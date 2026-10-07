<div align="center">

<img src="doc/img/logo.png" width="130" alt="Logo: plato con las 6 divisiones">

# 🍽️ Mi Plato Saludable

### Producción de Videojuegos – Sistemas Interactivos 2026

**Universidad Antonio Nariño (UAN)**<br>
Facultad de Ingeniería de Sistemas y Computación

![Godot](https://img.shields.io/badge/Godot-4.7-478CBF?logo=godotengine&logoColor=white) ![GDScript](https://img.shields.io/badge/GDScript-2.0%20tipado-355570) ![Renderer](https://img.shields.io/badge/Renderer-Compatibility-2e7d32) ![Avance](https://img.shields.io/badge/Avance-Gu%C3%ADa%202%20de%207-f2c14e)

</div>

---

## 📝 Descripción del Proyecto

**Mi Plato Saludable** es un juego educativo para niños, desarrollado en **Godot Engine**, que enseña el **Plato saludable de la Familia Colombiana** de las Guías Alimentarias Basadas en Alimentos (GABA) del ICBF.

El plato aparece en el centro con sus **6 grupos de alimentos** y los alimentos alrededor. El niño ubica cada alimento en su grupo: si acierta, el juego le explica **para qué sirve ese grupo**, **por qué es importante** en la alimentación y le muestra **uno de los mensajes oficiales de las Guías Alimentarias**.

Este repositorio es el proyecto integrador del semestre 2026-2: el juego crece guía tras guía siguiendo buenas prácticas de ingeniería de software.

![Pantalla para conocer los grupos del plato](doc/img/guia_2.jpg)

<sub>Pantalla para conocer los grupos del plato · estado al cerrar la Guía 2</sub>

## 🎮 Cómo se juega

- Pulsa **Iniciar juego** y toca cada uno de los 6 grupos para leer para qué sirve.

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
| 3 | Navegación desacoplada (Event Bus) | `EventBus`, orquestador `MainApp`, Configuración y Créditos. | ⏳ |
| 4 | Estado global y ButtonNav | `GlobalManager` con los datos del plato; primera versión jugable por botones. | ⏳ |
| 5 | Entrada, movimiento y mecánicas | Minijuego *Atrapa frutas y verduras* y estrellas de bonificación. | ⏳ |
| 6 | Máquinas de estado y Tweens | El plato interactivo: arrastrar cada alimento a su grupo. | ⏳ |
| 7 | Vertical Slice, persistencia y Web | Progreso guardado, diseño final, álbum de grupos y versión Web. | ⏳ |

Cada guía se desarrolla en su propia rama `lab-N`, se fusiona en `main` y se marca con la etiqueta `lab-N-final`.

## 🏗️ Arquitectura

- Cada pantalla vive en su carpeta con su escena `.tscn` y su script `.gd` (co-localización).
- Señales conectadas por código con `@onready` + `.connect()` y un callback reutilizado con `.bind()`.

## 📁 Estructura de Directorios del Repositorio

```
src/
└── scenes/
    ├── main/
    └── simulation/
doc/
├── ADR-001-colocalizacion.md
├── guias/    Qué se aplicó de cada guía
└── img/      Capturas para este README
DEVLOG.md     Bitácora de desarrollo
```

Todos los archivos y carpetas usan `snake_case`, y cada escena vive junto a su script.

## ⚙️ Tecnologías Utilizadas

- **Engine:** Godot Engine 4.7 (renderizador *Compatibility* para portabilidad web)
- **Lenguaje:** GDScript 2.0 (tipado estricto)
- **Versionamiento:** Git / GitHub con ramas por guía y Conventional Commits
- **Documentación:** ADR + DEVLOG

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

`lab-1` · `lab-2` · `lab-2-final`

## 📚 Documentación

- [`DEVLOG.md`](DEVLOG.md): bitácora de desarrollo, una entrada por guía.
- [`doc/guias/guia_02_colocalizacion.md`](doc/guias/guia_02_colocalizacion.md): qué pide la Guía 2 y cómo se aplicó al juego.
- Decisiones de arquitectura: [ADR-001](doc/ADR-001-colocalizacion.md).

## 📜 Créditos y licencias

- Contenido educativo: *Guías Alimentarias Basadas en Alimentos para la población colombiana mayor de 2 años* (ICBF – FAO) y su **Plato saludable de la Familia Colombiana**.

## 👨‍💻 Autor

- **Nombre:** Ronaldo Congo Cancelado
- **Código Estudiantil:** 12242622951
- **Programa:** Ingeniería de Software
- **Repositorio:** [Rcongo01/produccion-videojuegos-2026-2](https://github.com/Rcongo01/produccion-videojuegos-2026-2)
