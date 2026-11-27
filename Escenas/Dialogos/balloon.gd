extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.

## The dialogue resource
@export var dialogue_resource: DialogueResource

## Start from a given title when using balloon as a Node in a scene.
@export var start_from_title: String = ""

## If running as a Node in a scene then auto start the dialogue.
@export var auto_start: bool = false

## If all other input is blocked as long as dialogue is shown.
@export var will_block_other_input: bool = true

## The action to use for advancing dialogue.
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing dialogue.
@export var skip_action: StringName = &"ui_cancel"

## Audio player for voice lines.
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

## Temporary game states.
var temporary_game_states: Array = []

## See if we are waiting for the player.
var is_waiting_for_input: bool = false

## See if we are running a long mutation.
var will_hide_balloon: bool = false

## Dictionary for ephemeral variables.
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

## The current dialogue line.
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			if is_instance_valid(audio_stream_player):
				audio_stream_player.stop()

			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line

## Cooldown timer for mutations.
var mutation_cooldown: Timer = Timer.new()

## Main balloon nodes.
@onready var balloon: Control = %Balloon
@onready var dialogue_frame: TextureRect = $Balloon/DialogueFrame
@onready var character_portrait: TextureRect = $Balloon/CharacterPortrait
@onready var panel_container: PanelContainer = $Balloon/MarginContainer/PanelContainer
@onready var outer_margin: MarginContainer = $Balloon/MarginContainer
@onready var content_margin: MarginContainer = $Balloon/MarginContainer/PanelContainer/ContentMargin

## Character portraits.
const RETRATOS: Dictionary = {
	"claud": preload("res://Arte/Claud Dialogos.png"),
	"elfi_bug": preload("res://Arte/Elfi_ Dialogo bug.png"),
	"elfi_normal": preload("res://Arte/Elfi_ Dialogo normal.png")
}

## Dialogue frames.
const MARCOS: Dictionary = {
	"gold": preload("res://Arte/recuadro dialogo personajes sec.png"),
	"glitch": preload("res://Arte/recuadro dialogo roto.png"),
	"cyan": preload("res://Arte/recuadro dialogo servi.png")
}

## Character name.
@onready var character_label: RichTextLabel = %CharacterLabel

## Dialogue text.
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## Responses menu.
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

## Progress indicator.
@onready var progress: Polygon2D = %Progress


func _ready() -> void:
	balloon.hide()

	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()


func _process(_delta: float) -> void:
	if is_instance_valid(dialogue_line):
		progress.visible = (
			not dialogue_label.is_typing
			and dialogue_line.responses.size() == 0
		)


func _unhandled_input(_event: InputEvent) -> void:
	if will_block_other_input:
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if (
		what == NOTIFICATION_TRANSLATION_CHANGED
		and _locale != TranslationServer.get_locale()
		and is_instance_valid(dialogue_label)
	):
		_locale = TranslationServer.get_locale()

		var visible_ratio: float = dialogue_label.visible_ratio
		dialogue_line = await dialogue_resource.get_next_dialogue_line(dialogue_line.id)

		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start dialogue.
func start(
	with_dialogue_resource: DialogueResource = null,
	title: String = "",
	extra_game_states: Array = []
) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false

	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource

	if not title.is_empty():
		start_from_title = title

	dialogue_line = await dialogue_resource.get_next_dialogue_line(
		start_from_title,
		temporary_game_states
	)

	show()


## Apply changes to the balloon for the current dialogue line.
func apply_dialogue_line() -> void:
	
	
	mutation_cooldown.stop()

	progress.hide()
	is_waiting_for_input = false

	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")

	_actualizar_apariencia_dialogo()

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	balloon.show()
	will_hide_balloon = false

	# Stop the previous voice.
	# Detener el audio anterior
	audio_stream_player.stop()

	# Reproducir el audio de esta línea
	if dialogue_line.has_tag("voice"):
		var ruta_audio: String = str(dialogue_line.get_tag_value("voice"))
		print("AUDIO DETECTADO: ", ruta_audio)

		var audio: AudioStream = load(ruta_audio) as AudioStream

		if audio != null:
			audio_stream_player.stream = audio
			audio_stream_player.play()
		else:
			push_warning("No se pudo cargar el audio: " + ruta_audio)

	# Mostrar el texto
	dialogue_label.show()

	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Handle responses.
	if dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()

	# Handle automatic dialogue timing.
	elif dialogue_line.time != "":
		var time: float = (
			dialogue_line.text.length() * 0.02
			if dialogue_line.time == "auto"
			else dialogue_line.time.to_float()
		)

		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)

	# Wait for player input.
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


## Configure portrait and frame for the current line.
func _actualizar_apariencia_dialogo() -> void:
	var retrato_id: String = dialogue_line.get_tag_value("portrait")
	var marco_id: String = dialogue_line.get_tag_value("frame")

	var textura_retrato: Texture2D = RETRATOS.get(retrato_id)
	var textura_marco: Texture2D = MARCOS.get(marco_id)

	var usar_apariencia_personaje: bool = (
		textura_retrato != null
		and textura_marco != null
	)

	character_portrait.texture = textura_retrato
	dialogue_frame.texture = textura_marco

	character_portrait.visible = usar_apariencia_personaje
	dialogue_frame.visible = usar_apariencia_personaje

	if usar_apariencia_personaje:
		var fondo_dialogo := StyleBoxFlat.new()
		fondo_dialogo.bg_color = Color(0.035, 0.04, 0.05, 0.94)

		panel_container.add_theme_stylebox_override(
			"panel",
			fondo_dialogo
		)

		outer_margin.offset_left = 80.0
		outer_margin.offset_right = -80.0

		content_margin.add_theme_constant_override("margin_left", 145)
		content_margin.add_theme_constant_override("margin_right", 28)
		content_margin.add_theme_constant_override("margin_top", 30)
		content_margin.add_theme_constant_override("margin_bottom", 22)

	else:
		outer_margin.offset_left = 0.0
		outer_margin.offset_right = 0.0

		panel_container.remove_theme_stylebox_override("panel")

		content_margin.remove_theme_constant_override("margin_left")
		content_margin.remove_theme_constant_override("margin_right")
		content_margin.remove_theme_constant_override("margin_top")
		content_margin.remove_theme_constant_override("margin_bottom")


## Go to the next dialogue line.
func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(
		next_id,
		temporary_game_states
	)


#region Signals

func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# Skip typing when requested.
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.is_pressed()
		)

		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)

		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input:
		return

	if dialogue_line.responses.size() > 0:
		return

	get_viewport().set_input_as_handled()

	if (
		event is InputEventMouseButton
		and event.is_pressed()
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		next(dialogue_line.next_id)

	elif (
		event.is_action_pressed(next_action)
		and get_viewport().gui_get_focus_owner() == balloon
	):
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(
	response: DialogueResponse
) -> void:
	next(response.next_id)


#endregion
