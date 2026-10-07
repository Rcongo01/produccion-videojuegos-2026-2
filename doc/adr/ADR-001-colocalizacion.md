# Registro de Decisión de Arquitectura (ADR)

## ADR-001: Adopción de Co-localización y Arquitectura por Componentes

* **Estado:** Aprobado
* **Fecha:** 2026-10-03
* **Autor:** Ronaldo Congo Cancelado

### Contexto

El juego *Mi Plato Saludable* parte de un prototipo plano (Laboratorio 1) donde las escenas y los scripts estaban separados por tipo (`src/scenes/` y `src/scripts/`). El juego va a crecer con pantallas para conocer los grupos del Plato saludable de la Familia Colombiana, armar el plato y minijuegos; con la estructura plana, modificar una pantalla obliga a saltar entre carpetas distantes.

### Decisión

Adoptar el patrón de **Co-localización y Alta Cohesión**. Cada pantalla vive en su propio subdirectorio con su escena `.tscn` y su controlador `.gd`:

* `src/scenes/main/` → `menu_panel.tscn` + `menu_panel.gd` (menú del juego).
* `src/scenes/simulation/` → `step_1_base.tscn` + `step_1_base.gd` (pantalla para conocer los grupos del plato).

Todos los archivos y carpetas usan `snake_case` para evitar errores de rutas en la exportación Web.

### Consecuencias

* **Positivas:**
  * Los archivos que cambian juntos residen juntos.
  * Facilita el trabajo en paralelo y reduce conflictos de Git.
  * Cada pantalla es un componente transportable.
* **Negativas / Costos:**
  * Requiere reubicar y renombrar archivos desde el panel FileSystem de Godot.
  * Aumenta la profundidad del árbol de directorios.
