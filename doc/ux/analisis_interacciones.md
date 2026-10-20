# Análisis de la comunicación del juego del plato (Guía 8, Paso 1.2)

En la guía se analiza *Pizza Rush*. En este proyecto el minijuego equivalente es el **plato interactivo** (`plate_game_main.tscn`, construido en el Lab 6): el jugador debe descubrir que **toma** un alimento, lo **arrastra** y lo **suelta** sobre su grupo. Cada interacción se analizó con el formato **Situación → Mejora propuesta → Resultado esperado**, y todas las mejoras se implementaron.

| Interacción | Situación | Mejora propuesta (implementada) | Resultado esperado |
|---|---|---|---|
| **1. Empezar / tomar** | Al empezar, el jugador ve el plato y 12 alimentos, pero nada le dice que se pueden mover. | **Mano guía animada** (`TutorialHand`) que toma un alimento y lo lleva hasta su grupo, en bucle, la primera vez que se juega. Instrucción en la barra inferior: *"Mira la mano: toma el alimento y llévalo a su grupo"*. **Cursor de mano** al pasar sobre un alimento. | Reconoce que los alimentos se toman y se arrastran. La mano desaparece en cuanto empieza a arrastrar y no vuelve después del primer acierto (`tutorial_done` se guarda). |
| **2. Arrastrar** | Mientras arrastra, no sabe dónde soltar. | La instrucción cambia sola a *"Suéltalo sobre el color de su grupo"* (estado `ARRASTRANDO` de la FSM). Cursor de arrastre. El sector bajo el alimento ya se resaltaba (Lab 6). Sonido *pick*. | Entiende que el destino es un color del plato. |
| **3. Soltar bien** | Acierta, pero el aviso queda lejos (panel derecho). | **"+10" flotante** en el punto donde soltó, **sonido de acierto**, y **racha** (*¡Racha x3!*, x5, x8, x12) con su propio sonido. El panel del grupo sigue explicando su función y su mensaje GABA. | Confirma el acierto en el lugar donde mira y se motiva a seguir. |
| **4. Soltar mal** | Se equivoca; el alimento vuelve a la bandeja y no sabe qué pasó. | **"¡Ups!" flotante**, sonido de error, la instrucción cambia a *"¡Casi! Lee la pista del panel y vuelve a intentarlo"*, la racha se reinicia. Pista del grupo correcto en el panel (opción *Mostrar pistas*). | Entiende que falló, sabe dónde mirar y que puede reintentar. |
| **5. Pedir ayuda** | Durante la partida no hay instrucciones a la mano. | **Botón "?"** (convención de ayuda) en el HUD que abre una ventana *¿Cómo se juega?* con 5 pasos y el botón *Muéstrame con la mano*. **El tiempo se detiene** mientras está abierta. Botón **X** para cerrar. | Consulta las reglas sin perder la partida. |
| **6. Terminar** | Arma el plato y confirma, pero solo cambia un texto. | **PlateSuccessPopup** (*¡Plato servido!*, ✓ verde, total de puntos, mensaje GABA y *Continuar*) + confeti y sonido de victoria al completar el plato. | Sabe que terminó, cuántos puntos obtuvo y cómo volver. |

## Reto 1 · Instrucciones progresivas

`HintBar` (esquina inferior izquierda) cambia su texto según la señal `state_changed(food, from, to)` que emite cada alimento al cambiar de estado en la FSM:

| Estado / evento | Texto |
|---|---|
| Inicio (primera vez) | *Mira la mano: toma el alimento y llévalo a su grupo* |
| Inicio (ya sabe jugar) | *Toca un alimento y arrástralo hasta su grupo del plato* |
| `DISPONIBLE → ARRASTRANDO` | *Suéltalo sobre el color de su grupo* |
| Acierto (`placement_evaluated` correcto) | *¡Muy bien! Sigue con el siguiente alimento* |
| Error | *¡Casi! Lee la pista del panel y vuelve a intentarlo* |

La mano guía es la instrucción visual del primer paso; cuando la acción ya es conocida (primer acierto) desaparece y no se vuelve a mostrar en las siguientes partidas (`GlobalManager.settings.tutorial_done`, persistente). Se puede volver a ver desde la ayuda.

## Reto 2 · Otras problemáticas resueltas

| Problema (hallazgo) | Solución | Dónde |
|---|---|---|
| **H5.** El tiempo se acababa sin aviso. | A los 20 s (`low_time_warning`) el contador se pone **rojo y pulsa**. | `plate_game_main.gd` → `_start_low_time_warning()` |
| **H8.** Si el niño se queda quieto, el juego no reacciona. | Tras 10 s sin interacción (`idle_nudge_seconds`) un alimento hace un **pequeño salto** (`food_item.nudge()`) para invitar a tocarlo. | `plate_game_main.gd` → `_process()`, `food_item.gd` → `nudge()` |
| Sonido molesto en un aula. | Opción **Sonidos del juego** (persistente) en Ajustes, con interruptor verde/gris. | `config_panel`, `AudioManager`, `GlobalManager.settings.sound_enabled` |

> Documenta aquí la problemática que encuentres en tu segunda prueba real (Reto 2) si es distinta de estas.

## Reto 3 · Popup refinado

`PlateSuccessPopup` usa las variaciones del Theme `PopupOverlay` (fondo oscuro semitransparente que bloquea los clics), `PopupCard` (tarjeta crema con borde verde), `PopupTitle` (título verde de 38 px) y `PopupText`. Jerarquía: ícono ✓ (64 px) → título → mensaje → **total** destacado en dorado → botón *Continuar* con ícono ✓. Aparece con una animación de escala (`TRANS_BACK`).
