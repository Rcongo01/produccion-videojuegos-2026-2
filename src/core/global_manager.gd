# res://src/core/global_manager.gd
# Lab 4: estado global del juego (Autoload "GlobalManager").
# Administra los datos del Plato saludable de la Familia Colombiana, la ronda actual y el puntaje.
# No conoce la interfaz: recibe eventos del EventBus, modifica el estado y emite resultados.
extends Node

# --- Datos (equivalente a "prices" de la guía) ------------------------------------------

# Mensajes oficiales de las Guías Alimentarias Basadas en Alimentos (GABA) para la
# población colombiana mayor de 2 años (ICBF - FAO), versión final validada en campo.
const GABA_MESSAGES: Array[String] = [
	"Consuma alimentos frescos y variados como lo indica el Plato saludable de la Familia Colombiana.",
	"Para favorecer la salud de músculos, huesos y dientes, consuma diariamente leche u otro producto lácteo y huevo.",
	"Para una buena digestión y prevenir enfermedades del corazón, incluya en cada una de las comidas frutas enteras y verduras frescas.",
	"Para complementar su alimentación consuma al menos dos veces por semana leguminosas como frijol, lenteja, arveja y garbanzo.",
	"Para prevenir la anemia, los niños, niñas, adolescentes y mujeres jóvenes deben comer vísceras una vez por semana.",
	"Para mantener un peso saludable, reduzca el consumo de \"productos de paquete\", comidas rápidas, gaseosas y bebidas azucaradas.",
	"Para tener una presión arterial normal, reduzca el consumo de sal y alimentos como carnes embutidas, enlatados y productos de paquete, altos en sodio.",
	"Cuide su corazón, consuma aguacate, maní y nueces; disminuya el consumo de aceite vegetal y margarina; evite grasas de origen animal como mantequilla y manteca.",
	"Por el placer de vivir saludablemente realice actividad física frecuentemente.",
]

# Los 6 grupos del plato. "message" es el índice del mensaje GABA asociado al grupo.
# "plate_share" (Lab 6): fracción aproximada del plato que ocupa la división al dibujarlo.
var groups: Dictionary = {
	"cereales": {
		"label": "Cereales y\ntubérculos",
		"plate_share": 0.27,
		"name": "Cereales, raíces, tubérculos y plátanos",
		"short": "Cereales y tubérculos",
		"color": Color("f2c14e"),
		"function": "Son la principal fuente de energía (carbohidratos) para el cuerpo y el cerebro.",
		"importance": "Te dan fuerza para jugar, correr y concentrarte en clase. Prefiere los naturales e integrales: papa, yuca, arepa, plátano y arroz.",
		"message": 0,
	},
	"frutas_verduras": {
		"label": "Frutas y\nverduras",
		"plate_share": 0.3,
		"name": "Frutas y verduras",
		"short": "Frutas y verduras",
		"color": Color("6abf4b"),
		"function": "Aportan vitaminas, minerales y fibra.",
		"importance": "Ayudan a la digestión, cuidan el corazón y te protegen de enfermedades. Inclúyelas en cada comida, enteras y frescas.",
		"message": 2,
	},
	"lacteos": {
		"label": "Lácteos",
		"plate_share": 0.14,
		"name": "Leche y productos lácteos",
		"short": "Lácteos",
		"color": Color("4a90d9"),
		"function": "Aportan calcio y proteína.",
		"importance": "Forman huesos y dientes fuertes y ayudan a tus músculos mientras creces.",
		"message": 1,
	},
	"carnes": {
		"label": "Carnes, huevos\ny leguminosas",
		"plate_share": 0.14,
		"name": "Carnes, huevos, leguminosas secas, frutos secos y semillas",
		"short": "Carnes, huevos y leguminosas",
		"color": Color("e0533d"),
		"function": "Aportan proteína, hierro y zinc.",
		"importance": "Construyen y reparan los músculos y ayudan a prevenir la anemia. El fríjol, la lenteja y el maní también son de este grupo.",
		"message": 3,
	},
	"grasas": {
		"label": "Grasas",
		"plate_share": 0.08,
		"name": "Grasas",
		"short": "Grasas",
		"color": Color("f08cb4"),
		"function": "Dan energía concentrada y ayudan a aprovechar las vitaminas A, D, E y K.",
		"importance": "Se necesitan en poca cantidad. Prefiere el aguacate y los frutos secos; evita la manteca y la mantequilla.",
		"message": 7,
	},
	"azucares": {
		"label": "Azúcares",
		"plate_share": 0.07,
		"name": "Azúcares",
		"short": "Azúcares",
		"color": Color("9b6bc9"),
		"function": "Dan energía rápida.",
		"importance": "Son la porción más pequeña del plato: cómelos pocas veces y en poca cantidad para cuidar tu peso y tus dientes.",
		"message": 5,
	},
}

# Catálogo de alimentos: id -> nombre visible y grupo correcto.
var foods: Dictionary = {
	"arroz": {"name": "Arroz", "group": "cereales"},
	"pan": {"name": "Pan", "group": "cereales"},
	"papa": {"name": "Papa", "group": "cereales"},
	"maiz": {"name": "Maíz", "group": "cereales"},
	"arepa": {"name": "Arepa", "group": "cereales"},
	"pasta": {"name": "Pasta", "group": "cereales"},
	"manzana": {"name": "Manzana", "group": "frutas_verduras"},
	"banano": {"name": "Banano", "group": "frutas_verduras"},
	"zanahoria": {"name": "Zanahoria", "group": "frutas_verduras"},
	"brocoli": {"name": "Brócoli", "group": "frutas_verduras"},
	"tomate": {"name": "Tomate", "group": "frutas_verduras"},
	"naranja": {"name": "Naranja", "group": "frutas_verduras"},
	"mango": {"name": "Mango", "group": "frutas_verduras"},
	"fresa": {"name": "Fresa", "group": "frutas_verduras"},
	"pera": {"name": "Pera", "group": "frutas_verduras"},
	"sandia": {"name": "Sandía", "group": "frutas_verduras"},
	"leche": {"name": "Leche", "group": "lacteos"},
	"queso": {"name": "Queso", "group": "lacteos"},
	"pollo": {"name": "Pollo", "group": "carnes"},
	"pescado": {"name": "Pescado", "group": "carnes"},
	"huevo": {"name": "Huevo", "group": "carnes"},
	"carne": {"name": "Carne de res", "group": "carnes"},
	"frijoles": {"name": "Fríjoles", "group": "carnes"},
	"mani": {"name": "Maní", "group": "carnes"},
	"aguacate": {"name": "Aguacate", "group": "grasas"},
	"coco": {"name": "Coco", "group": "grasas"},
	"mantequilla": {"name": "Mantequilla", "group": "grasas"},
	"tocineta": {"name": "Tocineta", "group": "grasas"},
	"dulce": {"name": "Dulce", "group": "azucares"},
	"chocolatina": {"name": "Chocolatina", "group": "azucares"},
	"torta": {"name": "Torta", "group": "azucares"},
	"helado": {"name": "Helado", "group": "azucares"},
	"colombina": {"name": "Colombina", "group": "azucares"},
	"gaseosa": {"name": "Gaseosa", "group": "azucares"},
}

# Cuántos alimentos de cada grupo trae una ronda: imita las proporciones del plato
# (más cereales y frutas/verduras, menos grasas y azúcares).
var round_composition: Dictionary = {
	"cereales": 3, "frutas_verduras": 3, "lacteos": 2, "carnes": 2, "grasas": 1, "azucares": 1,
}

# Puntos por jugada (equivalente a la tabla de precios de la guía).
var points: Dictionary = {"correct": 10, "wrong": 0}

# --- Estado de la ronda (equivalente a "selection" de la guía) --------------------------
var selection: Dictionary = {
	"food": "",
	"correct": 0,
	"wrong": 0,
	"by_group": {},
}
var round_deck: Array[String] = []
var current_score: int = 0

# Lab 5: estrellas de bonificación obtenidas en el minijuego.
# Ejemplo: {"value": 30, "minimum_score": 60}
var bonuses: Array[Dictionary] = []

# Preferencias que sobreviven al cambio de pantalla
# Lab 8: sonido y tutorial (la mano guía se muestra hasta que el niño ubica su primer alimento)
var settings: Dictionary = {"show_hints": true, "sound_enabled": true, "tutorial_done": false}

# --- Lab 9: catálogo de alimentos de la lonchera (Resources) -----------------------------
# El GlobalManager no copia los alimentos: da acceso global al catálogo ingredient_database.tres
var ingredient_database: IngredientDatabase = preload("res://src/data/ingredient_database.tres")
var ingredients: Array[IngredientData]:
	get:
		return ingredient_database.ingredients

# Lab 9 (mejora "Lonchera Express"): pedidos de los niños, también como Resources
var order_database: OrderDatabase = preload("res://src/data/order_database.tres")

# Compartimentos de la lonchera (la guía usa dos mitades: "left" / "right")
const LUNCHBOX_SLOTS: Array[String] = ["bebida", "fruta", "principal", "snack"]
const LUNCH_ORDERS_PER_ROUND := 4
const SEAL_NAMES := {"azucares": "EXCESO EN AZÚCARES", "sodio": "EXCESO EN SODIO", "grasas": "EXCESO EN GRASAS SATURADAS"}

# Estado TEMPORAL de la lonchera (equivalente a pizza_selection / pizza_total de la guía)
var lunchbox_selection: Dictionary = {
	"bebida": "",
	"fruta": "",
	"principal": "",
	"snack": ""
}
var lunchbox_total: int = 0
# Ronda de pedidos en curso (temporal): pedidos, índice, tiempo restante y resultados
var lunch_round: Dictionary = {"orders": [], "index": 0, "time_left": 0.0, "results": [], "total": 0}
# Persistente: mejor puntaje de una ronda de Lonchera Express
var lunch_best: int = 0

# --- Lab 7: persistencia ----------------------------------------------------------------
# Estado TEMPORAL: la ronda en curso (selection, round_deck, current_score). Se pierde al cerrar.
# Estado PERSISTENTE: progreso del jugador. Se guarda en user:// (en Web, IndexedDB).
const SAVE_PATH := "user://save_data.json"
var best_score: int = 0
var groups_learned: Array[String] = []


func _ready() -> void:
	EventBus.next_food_requested.connect(_on_next_food_requested)
	EventBus.food_placed.connect(_on_food_placed)
	EventBus.round_restart_requested.connect(reset_round)
	EventBus.bonus_obtained.connect(_on_bonus_obtained)
	EventBus.hints_toggled.connect(_on_hints_toggled)
	EventBus.progress_reset_requested.connect(reset_progress)
	# Lab 9
	EventBus.ingredient_selected.connect(_on_ingredient_selected)
	EventBus.sound_toggled.connect(func(enabled: bool) -> void:
		settings["sound_enabled"] = enabled
		save_progress()
	)
	EventBus.tutorial_completed.connect(func() -> void:
		if not settings["tutorial_done"]:
			settings["tutorial_done"] = true
			save_progress()
	)
	# Lab 7: recuperar el progreso guardado al iniciar
	load_progress()
	reset_round()


func _on_hints_toggled(enabled: bool) -> void:
	settings["show_hints"] = enabled
	save_progress()


# Reinicia el estado de la ronda (cantidades en cero y mazo nuevo)
func reset_round() -> void:
	selection["food"] = ""
	selection["correct"] = 0
	selection["wrong"] = 0
	selection["by_group"] = {}
	for group_id in groups:
		selection["by_group"][group_id] = 0
	round_deck = _build_deck()
	_update_score()


func round_size() -> int:
	var total: int = 0
	for group_id in round_composition:
		total += round_composition[group_id]
	return total


func is_round_finished() -> bool:
	return selection["correct"] >= round_size()


func _build_deck() -> Array[String]:
	var deck: Array[String] = []
	for group_id in round_composition:
		var options: Array = foods.keys().filter(func(f: String) -> bool: return foods[f]["group"] == group_id)
		options.shuffle()
		for i in round_composition[group_id]:
			deck.append(options[i % options.size()])
	deck.shuffle()
	return deck


# Evento recibido -> modificar estado -> emitir resultado
func _on_next_food_requested() -> void:
	if round_deck.is_empty():
		selection["food"] = ""
	else:
		selection["food"] = round_deck.pop_back()
	EventBus.food_changed.emit(selection["food"])


func _on_food_placed(food_id: String, group_id: String) -> void:
	var correct: bool = is_correct(food_id, group_id)
	if correct:
		selection["correct"] += 1
		selection["by_group"][group_id] += 1
		_register_progress(group_id)
	else:
		# Lab 6: el alimento mal ubicado regresa a su bandeja (no al mazo)
		selection["wrong"] += 1
	_update_score()
	EventBus.placement_evaluated.emit(food_id, group_id, correct)


# Regla del juego: consulta pura sobre los datos
func is_correct(food_id: String, group_id: String) -> bool:
	return foods.has(food_id) and foods[food_id]["group"] == group_id


func _update_score() -> void:
	current_score = selection["correct"] * points["correct"] + selection["wrong"] * points["wrong"]
	current_score = max(current_score, 0)
	EventBus.score_changed.emit(current_score)


# Utilidades de consulta para la interfaz (solo lectura)
func food_texture_path(food_id: String) -> String:
	return "res://src/assets/foods/%s.png" % food_id


# --- Lab 9: lonchera ----------------------------------------------------------------------
# slot: índice del compartimento (0 bebida, 1 fruta, 2 principal, 3 snack)
func _on_ingredient_selected(ingredient_id: String, slot: int) -> void:
	if slot < 0 or slot >= LUNCHBOX_SLOTS.size():
		return
	lunchbox_selection[LUNCHBOX_SLOTS[slot]] = ingredient_id
	_update_lunchbox_total()


func _update_lunchbox_total() -> void:
	lunchbox_total = 0
	for ingredient_id in lunchbox_selection.values():
		var ingredient := get_ingredient(ingredient_id)
		if ingredient != null:
			lunchbox_total += ingredient.price
	EventBus.lunchbox_total_changed.emit(lunchbox_total)


# Consulta de solo lectura: busca un alimento del catálogo por su id
func get_ingredient(ingredient_id: String) -> IngredientData:
	for ingredient in ingredients:
		if ingredient.id == ingredient_id:
			return ingredient
	return null


func ingredients_of_kind(kind: String) -> Array[IngredientData]:
	var out: Array[IngredientData] = []
	for ingredient in ingredients:
		if ingredient.kind == kind:
			out.append(ingredient)
	return out


func lunchbox_items() -> Array[IngredientData]:
	var out: Array[IngredientData] = []
	for slot in LUNCHBOX_SLOTS:
		var ingredient := get_ingredient(lunchbox_selection[slot])
		if ingredient != null:
			out.append(ingredient)
	return out


func is_lunchbox_complete() -> bool:
	for slot in LUNCHBOX_SLOTS:
		if lunchbox_selection[slot] == "":
			return false
	return true


func seal_texture(seal_id: String) -> Texture2D:
	return load("res://src/assets/ui/seals/%s.png" % seal_id)


func reset_lunchbox() -> void:
	for slot in LUNCHBOX_SLOTS:
		lunchbox_selection[slot] = ""
	_update_lunchbox_total()


# --- Lonchera Express: ronda de pedidos ---------------------------------------------------
func start_lunch_round() -> void:
	var pool: Array = order_database.orders.duplicate()
	pool.shuffle()
	lunch_round = {"orders": pool.slice(0, LUNCH_ORDERS_PER_ROUND), "index": 0, "time_left": 0.0, "results": [], "total": 0}
	reset_lunchbox()
	lunch_round["time_left"] = float(current_order().time_limit)


func is_lunch_round_active() -> bool:
	return not lunch_round["orders"].is_empty() and lunch_round["index"] < lunch_round["orders"].size()


func current_order() -> OrderData:
	if not is_lunch_round_active():
		return null
	return lunch_round["orders"][lunch_round["index"]]


# Regla del pedido (consulta pura sobre la lonchera actual)
func order_fulfilled(order: OrderData) -> bool:
	var items := lunchbox_items()
	match order.rule:
		"contiene":
			return items.any(func(i: IngredientData) -> bool: return i.id in order.rule_values)
		"sin_sellos":
			return not items.is_empty() and items.all(func(i: IngredientData) -> bool: return i.seals.is_empty())
		"sin_azucar":
			return not items.is_empty() and items.all(func(i: IngredientData) -> bool: return i.group_id != "azucares" and not ("azucares" in i.seals))
		"min_puntos":
			return lunchbox_total >= order.rule_number
		"solo_saludable":
			return is_lunchbox_complete() and items.all(func(i: IngredientData) -> bool: return i.healthy)
	return false


# Califica la lonchera del pedido actual: puntos, estrellas (1 a 3) y mensajes de Nutri
func evaluate_lunchbox(time_left: float = 0.0) -> Dictionary:
	var order := current_order()
	var items := lunchbox_items()
	var met := order != null and order_fulfilled(order)
	var unhealthy: Array = items.filter(func(i: IngredientData) -> bool: return not i.healthy)
	var complete := is_lunchbox_complete()
	var stars := 1
	if met:
		stars += 1
	if complete and unhealthy.is_empty():
		stars += 1
	var lines: Array[String] = []
	if order != null:
		lines.append(order.success_text if met else order.fail_text)
	for item in unhealthy:
		lines.append("- %s: %s" % [item.display_name, item.tip])
	if not complete:
		lines.append("Faltó llenar compartimentos de la lonchera.")
	if met and complete and unhealthy.is_empty():
		lines.append("¡Lonchera balanceada y sin ultraprocesados!")
	# La rapidez solo premia una lonchera completa que cumple el pedido
	var time_bonus := int(ceil(time_left)) if complete and met else 0
	var points := lunchbox_total + (order.bonus_points if met else 0) + time_bonus
	return {"points": points, "stars": stars, "met": met, "time_bonus": time_bonus,
		"unhealthy": unhealthy.size(), "lines": lines, "kid": order.kid_name if order else ""}


# Entrega la lonchera: guarda el resultado, vacía la lonchera y pasa al siguiente pedido
func deliver_lunchbox(time_left: float) -> Dictionary:
	var result := evaluate_lunchbox(time_left)
	result["order"] = current_order()
	lunch_round["results"].append(result)
	lunch_round["total"] += result["points"]
	lunch_round["index"] += 1
	reset_lunchbox()
	if is_lunch_round_active():
		lunch_round["time_left"] = float(current_order().time_limit)
	return result


func lunch_round_stars() -> int:
	var total := 0
	for result in lunch_round["results"]:
		total += result["stars"]
	return total


# Al confirmar la ronda: guarda el récord si se superó
func register_lunch_score(final_points: int) -> bool:
	if final_points > lunch_best:
		lunch_best = final_points
		save_progress()
		return true
	return false


func group_message(group_id: String) -> String:
	return GABA_MESSAGES[groups[group_id]["message"]]


# --- Lab 5: reglas de negocio de las estrellas de bonificación --------------------------
# Datos: valor de la estrella, puntaje mínimo y estrellas guardadas.
# Reglas: una estrella por plato, se aplica la de mayor valor entre las válidas,
# solo es válida si el plato alcanza el puntaje mínimo.

func _on_bonus_obtained(bonus: Dictionary) -> void:
	bonuses.append(bonus)
	save_progress()


func get_best_bonus(subtotal: int) -> Dictionary:
	var best_bonus := {}
	for bonus in bonuses:
		if subtotal >= bonus["minimum_score"]:
			if best_bonus.is_empty() or bonus["value"] > best_bonus["value"]:
				best_bonus = bonus
	return best_bonus


func remove_bonus(bonus: Dictionary) -> void:
	if bonus in bonuses:
		bonuses.erase(bonus)
		save_progress()


# --- Lab 7: guardar y cargar el progreso -------------------------------------------------

func _register_progress(group_id: String) -> void:
	var changed: bool = false
	if not group_id in groups_learned:
		groups_learned.append(group_id)
		changed = true
	if is_round_finished() and current_score_after_correct() > best_score:
		best_score = current_score_after_correct()
		changed = true
	if changed:
		save_progress()


# _register_progress se llama antes de _update_score(); calcula el puntaje que tendrá la ronda
func current_score_after_correct() -> int:
	return max(selection["correct"] * points["correct"] + selection["wrong"] * points["wrong"], 0)


func save_progress() -> void:
	var save_data := {
		"version": 1,
		"bonuses": bonuses,
		"best_score": best_score,
		"lunch_best": lunch_best,
		"groups_learned": groups_learned,
		"settings": settings,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		printerr("No fue posible guardar el progreso: ", FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(save_data, "\t"))


func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		printerr("No fue posible cargar el progreso.")
		return
	var data = JSON.parse_string(file.get_as_text())
	if not data is Dictionary:
		printerr("Archivo de guardado inválido; se ignora.")
		return
	# JSON convierte los enteros en float: se normalizan al cargarlos.
	# Se usa assign() porque un Array genérico no puede asignarse a un Array tipado.
	bonuses.clear()
	for bonus in data.get("bonuses", []):
		if bonus is Dictionary and bonus.has("value") and bonus.has("minimum_score"):
			bonuses.append({"value": int(bonus["value"]), "minimum_score": int(bonus["minimum_score"])})
	best_score = int(data.get("best_score", 0))
	lunch_best = int(data.get("lunch_best", 0))
	groups_learned.assign(data.get("groups_learned", []).filter(func(g) -> bool: return groups.has(g)))
	var loaded_settings = data.get("settings", {})
	if loaded_settings is Dictionary:
		settings["show_hints"] = bool(loaded_settings.get("show_hints", true))
		settings["sound_enabled"] = bool(loaded_settings.get("sound_enabled", true))
		settings["tutorial_done"] = bool(loaded_settings.get("tutorial_done", false))


func reset_progress() -> void:
	bonuses.clear()
	best_score = 0
	lunch_best = 0
	groups_learned.clear()
	settings["tutorial_done"] = false  # Lab 8: un nuevo jugador vuelve a ver la mano guía
	save_progress()
