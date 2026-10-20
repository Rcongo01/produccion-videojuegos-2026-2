# Convenciones de interfaz e iconografía (Guía 8, Paso 2.2)

Íconos dibujados para el proyecto (`src/assets/ui/icons/`, PNG blancos de 64 px). Se dibujan en blanco para que el **Theme** los tiña según el estado del botón (`icon_normal_color`, `icon_hover_color`, …): tinta oscura en los botones amarillos y blanco en los secundarios.

| Elemento | 1. Acción | 2. Convención | 3. Integración | 4. Qué aporta el texto | 5. ¿Solo ícono? |
|---|---|---|---|---|---|
| *Salir* (menú) | Cerrar el juego | **X** | Ícono a la izquierda del texto, botón secundario | "Salir" (no se confunde con cerrar una ventana) | No: en un menú la X podría leerse como "cerrar este panel" |
| Cerrar ayuda | Cerrar ventana | **X** | Botón cuadrado en la esquina superior derecha | — | **Sí** (convención universal) |
| *Volver* / *Salir* de la partida | Regresar | **Flecha ←** | Ícono + texto, estilo secundario | A dónde vuelve ("Volver al menú") | Sí en el HUD; con texto en paneles para niños pequeños |
| *Ajustes* | Configuración | **Engranaje** | Ícono + texto | "Ajustes" | Sí (se mantiene el texto porque los niños aún aprenden la convención) |
| *Armar mi plato* / *Jugar* | Iniciar | **Plato / ▶ Play** | Ícono grande a la izquierda | Qué se va a jugar | No: hay dos juegos distintos |
| *Borrar mi progreso* | Eliminar | **Papelera** | Ícono + texto + confirmación con doble toque | Qué se borra | No (acción destructiva, el texto evita errores) |
| *Confirmar plato* / *Continuar* | Confirmar | **✓** | Ícono + texto | Qué se confirma | No |
| *?* del HUD | Ayuda | **?** | Botón cuadrado junto al tiempo | Tooltip "¿Cómo se juega?" | **Sí** |
| *Créditos* | Información | **i** | Ícono + texto | "Créditos" | No (la *i* es genérica) |
| *Ganar estrellas* | Recompensa | **Estrella** | Ícono + texto | Qué se gana | No |
| *Mis grupos del plato* | Colección / álbum | **Libro** | Ícono + texto | Qué contiene | No |
| *Sonidos del juego* | Activar / silenciar | **Parlante / interruptor** | Interruptor verde (encendido) y gris (apagado) | Qué se activa | No |

**Criterio general:** el público son niños de primaria que todavía están aprendiendo a leer y a reconocer convenciones. Por eso casi todos los botones conservan **ícono + texto**; solo la **X** de una ventana y el **?** de ayuda funcionan sin texto.
