# Guía 5 · Entrada del Usuario, Movimiento y Mecánicas Básicas

**Etapa del proyecto:** `lab-5` · tag `lab-5-final`

## Qué pide la guía

Reorganizar el flujo de compra, crear una experiencia gamificada independiente (un minijuego de recolección con `CharacterBody2D`, `RigidBody2D`, `StaticBody2D`, spawners e Input Map) que entregue cupones por el `EventBus`, y aplicar el mejor cupón válido en la factura con reglas de negocio.

## Cómo se aplicó a Mi Plato Saludable

| Concepto de la guía | Aplicación en el juego |
|---|---|
| `simulation/` → `buying_process/` | `simulation/` → **`plate_process/`** (el proceso principal es armar el plato). |
| `step_1_base` → `buy_panel` | `step_1_base` → **`plate_panel`** (nodo raíz `PlatePanel`). |
| `coupon_event.tscn` | **`bonus_event.tscn`**: invita voluntariamente a "Ganar estrellas" y muestra cuántas hay guardadas. |
| `coupon_game.tscn` (minijuego) | **`gamification/bonus_game.tscn` — "Atrapa frutas y verduras"**. |
| Jugador `CharacterBody2D` | Una **canasta** que se mueve con A/D o flechas. |
| `falling_food` (`RigidBody2D`, grupo `collectable`, rebote, `contact_monitor`) | Caen **frutas y verduras al azar** tomadas del catálogo del `GlobalManager`; se destruyen al tocar el suelo (grupo `floor`). |
| Suelo y embudo (`StaticBody2D`) | Mesa de madera y dos paredes de piedra inclinadas (sprites generados para el proyecto). |
| Spawner con Timer, límite y parábola | 3 spawners superiores y 2 laterales con parábola, con intervalos y límites distintos. |
| `AreaRecolect` + señal `collected_food` | Área sobre la canasta; la señal se conecta al controlador desde el editor (conexión en el `.tscn`). |
| Meta 10 / máximo 15 | Meta **8** / máximo 15 generados (ajustado para niños; verificado como ganable). |
| Cupón `{"value", "minimum_purchase"}` | **Estrella** `{"value": 30, "minimum_score": 60}`. |
| `purchase_invoice` | **`plate_summary`**: aciertos por grupo frente a lo esperado, errores, subtotal, estrella aplicada y total. *Confirmar plato* consume la estrella y empieza un plato nuevo. |
| `get_best_coupon` / `remove_coupon` | `get_best_bonus(subtotal)` / `remove_bonus(bonus)` en `GlobalManager`. |
| Input Map (`move_left`, `move_right`) | A + ←, D + → con mapeo físico. **Extra:** botones táctiles ◀ ▶ que presionan las mismas acciones (útil en tableta y Web). |

Al ganar, el panel de resultado muestra además el **mensaje 3 de las GABA** (frutas enteras y verduras frescas en cada comida), reforzando el aprendizaje.

### Reglas de negocio implementadas

* Una estrella por plato.
* Se aplica automáticamente la de mayor valor entre las válidas.
* Solo es válida si el plato alcanza el puntaje mínimo.
* Se consume al confirmar el plato, no al ver el resumen.
* El total no puede ser negativo.

## Verificación realizada

* Un bot jugó el minijuego moviendo la canasta hacia la fruta más baja: **ganó con 8 de 13 frutas generadas**, lo que confirma que el reto es conseguible.
* Sin mover la canasta se pierde y no se entrega estrella.
* Plato de 30 puntos: la estrella (mínimo 60) no se aplica. Plato de 70 puntos con estrellas de +30 (mín. 60) y +50 (mín. 200): se aplica la de +30 (la mejor **válida**) y el total es 100.
* Al confirmar se consume solo la estrella usada y el plato se reinicia.

13/13 pruebas superadas.
