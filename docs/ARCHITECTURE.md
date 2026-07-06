# FlowWise — Registro de Arquitectura

## Reglas oficiales

1. **Regla 1** — No se crean capas por simetría. Cada capa debe
   justificar su existencia con una responsabilidad propia.
2. **Regla 2** — Las dependencias externas (firebase_auth,
   shared_preferences, etc.) solo pueden ser importadas por sus
   implementaciones concretas en la capa data. Nunca por el
   dominio, el estado o la UI. Verificable por grep.
3. **Regla 3** — Ciclo obligatorio: Auditoría → Diseño →
   Aprobación → Implementación → Validación → Cierre.
4. **Regla 4** — Todo servicio debe tener un propietario: quién
   lo crea, quién lo destruye, quién lo inyecta.
5. **Regla 5** — Solo AppRoot decide el flujo principal; las
   pantallas nunca navegan como consecuencia de cambios de
   autenticación.

## Principios

- "El Core nunca define presentación. La UI nunca contiene
  lógica financiera."
- "Las pantallas representan estados; no deciden estados."
- "El Splash nunca toma decisiones de negocio."
- Primero producto → luego arquitectura → solo entonces código.
- YAGNI: no abstraer antes de tener dos consumidores reales.
- Commit local = checkpoint arquitectónico. Push = checkpoint
  funcional (vertical certificada).
  - "A partir de la base construida, una vertical bien certificada
  vale más que dos implementadas a toda velocidad."
  - "La arquitectura debe emerger de las preguntas de negocio, no
  de patrones preconcebidos."
- Umbral objetivo del resolver: cuando StartupRouteResolver
  necesite combinar más de tres estados independientes o ejecutar
  lógica secuencial entre ellos, se promueve a StartupCoordinator.

## Auditorías recurrentes

- Regla 2 por grep (imports externos fuera de data/).
- Composition Root Audit al cierre de cada sprint: quién crea,
  posee, destruye e inyecta cada dependencia; sin singletons
  ocultos.

---

## Sprint 2 — Core Financiero V1
**Estado: CERTIFICADO** (commit 93714ed)

✔ MovementDatasource + SharedPreferences (persistencia verificada
  en cold-start con logs)
✔ FinancialMovementMapper (dominio ↔ persistencia)
✔ LocalMovementRepository
✔ FinancialEngineV1 (process + recalculate)
✔ DecisionEngine + DecisionRules (SRP) + DecisionAction (sealed)
✔ DecisionUiModel + DecisionUiMapper
✔ Home responde las 4 preguntas: ¿Cómo estoy? ¿Tengo dinero?
  ¿Voy bien este mes? ¿Qué debo hacer ahora?

## Sprint 3 — Identidad del usuario (en curso, por verticales)

### Infraestructura de autenticación
**Estado: CERTIFICADA** (commit 52763f2)

✔ Dominio: AuthSession, AuthFailure, 3 contratos de repositorio,
  MovementOwnershipService (contrato)
✔ FirebaseAuthenticationRepository (validado contra Firebase real)
✔ Separación Auth ≠ Identidad ≠ Perfil financiero

### Vertical 1 — Splash
**Estado: CERTIFICADA** (commit b440ac4)

✔ StartupRouteResolver (función pura, enum)
✔ AppRoot (único navegador de flujo)
✔ SplashScreen pasivo (sin lógica ni timers)

### Vertical 2 — Login Email
**Estado: CERTIFICADA**

✔ Email/Password (login + registro con nombre)
✔ Persistencia de sesión (kill + reabrir → Home directo)
✔ AuthFormViewModel (validación + errores en español)
✔ Logout reactivo (Regla 5 verificada en runtime)
✔ AppRoot limpia pila al cambiar flujo

**Auditoría post-certificación V2** (sin defectos críticos):
- popUntil en AppRoot: correcto hoy; refinar si aparecen flujos
  apilados que deban sobrevivir cambios de sesión.
- Inyección en cascada (2 niveles): aceptable; umbral de revisión
  en 4+ niveles.
- Backlog UX: mostrar/ocultar contraseña; limpiar campos al
  alternar login/registro.
- auth_screen.dart cerca del límite de tamaño; evaluar extracción
  de widgets al crecer en V3.

### Vertical 3 — Google Sign-In
**Estado: CERTIFICADA**

✔ Infraestructura iOS (GoogleService-Info.plist con OAuth,
  REVERSED_CLIENT_ID como URL Scheme en Info.plist)
✔ AuthProvider enum + submitWithProvider (abstracción de
  proveedores federados, sin método por proveedor)
✔ Cancelación silenciosa (cerrar el selector no es un error)
✔ Certificado: login, sesión restaurada, re-login, cancelación

**Auditoría post-certificación V2** (aplicada en V3): la extracción
de widgets de auth_screen.dart queda en observación; el archivo
creció con _DivisorO y _BotonGoogle — evaluar extracción en V4/V5
si se agregan más elementos.


### Vertical 4 — Perfil financiero
**Estado: CERTIFICADA**

✔ FinancialProfile + offeredAt (distinción omitido/desconocido)
✔ OnboardingStatus derivado del modelo (unknown/notOffered/
  offered/completed)
✔ SharedPreferencesFinancialProfileRepository (get-or-create;
  contrato intacto con Future<FinancialProfile?>)
✔ FinancialProfileNotifier + FormViewModel (Reglas 4 y 5)
✔ Pantalla de perfil guiada: Continuar / Lo haré después
✔ StartupRouteResolver extendido (sigue función pura; recibe
  OnboardingStatus resuelto, no campos crudos)
✔ Integración mínima en Home: ingreso declarado visible
✔ Certificado: primera oferta única, posposición persistente,
  no reinterrumpe tras logout/login, declarado sobrevive cold-start

**Decisiones de producto V4:**
- El perfil existe siempre (empty() en primer uso); la app nunca
  maneja "sin perfil", solo completed true/false.
- FlowWise guía, no obliga: todos los campos omitibles.
- Sin perfil no se bloquea nada; se degradan capacidades.
- El flujo se ofrece UNA vez por cuenta-dispositivo (offeredAt).
- El pendiente vivirá como FinancialDecision (Sprint 4).
- Integración perfil ↔ Engine pospuesta a Sprint 4 (un solo ciclo:
  presupuesto declarado + proyección payDay +
  CompleteProfileDecisionRule con prioridad dinámica).


### Vertical 5 — Home conectado → pendiente

## Deuda técnica activa

- HomeHeader hardcodeado (se paga en V5)
- Navegación de DecisionAction (pantallas destino no existen)
- "Ver todo" en RecentMovementsCard (Sprint 4)
- MovementPresentationMapper (al existir pantalla Movimientos)
- "¿Olvidaste tu contraseña?" (post-V2)
- signInWithApple lanza unknown (requiere Apple Developer;
  considerar AuthFailureReason.providerUnavailable al retomarlo)
- Arquitectura objetivo: AuthenticationCoordinator (cuando auth +
  onboarding + perfiles converjan)
- Ícono oficial de Google (branding guidelines) — pulido visual
- BUNDLE_ID com.example.flowwise → cambiar antes de App Store
  (requiere re-registrar app en Firebase) — pre-lanzamiento
  - Elevados a candidatos Sprint 4: separador de miles en montos,
  teclado tapa formulario de registro, pantalla de Movimientos.