# FlowWise — Mapa de Dominio

**Brújula:** FlowWise no es un registro de finanzas personales.
Es un sistema que interpreta la realidad financiera de una
persona para ayudarle a tomar mejores decisiones. Toda capacidad
nueva se evalúa contra esta pregunta: ¿ayuda a interpretar la
realidad financiera y mejorar las decisiones del usuario? Si no,
probablemente es accesoria.

Este documento describe territorio, no implementación. Sin
clases, sin atributos, sin código — eso vive en ADR-0002,
ENGINE.md y el código mismo.

---

## Identity
**Responde:** ¿Quién es el usuario?
**Agregado raíz:** UserProfile
**Consume:** AuthSession (proveedor de autenticación)
**Produce:** identidad estable para todos los demás dominios
**Depende de:** nada — es la base
**Construido:** Sprint 3 completo (Auth email/Google, ownership,
identidad conectada al Home)
**Pendiente:** Apple Sign-In (requiere cuenta Developer), edición
de perfil, multi-dispositivo

---

## Money Flow
**Responde:** ¿Cómo estoy hoy? ¿Voy bien este mes?
**Agregado raíz:** FinancialMovement (hecho); FinancialState
(interpretación)
**Consume:** movimientos registrados, FinancialProfile (plan)
**Produce:** presupuesto, liquidez, proyecciones, decisiones del
presente
**Depende de:** Identity (movimientos pertenecen a un usuario)
**Construido:** Sprint 2 (Core V1) y Sprint 4 completo (Engine
interpreta el plan, proyecciones, frecuencias colombianas,
decisiones inteligentes)
**Pendiente:** Historial y gestión (editar/eliminar/buscar/
filtrar — Sprint retomado tras esta pausa), plantillas de
movimientos recurrentes

---

## Financial Commitments (Obligaciones Financieras)
**Responde:** ¿Cuánto debo? ¿Cuándo debo? ¿Qué pasa si no pago?
**Agregado raíz:** FinancialObligation (sellado: Credit y
hermanos futuros — RecurringExpense, TaxObligation nombrados,
no diseñados)
**Consume:** condiciones contractuales declaradas por el usuario
(entidad, tasa, plazo, seguros)
**Produce:** cuotas proyectadas, saldo pendiente, costo total
real; al pagarse, genera un FinancialMovement (los movimientos
siguen siendo la única fuente de verdad — ADR-0002 intacto)
**Depende de:** Identity, Money Flow (el pago es un movimiento;
la cuota alimenta las mismas decisiones que payDay)
**Construido:** nada — anzuelos únicamente (CreditRegistered
vacío, UpcomingObligation vacío, PayCreditAction sin regla)
**Pendiente:** todo. Primer dominio nuevo a auditar y diseñar
después de este mapa. InterestRate como value object (EA con
conversiones) es su pieza fundacional — probablemente
reutilizable por Wealth (inversiones)

---

## Wealth (Patrimonio)
**Responde:** ¿Qué tengo?
**Agregado raíz:** hoy ninguno real (WealthState existe pero solo
agrega saldos de cuenta); futuro: Asset / Investment
**Consume:** saldos de cuenta, y (futuro) instrumentos de
inversión declarados (CDTs, acciones, inmuebles)
**Produce:** patrimonio neto (activos − pasivos)
**Depende de:** Money Flow (saldos), Commitments (pasivos reales
— hoy WealthState.totalLiabilities está vacío de facto)
**Construido:** el modelo WealthState existe desde Sprint 2, sin
fuente real de pasivos
**Pendiente:** Investment (CDT y afines, reutilizando
InterestRate de Commitments; retención en la fuente como input
del usuario, no tabla tributaria modelada), conexión real de
Commitments → totalLiabilities

---

## Planning (Planificación)
**Responde:** ¿Qué quiero lograr?
**Agregado raíz:** futuro: Goal
**Consume:** capacidad de ahorro (Money Flow), capacidad de
endeudamiento (Commitments), patrimonio disponible (Wealth)
**Produce:** viabilidad de una meta ("con tu ingreso actual,
podrías...")
**Depende de:** Money Flow + Commitments + Wealth + Simulation
(la respuesta real requiere simular escenarios, no solo sumar)
**Construido:** GoalProgress existe como modelo vacío desde
Sprint 2; ContributeToGoalAction existe sin regla
**Pendiente:** todo. Es consumidor, no productor — no tiene
sentido diseñarlo antes que sus dependencias existan

---

## Simulation
**Responde:** ¿Qué pasa si...?
**Agregado raíz:** futuro: Scenario
**Consume:** el estado real (Money Flow + Commitments + Wealth)
como punto de partida
**Produce:** una proyección hipotética que NO modifica la
realidad — abono extraordinario, refinanciación, cancelar una
tarjeta, aumentar ahorro
**Depende de:** Commitments (no se puede simular un abono sin
modelo de amortización), Money Flow
**Construido:** nada
**Pendiente:** todo. Depende estructuralmente de Commitments —
no puede empezarse antes

---

## Financial Advisor
**Responde:** ¿Qué debería hacer?
**Agregado raíz:** ninguno — dominio nombrado por intuición, no
diseñado
**Consume:** todos los demás dominios
**Produce:** recomendaciones ("conviene prepagar este crédito",
"puedes aumentar tu ahorro sin comprometer liquidez")
**Depende de:** Money Flow, Commitments, Wealth, Planning,
Simulation — todos
**Construido:** nada
**Pendiente:** todo. Probablemente el verdadero producto Premium
final: no registra, no calcula — recomienda. No se diseña hasta
que sus dependencias existan

---

## Reports
**Responde:** ¿Cómo me ha ido en el tiempo?
**Agregado raíz:** ninguno — vista sobre datos de otros dominios,
no dominio productor propio
**Consume:** históricos de Money Flow, Commitments, Wealth
**Produce:** estadísticas, hábitos, tendencias visuales
**Depende de:** todos los dominios de datos
**Construido:** nada
**Pendiente:** todo. Nota de diseño: Historial (dentro de Money
Flow) es una vista operativa (editar/buscar); Reports es
analítico (tendencias). No son el mismo dominio aunque ambos
"muestren el pasado"

---

## Infrastructure
**Responde:** ¿Cómo funciona el sistema por debajo?
**Agregado raíz:** ninguno — capa transversal
**Contiene:** autenticación (construida, Sprint 3), persistencia
local (construida), Premium/feature-gating (UserProfile.premium
existe, sin ningún consumidor — deliberadamente: no se gatea
nada hasta que el dominio que se gatea exista), sincronización
remota (no construida)
**Depende de:** nada — sirve a todos
**Construido:** Auth completo, persistencia local completa
**Pendiente:** Premium gating (al final, cuando haya qué gatear),
sincronización remota (Firestore/Supabase — resuelve también las
limitaciones de multi-dispositivo y multi-usuario documentadas
en Sprint 3)

---

## Orden de dependencia (no de prioridad)

Identity
│
▼
Money Flow ──────► Financial Commitments ──────► Wealth
│                        │                       │
└────────────────────────┼───────────────────────┘
▼
Simulation
│
▼
Planning
│
▼
Financial Advisor
Reports e Infrastructure: transversales, sin posición fija.


Esta secuencia no es casualidad: describe una madurez financiera
real. Primero entiendes tu dinero, luego tus obligaciones, luego
tu patrimonio, luego puedes simular, luego planificar, y solo
entonces el sistema puede aconsejarte. La arquitectura sigue la
lógica de la vida financiera, no la lógica de las pantallas.

---

## Los tres motores

Este mapa revela que FlowWise no tiene un Engine — tiene tres,
con responsabilidades distintas y una relación de dependencia
clara:

**1. Interpretation Engine** (construido, Sprint 2 y 4)
Responde: ¿qué está pasando? Produce Budget, Liquidity,
Projection, DecisionContext, Decisions — interpreta la realidad
observada en los movimientos.

**2. Simulation Engine** (futuro, dominio Simulation)
Responde: ¿qué pasaría si...? No interpreta la realidad — la
hipotetiza. Importante: reutiliza las mismas reglas de cálculo
del Interpretation Engine (misma matemática de amortización,
presupuesto, proyección); lo que cambia es el insumo — estado
real vs. estado hipotético — no el mecanismo. No contamina el
Interpretation Engine con escenarios ficticios.

**3. Recommendation Engine** (futuro, dominio Financial Advisor)
Responde: ¿qué debería hacer? No calcula ni simula — consume los
resultados de los otros dos motores y produce consejo. Probable
diferenciador principal de FlowWise frente a cualquier app de
presupuesto.

---

## Documentos fundacionales de FlowWise

- **ARCHITECTURE.md** → cómo está construido (reglas, capas,
  certificaciones por sprint)
- **ENGINE.md** → cómo piensa (hechos, interpretaciones,
  decisiones)
- **DOMAIN_MAP.md** (este documento) → qué problemas resuelve

## Siguiente paso

Auditoría de negocio de **Financial Commitments → Credit** (el
subtipo concreto, con conocimiento real de mercado colombiano).
Su resultado puede ajustar las RELACIONES de este mapa (nunca
agregar dominios sin justificación escrita según la Regla del
Mapa).