# Guía 6 · Máquinas de Estado Finito, Transiciones y Animaciones Programáticas

**Etapa del proyecto:** `lab-6` · tag `lab-6-final`

## Qué pide la guía

Construir el minijuego *Pizza Rush*: una escena reutilizable de pizza con una FSM (congelada, disponible, arrastrando, cocinando, lista, entregada), hornos y zona de entrega como `Area2D`, generadores, un controlador con temporizador, contador y panel de resultado, recompensa por `EventBus`, y animaciones `Tween` por transición.

## Cómo se aplicó a Mi Plato Saludable

Esta guía hizo posible **la idea central del juego**: el plato en el centro, los alimentos alrededor y el niño arrastrándolos a su grupo. En lugar de pizzas que se cocinan, cada **alimento** tiene una FSM, y los "hornos" son las **divisiones del plato**.

| Concepto de la guía | Aplicación en el juego |
|---|---|
| Mover el minijuego anterior a `catch_food/` | `gamification/catch_food/` contiene *Atrapa frutas y verduras*. |
| `pizza_rush_main.tscn` | `plate_process/plate_game/plate_game_main.tscn` — **"Arma tu plato"**. |
| `Pizza.tscn` (`CharacterBody2D`, `input_pickable`, `InteractionArea`, `Timer`) | `food_item.tscn`: imagen y nombre del alimento; un solo `Timer` para aparición y rechazo. |
| `Oven.tscn` (`Area2D`, grupo `oven`) | `plate_sector.tscn` (`Area2D`, grupo `plate_sector`): una división del plato con su color oficial. Se resalta al pasar un alimento por encima, destella al acertar y se pone roja al fallar. |
| `PizzaSpawn.tscn` (grupo `pizza_spawn`) | `food_tray.tscn` (grupo `food_tray`): 8 puestos **alrededor del plato**; se muestran 6 alimentos a la vez. |
| `DeliveryArea` | No hace falta: cada división del plato es el destino. |
| Estados de la pizza | `APARECIENDO → DISPONIBLE → ARRASTRANDO → UBICADO` (grupo correcto, fin del ciclo) / `→ RECHAZADO → DISPONIBLE` (grupo equivocado, vuelve a su puesto) / `→ DISPONIBLE` (soltado fuera del plato). |
| `change_state()` con `match` y `previous_state` | Igual; por ejemplo, `DISPONIBLE → UBICADO` directo es rechazado. |
| Mismo `Timer` reutilizado | Aparición (0,35 s) y rechazo (0,7 s). |
| Tweens por transición | Aparición con rebote y giro; *squash* al tomarlo; regreso suave a la bandeja; deformación y vuelo hasta un punto de la división al acertar; temblor rojo al fallar. |
| `PizzaRushManager` con temporizador y contador | `plate_game_main.gd`: 12 alimentos por plato, 150 s, contador de alimentos y puntos. |
| Panel de resultado y bloqueo de interacciones | Victoria: "¡Plato completo!" + un mensaje GABA al azar. Derrota por tiempo: mensaje 9 (actividad física). Se bloquean los alimentos y se oculta el HUD. |
| Recompensa al ganar por `EventBus` | **Plato perfecto** (sin errores): `bonus_obtained({"value": 20, "minimum_score": 100})`. |
| Input `interact` (clic izquierdo) | Agregado al Input Map. En pantallas táctiles funciona porque Godot emula el mouse con el toque. |
| `SceneContainer.mouse_filter = pass` | Aplicado en `main_app.tscn`. |

### Lo que pediste: información del grupo al acertar

Al soltar un alimento en su grupo, el **panel derecho** muestra:

1. "¡Muy bien! Leche → Lácteos" con la imagen del alimento.
2. **¿Para qué sirve?** — la función del grupo.
3. **¿Por qué es importante?** — su papel en la alimentación.
4. **Mensaje de las Guías Alimentarias** — el mensaje GABA asociado al grupo. El borde del panel toma el color de la división.

Al fallar se muestra "¡Casi!" y, si las pistas están activas, la función del grupo correcto.

### Cambios que reemplazan etapas anteriores

* La pantalla por botones (`plate_panel`, Guías 4-5) se sustituyó por el plato interactivo; *Armar mi plato* en el menú abre `plate_game_main`.
* En `GlobalManager`, un alimento mal ubicado ya no vuelve al mazo: regresa a su puesto.
* Se agregaron `label` y `plate_share` a cada grupo para dibujar el plato desde los datos.

### Mejoras al minijuego de la Guía 5 encontradas al probar

* Los spawners laterales lanzaban frutas por encima de las paredes (impulso entre -400 y 400). Se agregaron `impulse_min_x` / `impulse_max_x` exportados para lanzar siempre hacia el embudo.
* Máximo de generados subido a 18 (con topes de spawners que suman 22, para que la derrota siempre pueda ocurrir).

## Verificación realizada

Pruebas con **eventos de mouse reales** en una ventana (Godot 4.7 sobre display virtual):

* 6 divisiones y 6 alimentos disponibles al iniciar.
* Arrastrar al grupo correcto → `UBICADO`, +10 puntos, panel con función, importancia y mensaje GABA, y se repone un alimento.
* Grupo incorrecto → `RECHAZADO`, error contado, pista, y a los 0,7 s vuelve a `DISPONIBLE` en su puesto.
* Soltar fuera del plato → vuelve a su puesto.
* Transición inválida rechazada.
* Plato completo → victoria, 12 alimentos servidos en el plato, HUD oculto.
* Plato perfecto → estrella por `EventBus`. Tiempo agotado → derrota con interacciones bloqueadas.

22/22 pruebas superadas. El minijuego de la Guía 5, re-ejecutado 4 veces, se ganó todas con margen.
