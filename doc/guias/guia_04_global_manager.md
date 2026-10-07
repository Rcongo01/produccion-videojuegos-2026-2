# Guía 4 · Gestión de Estado Global y Componentes de Navegación Reutilizables

**Etapa del proyecto:** `lab-4` · tag `lab-4-final`

## Qué pide la guía

Un `GlobalManager` (Autoload) que guarde el estado de una simulación (precios, cantidades y total) y se comunique con la interfaz solo por el `EventBus`; un componente `ButtonNav` configurable desde el Inspector; y un historial de navegación como pila.

## Cómo se aplicó a Mi Plato Saludable

La "caja registradora" de la guía se convirtió en la **primera versión jugable de la mecánica central**: se muestra un alimento y el niño elige a qué grupo del plato pertenece.

| Concepto de la guía | Aplicación en el juego |
|---|---|
| `prices` (Dictionary de datos) | `groups` (6 grupos con nombre, color oficial de la división, función, importancia y mensaje GABA), `foods` (34 alimentos → grupo correcto), `GABA_MESSAGES` (los 9 mensajes oficiales) y `points` (10 por acierto). |
| `selection` (estado) | `selection` guarda el alimento actual, aciertos, errores y aciertos por grupo. `round_deck` es el mazo de la ronda. |
| `base_selected` (reemplaza) | `next_food_requested` → el manager reemplaza el alimento actual y emite `food_changed`. |
| `item_added` (incrementa) | `food_placed(food_id, group_id)` → el manager evalúa e incrementa aciertos o errores. |
| `total_changed` | `score_changed(new_score)` + `placement_evaluated(food, group, correct)`. |
| `_update_total()` | `_update_score()`: aciertos × 10. |
| Interfaz reactiva `Step1Base` | Muestra el alimento (imagen + nombre), 6 botones con el **color de su división en el plato**, el puntaje y la información del grupo. |
| `ButtonNav` + `discard_previous` | Menú (*Iniciar juego*, *Configuración*, *Créditos*) y todos los "Volver" usan `ButtonNav`. Al volver se hace `pop_back()` del historial. |
| Eliminar scripts que solo conectaban señales | `credits_panel.gd` se eliminó. `config_panel.gd` se conserva solo para la opción de pistas, que ahora vive en `GlobalManager.settings`. |

### Lo que el niño ve al jugar

* **Acierto:** "¡Muy bien! Leche es del grupo «Leche y productos lácteos»", la función del grupo, por qué es importante y el **mensaje de las Guías Alimentarias** asociado (por ejemplo, el mensaje 2 sobre músculos, huesos y dientes).
* **Error:** "¡Casi!" y, si la opción de pistas está activa, una pista con la función del grupo correcto. El alimento vuelve al mazo.
* **Ronda completa:** mensaje 1 de las GABA (alimentos frescos y variados).

### Decisión de diseño: las rondas imitan las proporciones del plato

Cada ronda trae 12 alimentos: 3 de cereales/tubérculos, 3 de frutas y verduras, 2 lácteos, 2 de carnes/huevos/leguminosas, 1 grasa y 1 azúcar. Así el juego refuerza que las grasas y los azúcares son las porciones más pequeñas.

## Verificación realizada

Equivalentes a las pruebas 1-4 de la guía: puntaje inicial 0; un error no suma y queda contado; ronda completa = 120 puntos con la composición 3-3-2-2-1-1; el historial hace `append` al entrar y `pop_back` al volver; el puntaje persiste al salir y volver a entrar. 11/11 pruebas superadas.

## Recursos agregados

`src/assets/foods/*.png`: íconos generados a partir de Noto Color Emoji (licencia SIL OFL 1.1).
