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

## [2026-10-03] - Laboratorio 5: Integración de Gamificación y Sistema de Recompensas

### Actividades Realizadas

* Reorganización: `simulation/` → `plate_process/` y `step_1_base` → `plate_panel`.
* Pantalla `bonus_event` (participación voluntaria) y entrada "Ganar estrellas" en el menú.
* Minijuego "Atrapa frutas y verduras": canasta (`CharacterBody2D`), frutas y verduras con físicas (`RigidBody2D`), suelo y embudo (`StaticBody2D`), 5 spawners con Timer y parábola.
* Input Map con `move_left` / `move_right` y botones táctiles que presionan las mismas acciones.
* Señal `bonus_obtained` en el `EventBus`; `GlobalManager` guarda estrellas y aplica las reglas (`get_best_bonus`, `remove_bonus`).
* Pantalla `plate_summary` con aciertos por grupo, estrella aplicada y total; confirmar consume la estrella y reinicia el plato.

### Desafíos y Soluciones

* *Desafío:* Entregar recompensas sin acoplar el minijuego al resumen del plato.
* *Solución:* El minijuego solo emite `bonus_obtained`; `GlobalManager` administra y el resumen consulta.
* *Desafío:* Que el reto fuera alcanzable por niños.
* *Solución:* Meta de 8 frutas; se verificó con un bot automatizado que es ganable.

## [2026-10-03] - Laboratorio 6: Máquina de Estado Finito y Animaciones Programáticas

### Actividades Realizadas

* Minijuego anterior movido a `gamification/catch_food/`.
* Nuevo juego principal "Arma tu plato": el Plato saludable de la Familia Colombiana dibujado con sus 6 divisiones y 8 puestos de alimentos alrededor.
* FSM por alimento (`APARECIENDO`, `DISPONIBLE`, `ARRASTRANDO`, `UBICADO`, `RECHAZADO`) con transiciones validadas en `change_state()`.
* Animaciones `Tween` por transición (aparición, tomar, volver, servir en el plato, rechazo).
* Panel lateral: al acertar muestra la función del grupo, por qué es importante y el mensaje GABA; al fallar, una pista.
* Controlador con temporizador de 150 s, contador, panel de resultado y estrella por plato perfecto vía `EventBus`.
* `SceneContainer` con `mouse_filter = pass` e input `interact`.

### Desafíos y Soluciones

* *Desafío:* Al empezar una partida nueva algunos alimentos aparecían en la escena anterior, que seguía un fotograma en el árbol tras `queue_free()`.
* *Solución:* Buscar bandejas entre los hijos de la propia escena (`$Trays`) y filtrar spawners con `is_ancestor_of()`.
* *Desafío:* En el minijuego, las frutas laterales salían del embudo y no se podían atrapar.
* *Solución:* Rango de impulso exportado por spawner para lanzarlas siempre hacia adentro.
