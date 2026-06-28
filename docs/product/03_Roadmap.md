Sprint 1
Rediseño del Home
Objetivo

Convertir el Home en el Centro de Control Financiero de FlowWise.

El usuario debe poder responder en menos de diez segundos estas cinco preguntas:

¿Cómo está mi presupuesto?
¿Cuánto puedo gastar?
¿Cómo va el mes?
¿Qué debo hacer ahora?
¿Estoy mejorando?
Jerarquía visual
AppBar

↓

Saludo

↓

Semáforo financiero

↓

Disponible para gastar hoy

↓

Dinero sin asignar

↓

Desempeño del mes

↓

Bloques 50/30/20

↓

Últimos movimientos

Fíjate que eliminé muchas cosas.

No porque no sean importantes.

Sino porque el Home debe ser extremadamente escaneable.

1. Semáforo financiero

Este sigue siendo el protagonista.

Pero ya no solo muestra colores.

Debe mostrar contexto.

Ejemplo

🟢 Esenciales

48%

$820.000 / $1.700.000

🟡 Estilo de Vida

74%

$520.000 / $700.000

🔴 Futuro

18%

$90.000 / $500.000

Cada fila debe tener

color
porcentaje
barra de progreso
monto usado
presupuesto
2. Disponible para gastar

No quiero que aparezca así

"$82.000"

Quiero que sea enorme.

Hoy puedes gastar

$82.400

sin afectar tu presupuesto

Eso responde la principal pregunta del usuario.

3. Dinero sin asignar

Debajo.

Más pequeño.

Dinero sin asignar

$180.000

Asignarlo ahora →

Porque queremos que haga clic.

4. Desempeño del mes

Esta parte me gustó mucho de tu idea.

Yo la haría así.

Mes transcurrido

████████░░

62%

Presupuesto usado

██████░░░░

49%

🟢 Excelente

Vas mejor que el ritmo esperado.

La lógica sería

Si

Presupuesto usado

<

Mes transcurrido

↓

Verde

Excelente

Si están parecidos

↓

Amarillo

Ten cuidado

Si

Presupuesto usado

Mes transcurrido

↓

Rojo

Debes mejorar

Esto es muchísimo más intuitivo.

No necesita interpretar números.

5. Bloques

No cambiaría mucho.

Solo haría las tarjetas más limpias.

Esenciales

Disponible

$920.000

────────

Usado

48%

6. Últimos movimientos

Cinco movimientos.

Con

ícono

categoría

hora

valor

Lo que sí cambiaría completamente

No pondría el patrimonio en el Home.

Y aquí cambio mi propia propuesta.

¿Por qué?

Porque después de leer más de FlowWise entendí cuál es la promesa de la aplicación.

No es invertir.

No es patrimonio.

Es controlar el flujo del dinero.

Entonces el Home debe hablar de flujo.

No de riqueza.

El patrimonio lo movería a

Estado Financiero

dentro de Informes.

Allá sí tendría sentido.

ACTIVOS

PASIVOS

PATRIMONIO

LIQUIDEZ

FLUJO

ENDEUDAMIENTO


Eso es una fotografía financiera.

El Home, en cambio, debe ser el tablero de control del día a día.

Lo que le pediría a Claude

Aquí es donde creo que está el verdadero valor de trabajar juntos. Yo no le pediría "haz un Home bonito", sino algo mucho más específico, por ejemplo:

Implementa un nuevo Home para FlowWise siguiendo una arquitectura modular. No desarrolles toda la interfaz en un único home_screen.dart. Crea un HomeScreen limpio que únicamente orqueste componentes reutilizables.

Divide la pantalla en widgets independientes:

HomeHeader
FinancialTrafficLightCard
DailySpendingCard
UnassignedMoneyCard
MonthlyPerformanceCard
BudgetBlocksCard
RecentMovementsCard

Cada widget debe ser completamente reutilizable, desacoplado de la lógica de negocio y recibir únicamente modelos o ViewModels mediante constructor. Evita lógica financiera dentro de los widgets; toda la lógica debe residir en servicios, providers o controllers.

Utiliza Material Design 3, soporta modo claro y oscuro, prepara la estructura para Skeleton Loading, Empty State y Error State, y mantén cada archivo por debajo de unas 250 líneas para facilitar mantenimiento.

Esta es la diferencia entre construir una pantalla y construir un producto

Si Claude genera un home_screen.dart de 1.200 líneas, dentro de seis meses será difícil mantenerlo. En cambio, si desde hoy imponemos una arquitectura modular, cuando agregues funciones como el Termómetro del Mes, la Salud Financiera o incluso el futuro Asistente Financiero Premium, simplemente añadirás una nueva tarjeta sin tocar las demás.

Creo que esa es la mejor manera de repartir el trabajo:

Yo defino qué debe existir, por qué existe, cómo debe comportarse y cómo debe organizarse la arquitectura funcional.
Claude implementa esa arquitectura en Flutter con código limpio, escalable y alineado con las buenas prácticas.

Con esa metodología, FlowWise puede crecer durante años sin que el proyecto se vuelva inmanejable. Y eso, en una aplicación financiera, vale mucho más que tener una pantalla bonita desde el primer día.