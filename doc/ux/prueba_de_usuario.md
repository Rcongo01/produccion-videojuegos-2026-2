# Prueba de uso · Mi Plato Saludable (Guía 8, Paso 1.1)

## Test

> **Test:** Un niño o niña de 7 a 10 años que nunca ha usado el juego debe poder entrar desde el menú, **armar un plato** ubicando los 12 alimentos en su grupo, **ganar una estrella** en el minijuego *Atrapa los alimentos* y **confirmar un plato con la estrella aplicada**, usando solo la interfaz.

| Aspecto | Qué se espera |
|---|---|
| **Flujo** | Menú → *Armar mi plato* → arrastrar los 12 alimentos → resumen → confirmar → menú → *Ganar estrellas* → minijuego → menú → *Armar mi plato* → resumen con la estrella. |
| **Acciones que debe poder hacer** | Tocar un alimento, arrastrarlo, soltarlo sobre un color del plato, leer el panel del grupo, volver al menú, mover la canasta en el minijuego, confirmar el plato. |
| **Información que debe comprender** | Que cada color del plato es un grupo; si acertó o se equivocó; cuántos alimentos le faltan y cuánto tiempo le queda; para qué sirve el grupo (panel derecho); qué es una estrella y que se gasta al confirmar. |
| **Situaciones a observar** | Pide ayuda · busca dónde tocar · duda entre dos grupos · suelta un alimento y no sabe si quedó bien · lee un mensaje y no lo entiende. |

## Protocolo

1. Abrir el juego en el menú y decir solo: *"Este es un juego sobre el plato saludable. Juega como quieras."*
2. Observar sin intervenir. Responder **solo** preguntas directas, después de que la persona no haya logrado avanzar.
3. Anotar cada momento en la tabla con el minuto y la pantalla.
4. Al final preguntar: *¿Qué fue lo más difícil? ¿Qué te gustó? ¿Para qué sirven las frutas?*

## Registro de observaciones

> Llenar durante la prueba con una persona real. Fecha: ____ · Participante: ____ (edad) · Versión: `lab-7-final`

| Min | Pantalla | Tipo de situación | Qué pasó |
|---|---|---|---|
|  |  | Solicita información |  |
|  |  | Busca dónde interactuar |  |
|  |  | Duda entre elementos |  |
|  |  | Necesita confirmar el resultado |  |
|  |  | Interpreta información |  |

## Hallazgos de la revisión (versión `lab-7-final`)

Antes de la prueba se recorrió la versión del Lab 7 con la lista de situaciones de la guía. Estos son los puntos donde un jugador nuevo se quedaría trabado o sin respuesta. Sirvieron como hipótesis para la prueba y para las mejoras del Lab 8:

| # | Situación | Pantalla | Hallazgo |
|---|---|---|---|
| H1 | Busca dónde interactuar | Plato | Nada indica que los alimentos se arrastran; un niño tiende a tocar el plato. |
| H2 | Solicita información | Plato | No había ayuda dentro de la partida; las instrucciones solo estaban en el panel derecho, con mucho texto. |
| H3 | Necesita confirmar el resultado | Plato | El acierto solo se veía en el panel derecho, lejos de donde se soltó el alimento. Sin sonido. |
| H4 | Interpreta información | Plato | Al equivocarse, el alimento volvía a la bandeja sin una frase que dijera qué hacer. |
| H5 | Duda entre elementos | Plato | El tiempo bajaba sin aviso; al llegar a 0 la partida terminaba de sorpresa. |
| H6 | Necesita confirmar el resultado | Resumen | Al presionar *Confirmar plato* solo cambiaba un texto pequeño. |
| H7 | Duda entre elementos | Menú y paneles | Botones solo con texto; *Volver* y *Confirmar* se veían iguales. |
| H8 | Busca dónde interactuar | Plato | Si el jugador no hace nada, el juego tampoco hace nada. |

> **Para el informe:** reemplaza o confirma estos hallazgos con lo que veas en tu prueba real (anota también los que no se cumplieron). El Reto 2 pide repetir la prueba **después** de los cambios con otra persona: usa la misma tabla de registro.

## Segunda prueba (Reto 2, después de las mejoras · versión `lab-8-final`)

| Min | Pantalla | Situación | Qué pasó | ¿Se resolvió con la mejora? |
|---|---|---|---|---|
|  |  |  |  |  |

**Problemática más común detectada:** ____________________

**Solución aplicada:** ver `analisis_interacciones.md`, sección *Reto 2*.
