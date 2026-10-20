# Guía 9 · Interfaz Dinámica y Representación de Datos mediante Resources

**Etapa del proyecto:** `lab-9` · tag `lab-9-final`

## La idea: "Lonchera Express"

La guía construye una pizza de dos mitades. En Mi Plato Saludable la mecánica se convirtió en un juego de pedidos: **Lonchera Express**.

* Llegan **4 niños**, uno tras otro, cada uno con un pedido y un **tiempo límite**: *"¡Hoy tengo fútbol! Necesito agua"*, *"Nada de productos de paquete con sellos"*, *"No me gusta la leche, pero necesito calcio"*…
* El jugador arma una **lonchera de 4 compartimentos**: bebida, fruta o verdura, plato principal y snack. Al tocar un compartimento, la lista muestra solo los alimentos de ese tipo.
* Hay **31 alimentos**: 19 saludables y 12 **ultraprocesados o de comida rápida** (gaseosa, jugo de caja, refresco, papas fritas, hamburguesa, perro caliente, pizza, chocolatina, galletas y ponqué de paquete, dona y unas "gomitas de fruta" que son una trampa: no son fruta).
* Los productos de paquete muestran los **sellos negros de advertencia** ("EXCESO EN AZÚCARES", "EXCESO EN GRASAS SATURADAS"), para que el niño aprenda a reconocerlos.
* Cada lonchera entregada recibe de **1 a 3 estrellas**: una por entregarla, otra por cumplir el pedido y otra si está completa y sin ultraprocesados. Suma puntos, bonificación del pedido y **bonificación por rapidez**. Nutri explica qué estuvo bien y qué no.
* Al final, el resumen de la ronda aplica las **estrellas del minijuego** y guarda el **récord**.

Encaja con los mensajes de las Guías Alimentarias: incluir frutas enteras en cada comida y reducir los "productos de paquete", las comidas rápidas, las gaseosas y las bebidas azucaradas.

### Mejora del minijuego: "Atrapa lo saludable"

En *Ganar estrellas* ahora también caen gaseosas y ultraprocesados (tomados del mismo catálogo de Resources, con su sello). Atrapar una fruta o verdura suma; atrapar un ultraprocesado quita **una de 3 vidas**. Cada 3 aciertos el juego se acelera y caen más ultraprocesados. Si se gana sin perder vidas, la estrella vale más (estrella dorada, +40 en lugar de +30).

## Equivalencias con la guía

| Guía (pizza) | Proyecto (lonchera) | Archivo |
|---|---|---|
| `res://src/scenes/buying_process/assets` | `res://src/scenes/plate_process/assets/` (`lunchbox/`, `kids/`) | co-localización |
| `IngredientData` (`id`, `display_name`, `texture`, `price`) | Igual, `price` = puntos saludables. **Además** `kind`, `healthy`, `seals`, `icon` (Reto 3), `group_id` y `tip` | `src/data/ingredient_data.gd` |
| `src/data/ingredients/*.tres` | 31 alimentos | `src/data/ingredients/` |
| `IngredientDatabase` + `ingredient_database.tres` | Igual | `src/data/` |
| — | **`OrderData`** + `OrderDatabase`: 9 pedidos de niños, también como Resources | `src/data/order_data.gd`, `src/data/orders/` |
| `GlobalManager.ingredient_database` / `ingredients` | Igual (preload + propiedad con `get`); además `order_database` | `src/core/global_manager.gd` |
| `buy_panel_interactive` | `lunchbox_interactive` | `src/scenes/plate_process/lunchbox_interactive.tscn/.gd` |
| `PizzaComposition` con `LeftFlavor` / `RightFlavor`, `Button` flat, `Selection` | `LunchboxComposition` con `SlotBebida`, `SlotFruta`, `SlotPrincipal`, `SlotSnack` (los de la derecha con **Flip H**), cada uno con `Button` flat, `Selection`, nombre y sellos | `lunchbox_composition.gd` |
| `enum PizzaHalf { LEFT, RIGHT }` | `enum LunchboxSlot { BEBIDA, FRUTA, PRINCIPAL, SNACK }` | |
| `pizza_selection` / `pizza_total` | `lunchbox_selection` (4 compartimentos) / `lunchbox_total` | `global_manager.gd` |
| `EventBus.ingredient_selected(id, half)` | `EventBus.ingredient_selected(id, slot)` | `event_bus.gd` |
| `EventBus.pizza_total_changed` | `EventBus.lunchbox_total_changed` | `event_bus.gd` |
| `animate_pizza_update()` / `update_selection_visual()` | `animate_lunchbox_update()` / `update_selection_visual()` | `lunchbox_composition.gd` |
| `purchase_invoice_interactive` + `PurchaseSuccessPopup` | `lunchbox_summary` (resultados de la ronda) + `LunchboxSuccessPopup` | `lunchbox_summary.tscn/.gd` |
| `get_best_coupon` / `remove_coupon` | `get_best_bonus` / `remove_bonus` (las estrellas del Lab 5, sin cambios) | `global_manager.gd` |
| Botón *Compra interactiva* en el menú | Botón **Lonchera Express** (ButtonNav, ícono de lonchera) | `menu_panel.tscn` |

El plato y su resumen **no se modificaron**: las experiencias conviven, como pide la guía.

## Cómo se aplicó, parte por parte

### Parte 0 · Imágenes
`gen_lab9_v2.py` (fuera del proyecto) dibuja el cuerpo de la lonchera, un compartimento vacío y un compartimento por alimento (**un solo alimento por imagen**), los 9 niños, los sellos y las estrellas. Los compartimentos de la derecha usan la misma imagen con **Flip H**.

### Partes 1 y 2 · Datos
```gdscript
class_name IngredientData
extends Resource
@export var id: String
@export var display_name: String
@export var texture: Texture2D
@export var price: int                       # puntos saludables
@export_group("Lonchera Express")
@export_enum("bebida", "fruta", "principal", "snack") var kind: String = "fruta"
@export var healthy: bool = true
@export var seals: PackedStringArray = []    # "azucares", "sodio", "grasas"
@export_group("Presentación y contenido")
@export var icon: Texture2D                  # Reto 3
@export var group_id: String
@export_multiline var tip: String
```
Los pedidos usan la misma idea: `OrderData` tiene el niño, su avatar, el texto del pedido, una **regla** (`contiene`, `sin_sellos`, `sin_azucar`, `min_puntos`, `solo_saludable`), el tiempo límite y los textos de éxito y fallo. Las reglas las evalúa `GlobalManager.order_fulfilled()`.

**Reto 1:** primero se crearon los 19 alimentos saludables; luego se agregaron los **12 ultraprocesados sin tocar el código** (solo nuevos `.tres` en el catálogo). Lo mismo vale para los pedidos.

### Parte 3 · Lista dinámica
`_build_list(kind)` recorre `GlobalManager.ingredients` y crea un `Button` por cada alimento del compartimento elegido, conectado con `bind(ingredient)`. El botón muestra ícono, **nombre y puntos** (Reto 2) y, si los tiene, los **sellos** del empaque. Al cambiar de compartimento la lista se vuelve a generar.

**Ajuste de UX (Lab 8):** el `ScrollContainer` solo envuelve la lista; el total y los botones quedan fijos. *Entregar lonchera* usa el estado **Disabled** del Theme hasta que los cuatro compartimentos estén llenos (o se acabe el tiempo, que la entrega sola).

### Parte 4 · Compartimentos y estado
* `LunchboxComposition` recibe el `IngredientData` por **llamada directa** (misma interfaz) y emite `EventBus.ingredient_selected(id, slot)`.
* `GlobalManager` guarda el id en `lunchbox_selection[slot]`, recalcula `lunchbox_total` con el `price` y emite `lunchbox_total_changed`.
* Al elegir, la selección pasa sola al siguiente compartimento vacío.
* Al entregar, `GlobalManager.deliver_lunchbox()` califica la lonchera (`evaluate_lunchbox()`), guarda el resultado de la ronda, vacía la lonchera y pasa al siguiente niño.

### Parte 4.6 · Resultados
`lunchbox_summary` muestra una fila por niño (avatar, puntos y estrellas), el total de estrellas, un consejo general de Nutri, la mejor estrella del minijuego (`get_best_bonus`), el total y el récord. *Confirmar ronda* consume la estrella, guarda el récord y muestra **LunchboxSuccessPopup**.

### Partes 5 y 6 · Retroalimentación
`Selection` (ColorRect con `mouse_filter = Ignore`) hace un destello amarillo y queda suave en el compartimento activo; el alimento nuevo aparece con `animate_lunchbox_update()`. Además: el niño "llega" con un salto, la barra de tiempo se pone roja y el número late en los últimos 10 segundos, Nutri salta de alegría con un alimento saludable y se sacude con un ultraprocesado, las estrellas del resultado se encienden una a una con sonido y hay confeti con 3 estrellas.

### Reto 4 · Conservar la composición
Si el niño sale al menú y vuelve, el pedido, el tiempo y la lonchera siguen como los dejó: `_restore_from_state()` reconstruye los compartimentos desde `GlobalManager.lunchbox_selection` y la ronda desde `GlobalManager.lunch_round`.

## Reflexión final

* **¿Ventaja de separar los datos de la interfaz?** El contenido (qué alimentos hay, sus puntos, sellos, imagen y consejo; qué piden los niños) se edita en el Inspector sin tocar la interfaz; los mismos datos los usan la lista, la lonchera, la calificación, el resumen y hasta el minijuego.
* **¿Ventaja de generar los elementos automáticamente?** Se agregaron 12 ultraprocesados sin crear botones a mano ni cambiar código; la lista por compartimento sale de un filtro sobre el catálogo.
* **¿Diferencia entre estado y representación?** El estado es `lunchbox_selection` y `lunch_round` en el GlobalManager; la representación son las texturas, sellos, etiquetas y animaciones. Por eso la escena se puede reconstruir al volver (Reto 4).
* **¿Qué permite que la interfaz crezca?** Catálogos (`IngredientDatabase`, `OrderDatabase`), contenedores que se organizan solos (`VBoxContainer` en un `ScrollContainer`) y funciones que crean el botón a partir de un `IngredientData`.
* **¿Cuándo usar objetos de datos reutilizables?** Cuando los datos son contenido del juego que crece o lo edita alguien que no programa: alimentos, pedidos, niveles, preguntas. Un docente podría agregar alimentos típicos de su región o pedidos nuevos.

## Verificación realizada

`tests/test_lab9.gd` (con clics reales en Xvfb), **50 comprobaciones, 0 fallas**: catálogos de 31 alimentos y 9 pedidos como Resources; 12 ultraprocesados con sellos; 5 o más opciones por compartimento; botón del menú; ronda de 4 pedidos con tiempo que corre; lista generada solo con bebidas; sellos y puntos en los botones; clic real en compartimentos; paso automático al siguiente compartimento; reemplazo; total 135; regla del pedido; Reto 4; entrega con 3 estrellas y bonificaciones; lonchera de ultraprocesados con 1 estrella y la explicación de Nutri; entrega automática al acabarse el tiempo; resultados con una fila por niño, estrella aplicada y récord guardado; las cinco reglas de pedido; un alimento nuevo en el catálogo aparece solo; y el minijuego (3 vidas, ultraprocesado quita una vida, aceleración, derrota sin vidas, caen ambos tipos, un bot que esquiva gana, valor de la estrella según las vidas). Regresión de las Guías 6, 7 y 8: superada.

| Lonchera Express | Resultado de un pedido |
|---|---|
| ![](../img/lonchera.jpg) | ![](../img/lonchera_resultado.jpg) |
| **Resultados de la ronda** | **Atrapa lo saludable** |
| ![](../img/lonchera_resumen.jpg) | ![](../img/minijuego.jpg) |
