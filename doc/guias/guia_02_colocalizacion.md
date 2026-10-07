# Guía 2 · Escenas, Nodos, Co-localización y Refactorización

**Etapa del proyecto:** `lab-2` · tag `lab-2-final`

## Qué pide la guía

Pasar de una estructura plana a una co-localizada, conectar señales por código con `@onready` + `.connect()`, reutilizar callbacks con `.bind()`, componer interfaces con contenedores y documentar con ADR y DEVLOG.

## Cómo se aplicó a Mi Plato Saludable

| Concepto de la guía | Aplicación en el juego |
|---|---|
| Co-localización (`src/scenes/main`, `src/scenes/simulation`) | `menu_panel.tscn/.gd` es el menú del juego; `step_1_base.tscn/.gd` es la primera pantalla educativa: **conoce los grupos del plato**. |
| `VBoxContainer` en el menú | Menú con *Iniciar juego*, *Créditos* y *Cerrar aplicación*. |
| `GridContainer` (2 columnas) | Los **6 grupos del Plato saludable de la Familia Colombiana** como botones: cereales/raíces/tubérculos/plátanos, frutas y verduras, lácteos, carnes/huevos/leguminosas, grasas y azúcares. |
| `.bind()` con parámetros | Los 6 botones usan el mismo callback `_on_grupo_selected(nombre_grupo, funcion)`. En vez de "base + costo" de la guía, se envía el nombre del grupo y para qué sirve en el cuerpo. |
| `LblStatusLocal` | Muestra la función del grupo elegido (por ejemplo: lácteos → calcio para huesos y dientes). |
| Experimento "Pop-up de créditos" | `PanelCreditos` se muestra y oculta con señales programáticas. |
| ADR + DEVLOG | `doc/ADR-001-colocalizacion.md` y `DEVLOG.md`. |

## Estructura resultante

```
src/scenes/main/menu_panel.tscn + menu_panel.gd
src/scenes/simulation/step_1_base.tscn + step_1_base.gd
doc/ADR-001-colocalizacion.md
DEVLOG.md
```

## Cómo probarlo

1. Abrir `project.godot` en Godot 4.7 y presionar F5.
2. *Iniciar juego* → tocar cada grupo y leer su función.
3. *Volver al menú* (todavía usa `change_scene_to_file`, deuda técnica que resuelve la Guía 3).

## Nota

No se recibió la Guía 1; esta etapa reconstruye su punto de partida (menú + escena de simulación) y aplica directamente la refactorización de la Guía 2.
