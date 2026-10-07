# Registro de Decisión de Arquitectura (ADR)

## ADR-005: Máquina de Estado Finito y Animaciones Programáticas

* **Estado:** Aprobado
* **Fecha:** 2026-10-03
* **Autor:** Ronaldo Congo Cancelado

### Contexto

La mecánica central del juego es **arrastrar cada alimento hasta su grupo en el Plato saludable de la Familia Colombiana**. Un alimento pasa por situaciones muy distintas (aparece, espera, se arrastra, queda servido, es rechazado) y la misma entrada (clic/toque) significa cosas diferentes según la situación. Resolverlo con condicionales sueltos haría el código frágil y difícil de extender. Varios alimentos conviven en pantalla, cada uno en una situación distinta.

### Decisión

* Modelar cada alimento (`food_item.tscn`, `CharacterBody2D` con `input_pickable`) con una **FSM**: `APARECIENDO → DISPONIBLE → ARRASTRANDO → {UBICADO | RECHAZADO → DISPONIBLE | DISPONIBLE}`.
* `change_state()` centraliza y valida las transiciones con `match`; guarda `previous_state`.
* Un único `Timer` por alimento sirve para la aparición y para el tiempo de rechazo, porque un alimento solo está en un estado a la vez.
* Las animaciones con `Tween` se eligen según el par `previous_state → current_state` (`play_transition_animation`), de modo que responden a la transición y no solo al estado final.
* Las divisiones del plato (`plate_sector.tscn`, `Area2D` en el grupo `plate_sector`) solo reaccionan visualmente (`activate`, `reject`, resaltado al pasar por encima); la regla de si un alimento pertenece a un grupo sigue en `GlobalManager.is_correct()`.
* El plato se dibuja a partir de los datos (`color`, `plate_share`, `label`) del `GlobalManager`.
* El controlador de la partida (`plate_game_main.gd`) solo maneja el progreso global (alimentos ubicados, tiempo, victoria/derrota) y escucha `placement_evaluated` del `EventBus`.
* `SceneContainer` de `MainApp` cambia `mouse_filter` a *pass* para que el clic llegue a los cuerpos físicos.

### Consecuencias

* **Positivas:**
  * El comportamiento depende explícitamente del estado; un alimento no puede hacer acciones incompatibles (por ejemplo, saltar de DISPONIBLE a UBICADO).
  * Agregar un estado nuevo (por ejemplo, un alimento "envuelto" que hay que tocar para abrir) solo modifica `change_state`, su `process_*` y su animación.
  * Las animaciones dan retroalimentación inmediata y clara a los niños.
  * La escena del alimento se reutiliza para los 34 alimentos.
* **Negativas / Costos:**
  * Más código estructural que una solución con condicionales.
  * Las animaciones deben coordinarse con las transiciones para no dejar estados visuales a medias.
  * Durante un fotograma la escena anterior sigue en el árbol tras `queue_free()`; buscar nodos con `get_nodes_in_group()` puede devolver nodos de la escena vieja. Se resolvió usando los hijos de la propia escena (`$Trays`) o filtrando con `is_ancestor_of()`.
