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


### Vertical 5 — Home conectado + Ownership
**Estado: CERTIFICADA** (con salvedad documentada)

✔ SharedPreferencesUserProfileRepository (persistencia únicamente;
  no conoce Firebase ni AuthSession)
✔ UserProfileNotifier: siembra del perfil desde la sesión
  (responsabilidad del flujo post-auth, no del repositorio)
✔ LocalMovementOwnershipService (key estable:
  flowwise_movements_owner_uid = UserProfile.id)
✔ MovementOwnershipNotifier separado de identidad (Regla 1)
✔ Auto-claim: usuarios sin movimientos previos reclaman
  silenciosamente; sus propios datos jamás disparan el diálogo
✔ StartupRouteResolver: Auth → Ownership → Onboarding → Home
  (3 estados exactos — en el umbral documentado del coordinador)
✔ OwnershipDecisionScreen con confirmación explícita de borrado
✔ HomeHeader conectado: nombre, inicial, premium reales
  (deuda de Sprint 2 PAGADA)
✔ Limpieza: memory_movement_repository.dart eliminado
  (grep confirmó cero referencias)

**Salvedad de certificación:** la lógica de ownership quedó
certificada vía auto-claim (misma maquinaria); la UI de
OwnershipDecisionScreen quedó validada por lógica pero pendiente
de ejercitar visualmente — solo aparece en dispositivos con
movimientos pre-auth, ventana que ya pasó en el dispositivo de
desarrollo. Ejercitar cuando haya un caso real o en QA.

**Limitación documentada (multi-cuenta):** con persistencia local
mono-usuario, un segundo usuario en el mismo dispositivo vería
los movimientos del primero (el owner uid se registra pero no se
compara con el usuario actual). Se resuelve en el sprint de
sincronización remota, junto con la limitación de multi-dispositivo.

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

  ## Sprint 3 — CERRADO

Las 5 verticales certificadas. La identidad del usuario existe:
Splash → Welcome → Auth (Email + Google) → Ownership →
Perfil financiero → Home con usuario real.

Comprometido para Sprint 4: integración perfil ↔ Core (presupuesto
declarado, proyección payDay, CompleteProfileDecisionRule con
prioridad dinámica). Candidatos: separador de miles, teclado sobre
formulario, pantalla de Movimientos.

## Sprint 4 — El Core interpreta (en curso, por verticales)

### V1 — El Engine interpreta el plan
**Estado: CERTIFICADA**

✔ Rename: FinancialEngineV1 → RuleBasedFinancialEngine (contrato
  FinancialEngine intacto; nombres de comportamiento, no cronología)
✔ FinancialProfile como parámetro de recalculate/process (ADR-0002:
  contexto, nunca dependencia)
✔ Presupuesto sobre ingreso declarado cuando monthlyIncome != null
  (la condición es el dato, no el estado administrativo)
✔ BudgetBasis (declaredPlan/registeredIncome) en el dominio: el
  objeto explica su origen; la UI lo declara ("Plan" vs "Presup.")
✔ Cableado en composition root: profileNotifier → financialNotifier
  vía listener; los notifiers no se conocen entre sí
✔ Clamp visual movido del modelo al widget: el badge puede mostrar
  honestamente >100%; la barra se satura en 100%
✔ Certificado: modo plan (bloques 50/30/20 sobre declarado, etiqueta
  Plan, persistencia en cold-start) y modo medición (regresión cero)

### V2 — Proyecciones
**Estado: CERTIFICADA**

✔ ProjectionState: escenarios separados del presente
  (LiquidityState = presente; ProjectionState = escenario;
  tiempos distintos del dominio)
✔ Liquidez con horizonte real: disponible hasta el próximo
  ingreso esperado, degradación elegante a fin de mes
✔ Regla de fechas determinista: payDay este mes si no ha pasado,
  mes siguiente si pasó; payDay 31 = último día en meses cortos
✔ Proyección de agotamiento por bloque al ritmo propio observado
  (calculada, sin UI: su consumidor es la V3)
✔ Solo payFrequency == monthly, verificado explícitamente
  (silencio no es soporte); semanal/quincenal en backlog
✔ Pagada la ingeniería inversa del ingreso en calculateLiquidity
  (recibe income como parámetro)
✔ Principio 5 al ADR-0002: el Engine solo proyecta hipótesis
  enunciables ("al ritmo actual, se agotaría alrededor del...")
✔ Certificado: horizonte de 24 días con payDay 30, persistencia
  en cold-start, modo degradado validado por lógica

### V2.1 — Frecuencias colombianas
**Estado: CERTIFICADA**

✔ Decisión de producto: FlowWise nace para Colombia — mensual,
  quincenal y semanal son requisito de primera clase
✔ payDay con semántica documentada por frecuencia en el modelo
  (día del mes / primer pago quincenal / día ISO de semana)
✔ Un intérprete por frecuencia en el Engine (_nextMonthly,
  _nextBiweekly, _nextWeekly); sin doble significado silencioso
✔ Quincenal deriva el segundo pago (+15 días, saturado a fin de
  mes) desde un único campo
✔ Formulario adaptativo: selector de día del mes o de día de
  semana según la frecuencia elegida
✔ PaySchedule (Value Object) documentado como evolución en
  ADR-0002 — se adopta cuando el campo único genere fricción real
✔ Certificado manualmente: quincenal (primer y segundo pago),
  semanal (incluyendo "tu pago es hoy"), mensual (regresión cero),
  irregular (degradación elegante)
  
### V3 — Decisiones inteligentes
**Estado: CERTIFICADA** (con salvedad de entorno)

✔ DecisionContext: contextos por concepto de negocio (Profile,
  IncomeAlignment, ExpectedIncome), cada uno con conclusión +
  evidencia enunciable (principios 6 y 8)
✔ 4 reglas nuevas: ProfileDecisionRule (escalonada 0-5/6-20/>20),
  ExpectedIncomeDecisionRule (2 días de gracia, desaparición por
  regeneración), IncomeAlignmentDecisionRule (3 meses ±15%,
  opción A al vuelo), BlockDepletionDecisionRule (solo si el
  agotamiento precede al próximo ingreso — principio 7)
✔ UpdateFinancialProfileAction (switch exhaustivo protegió el mapper)
✔ formatCurrency desde el primer commit en reglas nuevas
✔ MomentumDecisionRule: dormida, TODO documenta rediseño de la
  rama improving antes de despertar (criterio accionable)
✔ IDs deterministas: infraestructura del criterio "no repetitiva"

**Salvedad:** activación de BlockDepletion certificada manualmente;
desactivación por reducción de ritmo validada por lógica (historial
inmutable + fecha del sistema no controlable). Candidata a prueba
automatizada cuando el Engine tenga Clock inyectable (anotado).

✔ docs/ENGINE.md creado: mapa conceptual hechos → interpretaciones
  → decisiones
  
### V4 — Pulido de experiencia → pendiente

**Backlog surgido en V1:** movimientos con fecha futura (ingresos
anticipados, gastos programados) — requiere auditoría de producto
propia (¿cuenta al registrarse o al ocurrir?); emparentado con
UpcomingObligation.