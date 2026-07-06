# ADR-0001 — Sprint Review a mitad de Sprint 3

**Fecha:** 2026-07-06
**Estado:** Aceptado
**Contexto:** Verticales 1-4 certificadas; V5 pendiente. Review
sin código para evaluar coherencia de reglas, deuda y lecciones.

## Coherencia de reglas

Las 5 reglas bloquearon o habilitaron decisiones reales (no
decorativas): R1 rechazó el datasource de auth y el coordinador
prematuro; R2 verificada 2x por grep; R4 con registro vivo de
propietarios; R5 probada en runtime (logout reactivo).

## Tensiones documentadas (no contradicciones)

1. update() => save() en repos de perfil: duplicación aceptada
   conscientemente. Criterio: la Regla 1 aplica a CAPAS, no a
   métodos de contrato que expresan intención del dominio. No
   citar como precedente para capas vacías.
2. Convención "archivos completos": parciales solo si ≤3 cambios
   quirúrgicos en archivo largo, ofreciendo siempre el completo.

## Principios validados con evidencia

- Producto antes que arquitectura: offeredAt nació de una pregunta
  de negocio, no técnica.
- Verticales sobre capas: cero archivos a medio conectar.
- Navegación por estados: logout reactivo y fix popUntil costaron
  ~30 líneas por diseño correcto.
- Certificación con evidencia (logs/grep/plutil) sobre lectura:
  el bug de persistencia (S2) y el plist sin OAuth (V3) solo
  aparecieron con evidencia real.

## Decisiones malas documentadas (para no repetir)

1. AuthRepository inicial mezclaba autenticación con identidad.
   Lección: la revisión de diseño previa a implementación no es
   ceremonia — produjo la separación Auth/Profile.
2. signUpWithEmail nació sin name y hubo que modificar contrato
   congelado. Lección: al diseñar un contrato, recorrer TODOS los
   flujos de producto ya decididos que lo consumirán.
3. AppRoot v1 ignoraba pantallas apiladas (defecto hallado en
   certificación manual). Lección: la certificación no es opcional.
4. Ediciones parciales de código causaron los 2 incidentes de
   errores en cascada del sprint. La práctica de archivos completos
   fue corrección de proceso, no preferencia.

## Deuda elevada a candidata de Sprint 4

Separador de miles; teclado sobre formulario; pantalla de
Movimientos (desbloquea Ver todo, MovementPresentationMapper,
tests de edición). Comprometido: integración perfil ↔ Core.