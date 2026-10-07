# Guía 3 · Arquitectura de Navegación Desacoplada (Event Bus)

**Etapa del proyecto:** `lab-3` · tag `lab-3-final`

## Qué pide la guía

Crear un Event Bus global (patrón Observer + Autoload), un orquestador `MainApp` con `SceneContainer` que instancie las pantallas, rediseñar el menú para que solo emita señales, crear los paneles de Configuración y Créditos, y documentar con ADR-002.

## Cómo se aplicó a Mi Plato Saludable

| Concepto de la guía | Aplicación en el juego |
|---|---|
| `src/core/event_bus.gd` (Autoload `EventBus`) | Señales `navigation_requested(target_scene_path)` y `parameter_changed(param_name, value)`. |
| `MainApp` (Node) + `SceneContainer` (Control, Full Rect) | Orquestador y escena principal del juego. Se agregó un `ColorRect` **Fondo** verde que persiste mientras cambian las pantallas (el caso de uso que la guía menciona en su análisis). |
| Menú con lambdas que emiten al bus | 4 botones: *Iniciar juego*, *Configuración*, *Créditos*, *Cerrar aplicación*. Ninguno conoce las escenas de destino. |
| Paneles de Configuración y Créditos | **Configuración:** opción *Mostrar pistas al equivocarme* que emite `parameter_changed("show_hints", valor)` (se usará en el plato interactivo). **Créditos:** autor y fuente del contenido (GABA, ICBF-FAO). |
| Pantalla de simulación desacoplada | La pantalla de grupos del plato vuelve al menú mediante `EventBus.navigation_requested`. |
| ADR-002 y DEVLOG | `doc/adr/ADR-002-event-bus-navegacion.md`; entrada nueva en `DEVLOG.md`. Los ADR se mueven a `doc/adr/` como indica la guía. |

## Flujo

```
Botón → EventBus.navigation_requested(ruta) → MainApp → libera escena actual → instancia nueva en SceneContainer
```

## Verificación realizada

Prueba automatizada (Godot 4.7 headless): menú → grupos → info de lácteos por `bind` → volver → configuración (emite `show_hints`) → créditos; se comprobó que nunca quedan dos pantallas en `SceneContainer`. Resultado: 7/7 pruebas superadas.
