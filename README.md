<div align="center">

<img src="doc/img/logo.png" width="130" alt="Logo: plato con las 6 divisiones">

# 🍽️ Mi Plato Saludable

### Producción de Videojuegos – Sistemas Interactivos 2026

**Universidad Antonio Nariño (UAN)**<br>
Facultad de Ingeniería de Sistemas y Computación

![Godot](https://img.shields.io/badge/Godot-4.7-478CBF?logo=godotengine&logoColor=white) ![GDScript](https://img.shields.io/badge/GDScript-2.0%20tipado-355570) ![Renderer](https://img.shields.io/badge/Renderer-Compatibility-2e7d32) ![Avance](https://img.shields.io/badge/Avance-Gu%C3%ADa%209%20de%209-f2c14e) ![Web](https://img.shields.io/badge/Exportaci%C3%B3n-Web%20HTML5-e44d26?logo=html5&logoColor=white)

</div>

---

## 📝 Descripción del Proyecto

**Mi Plato Saludable** es un juego educativo para niños, desarrollado en **Godot Engine**, que enseña el **Plato saludable de la Familia Colombiana** de las Guías Alimentarias Basadas en Alimentos (GABA) del ICBF.

El plato aparece en el centro con sus **6 grupos de alimentos** y los alimentos alrededor. El niño ubica cada alimento en su grupo: si acierta, el juego le explica **para qué sirve ese grupo**, **por qué es importante** en la alimentación y le muestra **uno de los mensajes oficiales de las Guías Alimentarias**.

Este repositorio es el proyecto integrador del semestre 2026-2: el juego crece guía tras guía siguiendo buenas prácticas de ingeniería de software.

![Mi Plato Saludable](doc/img/lonchera.jpg)

## 🎮 Cómo se juega

- **Armar mi plato**: **arrastra** cada alimento hasta su división del plato. La primera vez, una **mano guía** te muestra cómo. Toca **?** para la ayuda.
- **Lonchera Express**: llegan 4 niños con un pedido y poco tiempo. Toca un compartimento (bebida, fruta, plato principal o snack) y elige un alimento de la lista. ¡Ojo con los ultraprocesados y sus sellos negros!
- Cada lonchera gana de 1 a 3 estrellas: por entregarla, por cumplir el pedido y por ser completa y sin ultraprocesados. Entregar rápido da puntos extra.
- **Ganar estrellas: Atrapa lo saludable**: atrapa frutas y verduras y esquiva gaseosas y ultraprocesados (3 vidas). Las estrellas suman puntos al plato o a la lonchera.
- **Mis grupos del plato**: álbum de los grupos descubiertos. **Ajustes**: pistas y sonidos. Tu progreso y tus récords se guardan solos.

## 🥗 Los 6 grupos del plato

| Grupo | Color | Para qué sirve |
|---|:---:|---|
| Cereales, raíces, tubérculos y plátanos | 🟨 | Energía para el cuerpo y el cerebro |
| Frutas y verduras | 🟩 | Vitaminas, minerales y fibra |
| Leche y productos lácteos | 🟦 | Calcio y proteína para huesos y dientes |
| Carnes, huevos, leguminosas, frutos secos y semillas | 🟥 | Proteína, hierro y zinc |
| Grasas | 🩷 | Energía concentrada; en poca cantidad |
| Azúcares | 🟪 | Energía rápida; la porción más pequeña |

## 🗺️ Avance por guías de laboratorio

| Guía | Tema | Qué se agregó al juego | Estado |
|:---:|---|---|:---:|
| 1 | Entorno y arquitectura base | Proyecto inicial, estructura `src/` y primer menú. | ✅ |
| 2 | Escenas, nodos y co-localización | Menú y pantalla para conocer los 6 grupos del plato con `.bind()`. | ✅ |
| 3 | Navegación desacoplada (Event Bus) | `EventBus`, orquestador `MainApp`, Configuración y Créditos. | ✅ |
| 4 | Estado global y ButtonNav | `GlobalManager` con los datos del plato; primera versión jugable por botones. | ✅ |
| 5 | Entrada, movimiento y mecánicas | Minijuego *Atrapa frutas y verduras* y estrellas de bonificación. | ✅ |
| 6 | Máquinas de estado y Tweens | El plato interactivo: arrastrar cada alimento a su grupo. | ✅ |
| 7 | Vertical Slice, persistencia y Web | Progreso guardado, diseño final, álbum de grupos y versión Web. | ✅ |
| 8 | Evaluación y mejora de UX | Prueba de uso, Theme con estados, íconos, menú con la mascota Nutri, ayuda, mano guía, sonidos y popup de confirmación. | ✅ |
| 9 | Interfaz dinámica con Resources | *Lonchera Express*: alimentos y pedidos como `Resource`, lista generada por código, lonchera de 4 compartimentos y minijuego *Atrapa lo saludable*. | ✅ |

Cada guía se desarrolla en su propia rama `lab-N`, se fusiona en `main` y se marca con la etiqueta `lab-N-final`.

## 🏗️ Arquitectura

- Cada pantalla vive en su carpeta con su escena `.tscn` y su script `.gd` (co-localización).
- Señales conectadas por código con `@onready` + `.connect()` y un callback reutilizado con `.bind()`.
- **`EventBus`** (Autoload): señales globales; las pantallas solo emiten intenciones (patrón Observer).
- **`MainApp`**: única escena principal; instancia y libera pantallas dentro de `SceneContainer`.
- **`GlobalManager`** (Autoload): datos del plato (grupos, alimentos, mensajes GABA) y estado de la ronda.
- **`ButtonNav`**: botón de navegación reutilizable configurado desde el Inspector; historial como pila.
- El minijuego es un módulo independiente: publica `bonus_obtained` y `GlobalManager` aplica las reglas de las estrellas.
- Entrada por acciones del Input Map (`move_left`, `move_right`), no por teclas fijas.
- Cada alimento tiene una **máquina de estados finita**: `APARECIENDO → DISPONIBLE → ARRASTRANDO → UBICADO / RECHAZADO`.
- Animaciones con **Tween** elegidas según la transición (estado anterior → actual).
- **Persistencia** en `user://save_data.json` (IndexedDB en Web): estrellas, récord, grupos descubiertos y preferencias.
- **Tema global** (`plato_theme.tres`) para una apariencia consistente en todas las pantallas.
- **`ui_theme.tres`** reemplaza al tema anterior: estados Normal / Hover / Pressed / Disabled y variaciones `SecondaryButton` y `Popup*`.
- **`AudioManager`** (Autoload): reproduce los sonidos que se piden por el `EventBus`; se puede apagar en Ajustes.
- Cada alimento emite `state_changed`; el controlador de la partida muestra **instrucciones progresivas** según el estado.
- **`IngredientData`** (`Resource`): cada alimento de la lonchera es un archivo `.tres` con nombre, textura, puntos, compartimento, sellos y consejo.
- **`IngredientDatabase`** y **`OrderDatabase`**: catálogos de 31 alimentos y 9 pedidos; agregar uno nuevo es crear un `.tres`, sin tocar código.
- La lista de botones y la lonchera se **generan desde los datos**; `EventBus.ingredient_selected` y `lunchbox_total_changed` comunican la elección.

## 📁 Estructura de Directorios del Repositorio

```
src/
├── assets/
│   ├── audio/
│   ├── fonts/
│   ├── foods/
│   └── ui/
│       ├── icons/
│       └── seals/
├── components/
│   └── navigation/
├── core/
├── data/
│   ├── ingredients/
│   └── orders/
└── scenes/
    ├── album/
    ├── config/
    ├── credits/
    ├── gamification/
    │   └── catch_food/
    ├── main/
    └── plate_process/
        ├── assets/
        └── plate_game/
doc/
├── adr/      Registros de decisiones de arquitectura (ADR)
├── guias/    Qué se aplicó de cada guía
├── ux/       Prueba de uso, análisis de interacciones e iconografía
└── img/      Capturas para este README
DEVLOG.md     Bitácora de desarrollo
```

Todos los archivos y carpetas usan `snake_case`, y cada escena vive junto a su script.

## ⚙️ Tecnologías Utilizadas

- **Engine:** Godot Engine 4.7 (renderizador *Compatibility* para portabilidad web)
- **Lenguaje:** GDScript 2.0 (tipado estricto)
- **Versionamiento:** Git / GitHub con ramas por guía y Conventional Commits
- **Documentación:** ADR + DEVLOG

## 🌐 Versión Web

El preset **Web** ya está configurado en `export_presets.cfg` (sin hilos y sin cabeceras de aislamiento).

1. En Godot: **Proyecto → Exportar… → Web → Exportar Proyecto** (desactiva *Exportar con depuración*).
2. La exportación queda en `build/web/index.html` (la carpeta `build/` está excluida de Git).

## ▶️ Cómo abrir el proyecto

1. Instala **Godot Engine 4.7** (versión *Standard*).
2. Clona el repositorio:
   ```bash
   git clone https://github.com/Rcongo01/produccion-videojuegos-2026-2.git
   ```
3. En el **Project Manager** de Godot: **Importar** → selecciona `project.godot` → **Importar y Editar**.
4. Presiona **F5** para jugar.

Para ver el proyecto tal como quedó al terminar una guía: `git checkout lab-N-final`.

## 🏷️ Versiones

`lab-1` · `lab-2` · `lab-2-final` · `lab-3-final` · `lab-4-final` · `lab-5-final` · `lab-6-final` · `lab-7-final` · `lab-8-final` · `lab-9-final`

## 📚 Documentación

- [`DEVLOG.md`](DEVLOG.md): bitácora de desarrollo, una entrada por guía.
- [`doc/guias/guia_02_colocalizacion.md`](doc/guias/guia_02_colocalizacion.md): qué pide la Guía 2 y cómo se aplicó al juego.
- [`doc/guias/guia_03_event_bus.md`](doc/guias/guia_03_event_bus.md): qué pide la Guía 3 y cómo se aplicó al juego.
- [`doc/guias/guia_04_global_manager.md`](doc/guias/guia_04_global_manager.md): qué pide la Guía 4 y cómo se aplicó al juego.
- [`doc/guias/guia_05_entrada_mecanicas.md`](doc/guias/guia_05_entrada_mecanicas.md): qué pide la Guía 5 y cómo se aplicó al juego.
- [`doc/guias/guia_06_fsm_tweens.md`](doc/guias/guia_06_fsm_tweens.md): qué pide la Guía 6 y cómo se aplicó al juego.
- [`doc/guias/guia_07_vertical_slice.md`](doc/guias/guia_07_vertical_slice.md): qué pide la Guía 7 y cómo se aplicó al juego.
- [`doc/guias/guia_08_ux.md`](doc/guias/guia_08_ux.md): qué pide la Guía 8 y cómo se aplicó al juego.
- [`doc/guias/guia_09_resources.md`](doc/guias/guia_09_resources.md): qué pide la Guía 9 y cómo se aplicó al juego.
- [`doc/ux/`](doc/ux/): prueba de uso, análisis Situación / Mejora / Resultado e iconografía (Guía 8).
- Decisiones de arquitectura: [ADR-001](doc/adr/ADR-001-colocalizacion.md), [ADR-002](doc/adr/ADR-002-event-bus-navegacion.md), [ADR-003](doc/adr/ADR-003-global-manager-button-nav.md), [ADR-004](doc/adr/ADR-004-gamificacion-recompensas.md), [ADR-005](doc/adr/ADR-005-fsm-animaciones.md), [ADR-006](doc/adr/ADR-006-theme-ux.md), [ADR-007](doc/adr/ADR-007-resources-interfaz-dinamica.md).

## 📜 Créditos y licencias

- Contenido educativo: *Guías Alimentarias Basadas en Alimentos para la población colombiana mayor de 2 años* (ICBF – FAO) y su **Plato saludable de la Familia Colombiana**.
- Íconos de alimentos: generados a partir de **Noto Color Emoji** (SIL Open Font License 1.1).
- Tipografía: **Fredoka** (SIL Open Font License 1.1), licencia en `src/assets/fonts/OFL_Fredoka.txt`.
- Fondo, logo, suelo y paredes: creados para este proyecto.
- Íconos de interfaz, mascota Nutri, fondo del menú y efectos de sonido: creados para este proyecto.
- Sellos de advertencia: dibujados para el proyecto a partir del etiquetado frontal de advertencia que se usa en Colombia.

## 🖼️ Galería

| | |
|:---:|:---:|
| ![Menú con Lonchera Express](doc/img/menu.jpg)<br>*Menú con Lonchera Express* | ![Lonchera Express: pedido con tiempo y 4 compartimentos](doc/img/lonchera.jpg)<br>*Lonchera Express: pedido con tiempo y 4 compartimentos* |
| ![Calificación del pedido (1 a 3 estrellas)](doc/img/lonchera_resultado.jpg)<br>*Calificación del pedido (1 a 3 estrellas)* | ![Resultados de la ronda](doc/img/lonchera_resumen.jpg)<br>*Resultados de la ronda* |
| ![Atrapa lo saludable: esquiva los ultraprocesados](doc/img/minijuego.jpg)<br>*Atrapa lo saludable: esquiva los ultraprocesados* | ![¡Ronda terminada!](doc/img/popup_lonchera.jpg)<br>*¡Ronda terminada!* |
| ![Plato: acierto con +10 y racha](doc/img/plato.jpg)<br>*Plato: acierto con +10 y racha* | ![Mano guía e instrucciones progresivas](doc/img/plato_guia.jpg)<br>*Mano guía e instrucciones progresivas* |

## 👨‍💻 Autor

- **Nombre:** Ronaldo Congo Cancelado
- **Código Estudiantil:** 12242622951
- **Programa:** Ingeniería de Software
- **Repositorio:** [Rcongo01/produccion-videojuegos-2026-2](https://github.com/Rcongo01/produccion-videojuegos-2026-2)
