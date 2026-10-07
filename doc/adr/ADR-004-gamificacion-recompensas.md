# Registro de Decisión de Arquitectura (ADR)

## ADR-004: Integración de Gamificación y Sistema de Recompensas Desacoplado

* **Estado:** Aprobado
* **Fecha:** 2026-10-03
* **Autor:** Ronaldo Congo Cancelado

### Contexto

El juego ya tiene `EventBus` (comunicación) y `GlobalManager` (estado). Se quiere motivar a los niños con un minijuego de destreza que entregue **estrellas de bonificación** para su plato, sin que el minijuego dependa de la pantalla del plato ni de su resumen.

### Decisión

* El minijuego *Atrapa frutas y verduras* (`src/scenes/gamification/`) es un módulo independiente del proceso principal (`src/scenes/plate_process/`).
* Al ganar publica `EventBus.bonus_obtained({"value": 30, "minimum_score": 60})`.
* `GlobalManager` guarda las estrellas en `bonuses` y expone las reglas: `get_best_bonus(subtotal)` y `remove_bonus(bonus)`.
* `plate_summary` (equivalente a la factura) solo consulta y representa el resultado.
* Reglas de negocio: una estrella por plato; se aplica la de mayor valor entre las válidas; solo es válida si el plato alcanza `minimum_score`; se consume únicamente al confirmar el plato; el total nunca es negativo.
* La entrada se modela con acciones del Input Map (`move_left`, `move_right`). Los botones táctiles en pantalla presionan las mismas acciones con `Input.action_press`, así el juego funciona en tabletas sin cambiar la lógica de la canasta.

### Consecuencias

* **Positivas:**
  * El minijuego puede reemplazarse (por ejemplo, por una ruleta) sin tocar el resumen del plato.
  * Las estrellas se administran en un único punto.
  * Nuevas reglas (caducidad, límite de intentos) se agregan en `GlobalManager`.
* **Negativas / Costos:**
  * Seguir una recompensa exige recorrer minijuego → EventBus → GlobalManager → resumen.
  * `GlobalManager` suma una responsabilidad más.
