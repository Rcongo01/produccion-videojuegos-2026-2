# Bitácora de Desarrollo (DEVLOG) - Mi Plato Saludable

## [2026-10-03] - Laboratorio 2: Refactorización a Arquitectura Modular

### Actividades Realizadas

* Inicialización de la rama de trabajo `lab-2` para aislar el desarrollo técnico.
* Organización co-localizada: `src/scenes/main/` (menú) y `src/scenes/simulation/` (pantalla de grupos del plato).
* Eliminación de carpetas vacías heredadas (`src/scripts/`, `src/assets/`, `src/components/`).
* Composición del menú con `VBoxContainer` y de la pantalla de grupos con `GridContainer` de 2 columnas (6 grupos del Plato saludable de la Familia Colombiana).
* Referencias a nodos con `@onready` y tipado estático; señales conectadas con `.connect()`.
* Uso de `.bind()` para reutilizar un único callback (`_on_grupo_selected`) con el nombre y la función de cada grupo.
* Experimento: botón de créditos que muestra y oculta un panel mediante señales programáticas.

### Desafíos y Soluciones

* *Desafío:* Mostrar información distinta para seis grupos sin escribir seis funciones.
* *Solución:* Un solo callback recibe `nombre_grupo` y `funcion` gracias a `.bind()`.
