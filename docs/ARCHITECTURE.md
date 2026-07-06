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

### Vertical 3 — Google Sign-In → pendiente
### Vertical 4 — Perfil financiero → pendiente
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