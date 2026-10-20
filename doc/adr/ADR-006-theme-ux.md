# Registro de Decisión de Arquitectura (ADR)

## ADR-006: Theme como sistema de estilos y retroalimentación desacoplada (UX)

* **Estado:** Aprobado
* **Fecha:** 2026-10-16
* **Autor:** Ronaldo Congo Cancelado

### Contexto

La prueba de uso del Lab 8 mostró que el juego funcionaba pero comunicaba poco: botones que se veían iguales, acciones sin respuesta visual o sonora y ninguna instrucción dentro de la partida. Corregirlo botón por botón y escena por escena habría repetido estilos y mezclado la lógica del juego con efectos visuales y sonidos.

### Decisión

* **Un único Theme** (`src/assets/ui/ui_theme.tres`), asignado en *Project Settings → GUI → Theme* y en el nodo raíz de cada escena de interfaz. Define la fuente, los `StyleBoxFlat` de `Button` en los estados **Normal, Hover, Pressed, Disabled** (y Focus) y variaciones de tipo (`theme_type_variation`) para los casos particulares: `SecondaryButton`, `PopupOverlay`, `PopupCard`, `PopupTitle`, `PopupText`. Reemplaza al `plato_theme.tres` del Lab 7.
* **Íconos blancos teñidos por el Theme**: un mismo PNG sirve en botones claros y oscuros.
* **`AudioManager` como Autoload** con un grupo de `AudioStreamPlayer`. Escucha el `EventBus` (`sound_requested`, `placement_evaluated`, `bonus_obtained`) y respeta `settings.sound_enabled`. Ninguna escena crea reproductores propios.
* **Instrucciones progresivas a partir de la FSM**: cada alimento emite `state_changed(food, from, to)`; el controlador de la partida decide el texto de la `HintBar`. La FSM no conoce la interfaz.
* **Popups dentro de la escena** (Panel oculto con `PopupOverlay`, se muestra por código), tal como pide la guía con `PurchaseSuccessPopup`.

### Consecuencias

* **Positivas:**
  * Cambiar el aspecto de todos los botones es editar un solo recurso.
  * Los estados del botón dan retroalimentación inmediata sin código.
  * Los sonidos se pueden apagar o cambiar desde un solo lugar.
  * La FSM del Lab 6 no cambió de responsabilidad; solo emite una señal más.
* **Negativas / Costos:**
  * La herencia del Theme obliga a revisar contrastes: un ícono oscuro en un botón secundario oscuro no se veía (se resolvió con íconos blancos y colores por estado).
  * Un `TextureRect` de fondo puede tapar el fondo de `MainApp` o bloquear clics: se usa `z_index` negativo y `mouse_filter = Ignore`.
