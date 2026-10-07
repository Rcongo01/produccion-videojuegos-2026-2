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

## [2026-10-03] - Laboratorio 3: Arquitectura de Navegación Desacoplada

### Actividades Realizadas

* Inicialización de la rama de trabajo `lab-3`.
* Implementación de `EventBus` como Autoload con `navigation_requested` y `parameter_changed`.
* Creación de `MainApp` + `SceneContainer` como escena principal y único responsable de instanciar pantallas.
* Fondo persistente en `MainApp` que se conserva durante la navegación.
* Menú y pantalla de grupos del plato refactorizados para emitir solicitudes al bus.
* Paneles de Configuración (opción "Mostrar pistas") y Créditos (autor y fuente GABA).
* ADR movidos a `doc/adr/`; creación de ADR-002.

### Desafíos y Soluciones

* *Desafío:* Entender la comunicación indirecta entre paneles y orquestador.
* *Solución:* Las pantallas solo emiten intenciones; `MainApp` es el único que sabe cargar escenas.

## [2026-10-03] - Laboratorio 4: Gestión de Estado Global y Componentes de Navegación Reutilizables

### Actividades Realizadas

* Inicialización de la rama de trabajo `lab-4`.
* `GlobalManager` como Autoload con los datos del Plato saludable (6 grupos, 34 alimentos, 9 mensajes GABA) y el estado de la ronda.
* Nuevas señales del `EventBus`: `next_food_requested`, `food_placed`, `food_changed`, `placement_evaluated`, `score_changed`, `hints_toggled`, `round_restart_requested`.
* Primera versión jugable: elegir el grupo de cada alimento; al acertar se muestra la función del grupo, su importancia y el mensaje GABA.
* Rondas de 12 alimentos que imitan las proporciones del plato (3-3-2-2-1-1).
* Componente `ButtonNav` con `target_scene` y `discard_previous`; historial de navegación como pila en `MainApp`.
* Eliminación de `credits_panel.gd`; la preferencia de pistas pasa a `GlobalManager.settings`.

### Desafíos y Soluciones

* *Desafío:* Separar la evaluación de respuestas de la interfaz.
* *Solución:* La interfaz solo emite `food_placed`; `GlobalManager` decide si es correcto y responde con `placement_evaluated`.
* *Desafío:* El botón "Siguiente" permitía saltar alimentos y dejar la ronda incompleta.
* *Solución:* Se deshabilita hasta que el niño responde.
