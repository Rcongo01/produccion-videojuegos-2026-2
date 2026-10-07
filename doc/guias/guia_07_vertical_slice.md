# Guía 7 · Vertical Slice, Persistencia y Publicación Web

**Etapa del proyecto:** `lab-7` · tag `lab-7-final` (avance final del proyecto)

## Qué pide la guía

1. Persistir los cupones con `FileAccess` + JSON en `user://`, distinguiendo estado temporal y persistente.
2. Recorrer el flujo completo y refinar la interfaz: distribución, legibilidad y consistencia (opcional: Themes). Retos: fondo e HUD.
3. Exportar para Web (preset Web, sin depuración, sin cabeceras de aislamiento de origen) y probar en el navegador, incluida la persistencia.
4. Publicar en itch.io como juego HTML (ZIP con `index.html`).

## Cómo se aplicó a Mi Plato Saludable

### 1. Persistencia

| Estado | Contenido | ¿Se guarda? |
|---|---|---|
| Temporal (sesión de juego) | Ronda en curso: `selection`, `round_deck`, `current_score` | No |
| Persistente (progreso del niño) | `bonuses` (estrellas), `best_score` (récord), `groups_learned` (grupos descubiertos), `settings` (pistas) | Sí, en `user://save_data.json` |

* `save_progress()` se llama al obtener o consumir una estrella, al descubrir un grupo, al batir el récord y al cambiar la opción de pistas.
* `load_progress()` se llama en el `_ready()` del `GlobalManager`.
* **Dos correcciones respecto al código de la guía**:
  * `JSON.parse_string` devuelve los enteros como `float`; se normalizan con `int()` al cargar.
  * Asignar el `Array` genérico del JSON a un `Array[Dictionary]` tipado falla en ejecución; se usa `assign()` o se reconstruye validando cada elemento.
* En Web, `user://` se guarda en IndexedDB del navegador.

### 2. Refinamiento y Vertical Slice

* **Tema global** (`src/core/theme/plato_theme.tres`, configurado en *Project Settings → GUI → Theme*): tipografía redondeada **Fredoka** (OFL, guardada como recurso nativo `fredoka.res` para que cargue desde la primera apertura), botones amarillos con relieve, tarjetas oscuras con bordes redondeados y sombra.
* **Fondo** (reto 1): fondo persistente en `MainApp` con siluetas de alimentos.
* **Menú rediseñado** con el logo del plato, botones jerarquizados y estadísticas del progreso guardado (récord, estrellas, grupos descubiertos). *Salir* se oculta en Web porque un navegador no permite cerrar la página desde el juego.
* **Nueva pantalla "Mis grupos del plato"**: álbum de los 6 grupos; los descubiertos muestran su función y su mensaje GABA, los demás aparecen bloqueados para motivar a seguir jugando.
* **Configuración**: opción de pistas (persistente) y *Borrar mi progreso guardado* con doble toque de confirmación, pensado para dispositivos compartidos en el aula.
* **Pantallas secundarias** (estrellas, resumen, créditos, configuración) dentro de tarjetas con el mismo estilo.
* **HUD** (reto 2): en el plato interactivo, al terminar se ocultan el HUD y el panel de información para que el resultado se lea sin interferencias.
* **Créditos** con las licencias de íconos y tipografía.
* Se revisaron los caracteres usados contra la tipografía: "→" y "◀ ▶" no existen en Fredoka; se reemplazaron por texto y por íconos de flecha dibujados.

### 3. Exportación Web

`export_presets.cfg` con el preset **Web**:

* `export_path = build/web/index.html`
* `variant/thread_support = false` (no requiere `SharedArrayBuffer`; compatible con itch.io)
* `progressive_web_app/ensure_cross_origin_isolation_headers = false` (cabeceras de aislamiento desactivadas, como pide la guía)
* Exportación en modo release (sin depuración).

Se usa la plantilla oficial `web_nothreads_release` de Godot 4.7.2 (*Editor → Administrar plantillas de exportación → Descargar*).

### 4. Publicación en itch.io

El ZIP de la build (contenido de `build/web/`) contiene `index.html` en la raíz junto con `index.js`, `index.wasm`, `index.pck` y los íconos, listo para subir:

1. itch.io → *Create new project*. Título: `Producción de Videojuegos, 2026-II, Ronaldo Congo Cancelado, Vertical Slice 1`.
2. *Kind of project*: **HTML**.
3. Subir el ZIP y marcar *This file will be played in the browser*.
4. Tamaño del área de juego: 1280 × 720 (activar el botón de pantalla completa).
5. Visibilidad: *Draft*; copiar la URL secreta y probarla en una ventana de incógnito sin sesión iniciada.
6. Pegar la URL en `DEVLOG.md` (sección *Publicación*).

## Verificación realizada

* **Escritorio, tres ejecuciones separadas** (simulan cerrar y reabrir el juego): navegación a las 5 pantallas del menú; álbum con 6 tarjetas; récord y grupos guardados; tras reabrir se recuperan estrella (como entero), récord, grupos y preferencia, pero **no** la ronda; la estrella cargada se aplica en el resumen (120 + 30 = 150) y se consume; tras reabrir sigue consumida; borrar progreso funciona. 22/22.
* **Build Web en Chromium**: el juego carga (WebGL 2), un alimento arrastrado con el mouse se ubicó y mostró el panel del grupo; tras cerrar y reabrir el navegador con el mismo perfil se conservaron la preferencia de pistas y "Grupos descubiertos: 2 / 6" (IndexedDB), y *Salir* aparece oculto.
* Regresión de las Guías 5 y 6 sobre la versión final: superadas.

La publicación en itch.io requiere la cuenta del estudiante, así que queda como último paso manual.
