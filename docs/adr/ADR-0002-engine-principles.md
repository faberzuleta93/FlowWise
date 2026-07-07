# ADR-0002 — Principios del Motor Financiero

**Fecha:** 2026-07-06
**Estado:** Aceptado
**Contexto:** Sprint 4 integra FinancialProfile al cálculo. Antes
de tocar el Engine, se fijan los principios que gobiernan su
evolución.

## Principios

1. **El perfil representa el plan; los movimientos representan
   la realidad.** El ingreso declarado es el presupuesto base
   (no un techo: la realidad puede superarlo). Lo declarado
   planifica; lo registrado mide. Nunca se mezclan (no existen
   promedios ni sustituciones entre ambos).

2. **El Engine interpreta la relación entre plan y realidad;
   nunca sustituye uno por el otro.** La contradicción entre
   ambos no es un error: es el insumo de las decisiones. Solo
   las discrepancias sostenidas (tendencia, no fotografía)
   generan sugerencias; FlowWise nunca auto-ajusta el plan.
   La relación incluye coincidencia, exceso, defecto y ausencia de realidad — no solo distancia.

3. **Toda decisión del Engine debe poder explicarse con datos
   observables.** Si el sistema sugiere "actualiza tu ingreso
   declarado", debe poder decir por qué: "en los últimos 3 meses
   registraste en promedio $34M; tu declarado sigue en $30M".
   El sistema guía; nunca es caja negra.

4. **El Engine nunca crea hechos; únicamente interpreta hechos
   utilizando el contexto disponible.** Aumentar el contexto
   (perfil, y en el futuro configuración regional, inflación,
   metas, escenarios hipotéticos) no cambia su responsabilidad,
   solo mejora la calidad de sus interpretaciones. El Engine
   crece verticalmente (contexto más rico), no horizontalmente
   (responsabilidades nuevas).

## Decisiones derivadas

- El perfil entra al Engine como PARÁMETRO de recalculate/process,
  nunca como dependencia del constructor. El Engine calcula sobre
  un contexto; no "usa" colaboradores. Se mantiene puro,
  determinista y testeable sin mocks.
- Umbral del FinancialContext: cuando el cálculo requiera tres o
  más insumos independientes (hoy: período y perfil = dos), los
  parámetros se agrupan en un FinancialContext. Habilitará
  escenarios hipotéticos ("¿y si mi ingreso fuera X?").
- Tendencias derivadas de la fuente de verdad (movimientos), nunca
  de conclusiones persistidas. "Discrepancia sostenida" se calcula
  al vuelo consultando los meses previos. Los hechos envejecen
  mejor que las conclusiones. Mismos movimientos + mismo perfil =
  misma respuesta, siempre.
- Filtro de utilidad de decisiones (4 criterios): accionable,
  oportuna, no repetitiva, relevante para el objetivo financiero
  del usuario. Lo informativo sin acción no entra a la tarjeta
  "¿Qué debo hacer ahora?".

- La condición de planificación es el dato, no el estado
  administrativo: se usa el plan cuando monthlyIncome != null,
  no cuando completed == true. BudgetBasis (declaredPlan /
  registeredIncome) se modela como enum del dominio, no como
  booleano de implementación, y se construye junto con el Budget
  (el objeto explica completamente su origen).

## Modos de operación (matriz declarado × registrado)

| Declarado | Registrado | Modo |
|-----------|------------|------|
| No | No | Degradación elegante |
| Sí | No | Plan puro |
| No | Sí | Medición pura |
| Sí | Sí | Plan + medición (distancia) |

Ningún cuadrante rompe la aplicación; cambia la calidad del
análisis.
## Taxonomía del FinancialState (hecho vs. interpretación)

Hechos (observaciones de movimientos): monthSummary,
recentMovements, budget.spent.
Interpretaciones (evaluaciones del Engine): budget.allocated,
liquidity.availableToday, health, momentum, decisions.

Hallazgo de auditoría: la frontera existía desde Sprint 2 sin
documentar (health/momentum/decisions siempre fueron
interpretaciones). Sprint 4 la vuelve explícita: budget.allocated
pasa de derivarse de la realidad a expresar el plan cuando existe
(budgetBasis lo declara). Regla: los hechos no dependen del
perfil; las interpretaciones pueden depender de él.