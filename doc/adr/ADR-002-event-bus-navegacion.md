# Registro de Decisión de Arquitectura (ADR)

## ADR-002: Adopción de Event Bus para la Navegación Desacoplada

* **Estado:** Aprobado
* **Fecha:** 2026-10-03
* **Autor:** Ronaldo Congo Cancelado

### Contexto

En el Laboratorio 2 el juego quedó co-localizado y con señales por código, pero el menú y la pantalla de grupos del plato seguían llamando directamente a `change_scene_to_file()`. Cada pantalla conocía la ruta de la otra; el juego tendrá más pantallas (configuración, créditos, plato interactivo, minijuegos) y esa dependencia se multiplicaría.

### Decisión

Adoptar un **Event Bus** (`Autoload` llamado `EventBus`) con las señales `navigation_requested` y `parameter_changed`. Un controlador central, `MainApp`, escucha las solicitudes, libera la pantalla actual e instancia la nueva dentro de `SceneContainer`. `MainApp` es ahora la escena principal del proyecto y mantiene un fondo persistente (`Fondo`) que no se destruye al navegar.

### Consecuencias

* **Positivas:**
  * Las pantallas no se conocen entre sí; solo expresan intenciones.
  * La navegación queda centralizada en un único punto.
  * Configuración y Créditos se agregaron sin tocar la lógica de navegación.
  * Elementos persistentes (fondo) sobreviven al cambio de pantalla.
* **Negativas / Costos:**
  * Capa adicional de comunicación indirecta, más difícil de rastrear al depurar.
  * Las rutas de escena siguen escritas en los emisores; mover una escena exige actualizarlas.
