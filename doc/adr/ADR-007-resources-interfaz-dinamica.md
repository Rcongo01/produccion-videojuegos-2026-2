# Registro de Decisión de Arquitectura (ADR)

## ADR-007: Alimentos como Resources e interfaz generada a partir de datos

* **Estado:** Aprobado
* **Fecha:** 2026-10-19
* **Autor:** Ronaldo Congo Cancelado

### Contexto

Se agregó una segunda experiencia: **Lonchera Express**, un juego de pedidos en el que el jugador llena los cuatro compartimentos de una lonchera (bebida, fruta, plato principal y snack) según lo que pide cada niño. La lista debía poder crecer (el Reto 1 pide 5 alimentos más sin tocar código) y cada alimento necesita una imagen para la lonchera, un ícono, sus puntos, su compartimento, si es ultraprocesado, sus sellos de advertencia y un consejo. Los pedidos de los niños también son contenido que crece. Los alimentos del plato (Lab 4) viven en un `Dictionary` dentro del `GlobalManager`, que no permite referenciar texturas ni editarlos desde el Inspector.

### Decisión

* Cada alimento de la lonchera es un **`IngredientData`** (`Resource`) guardado como `.tres` en `src/data/ingredients/`.
* El catálogo es un **`IngredientDatabase`** (`ingredient_database.tres`); `GlobalManager` solo lo precarga y expone `ingredients` con un `get`, sin copiar datos.
* Los pedidos siguen el mismo patrón: **`OrderData`** / **`OrderDatabase`** con el niño, su pedido, una regla declarativa (`contiene`, `sin_sellos`, `sin_azucar`, `min_puntos`, `solo_saludable`) y su tiempo. `GlobalManager.order_fulfilled()` interpreta la regla.
* El minijuego toma los ultraprocesados del mismo catálogo (`healthy = false`), así un alimento nuevo aparece también ahí.
* `lunchbox_interactive.gd` **genera un botón por recurso** del compartimento elegido; ningún botón de alimento existe en la escena.
* `LunchboxComposition` es un componente de **presentación**: recibe el recurso por llamada directa (misma interfaz) y comunica el cambio por `EventBus.ingredient_selected`. El **estado** (`lunchbox_selection`, `lunchbox_total`) vive en `GlobalManager`, que emite `lunchbox_total_changed`.
* La calificación (`evaluate_lunchbox`: puntos, 1 a 3 estrellas y mensajes de Nutri), la ronda de pedidos (`lunch_round`, temporal) y el récord (`lunch_best`, persistente) viven en el `GlobalManager`; las estrellas del minijuego (`get_best_bonus`, `remove_bonus`) se reutilizan sin cambios.
* Los alimentos del plato se mantienen en el diccionario del Lab 4 para no romper los sistemas anteriores.

### Consecuencias

* **Positivas:**
  * Agregar un alimento o un pedido es crear un `.tres` y sumarlo al catálogo; probado al agregar 12 ultraprocesados sin cambiar código.
  * La misma estructura de datos sirve a la lista, a la lonchera, a la calificación, al resumen y al minijuego.
  * El estado global permite reconstruir la lonchera al volver a la escena (Reto 4).
  * El plato y las reglas de las estrellas no se tocaron; el minijuego solo se extendió para leer el catálogo.
* **Negativas / Costos:**
  * Conviven dos formas de representar alimentos (diccionario del plato y `Resource` de la lonchera). Migrar el plato a `Resource` queda como mejora futura.
  * Un `.tres` con un error de ruta no falla al compilar, solo al cargar; las pruebas revisan que cada recurso tenga textura e ícono.
  * Los íconos a color de la lista necesitan anular el tinte de íconos del Theme.
