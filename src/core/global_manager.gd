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
var settings: Dictionary = {"show_hints": true}


func _ready() -> void:
	EventBus.next_food_requested.connect(_on_next_food_requested)
	EventBus.food_placed.connect(_on_food_placed)
	EventBus.round_restart_requested.connect(reset_round)
	EventBus.bonus_obtained.connect(_on_bonus_obtained)
	EventBus.hints_toggled.connect(func(enabled: bool) -> void: settings["show_hints"] = enabled)
	reset_round()


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


func group_message(group_id: String) -> String:
	return GABA_MESSAGES[groups[group_id]["message"]]


# --- Lab 5: reglas de negocio de las estrellas de bonificación --------------------------
# Datos: valor de la estrella, puntaje mínimo y estrellas guardadas.
# Reglas: una estrella por plato, se aplica la de mayor valor entre las válidas,
# solo es válida si el plato alcanza el puntaje mínimo.

func _on_bonus_obtained(bonus: Dictionary) -> void:
	print("Estrella obtenida: ", bonus)
	bonuses.append(bonus)


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
