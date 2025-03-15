extends Menu
const PREFAB : PackedScene = preload("res://Scenes/UI/item.tscn")

@onready var _character: CharacterBody3D = %Barbarian
@onready var player: Node = %Player
@onready var _item_container: GridContainer = $ScrollContainer/ItemContainer
@onready var _item_name: Label = $Title/VBoxContainer/ItemName
@onready var _item_description: Label = $Title/VBoxContainer/ItemDescription
@onready var _auxillary: Button = $Title/VBoxContainer/HBoxContainer/Auxillary
@onready var _drop: Button = $Title/VBoxContainer/HBoxContainer/Drop


#Remember bool always is set to false
var is_open: bool
var _selected_item : Item 
var _selected_button : Button
var _previously_selected_button : Button

func _ready():
	for item in File.progress.inventory:
		_add_item_button(load("res://Scripts/custom_resources/Items/" + item.name + ".tres"), item.quantity if item.has("quantity") else 1)

func open(breadcrumb : Menu = null):
	player.enabled = false
	super.open(breadcrumb)
	if _item_container.get_child_count() > 0:
		_item_container.get_child(0).grab_focus()
	else:
		_display_item_information(null)
	
	is_open = true

func add_item(item : Item, quantity : int = 1):
	if item is Stackable: 
		_add_stackable_item(item, quantity)
	else:
		for i in quantity:
			_add_single_item(item) 

func _add_single_item(item: Item):
	File.progress.inventory.push_back({"name": item.name})
	_add_item_button(item)
 
func _add_stackable_item(item : Stackable, quantity : int):
	#search in the inventory stacks of items 
	for i in File.progress.inventory.size():
		if File.progress.inventory[i].name == item.name:
			#check if there is any room within the stack
			if File.progress.inventory[i].quantity < item.stack_limit:
				#add the quantity and check if the said quantity exceeds the stack limit
				File.progress.inventory[i].quantity += quantity
				#reduce quantity
				quantity = File.progress.inventory[i].quantity - item.stack_limit
				if quantity > 0:
					File.progress.inventory[i].quantity = item.stack_limit
					_update_quantity(_item_container.get_child(i), item.stack_limit)
				else:
					_update_quantity(_item_container.get_child(i), File.progress.inventory[i].quantity)
					break
	#repeat until all quantity has been filled
	if quantity <= 0:
		return
	#Create a new stack if previous stack is full
	while quantity > 0:
		if quantity <= item.stack_limit:
			File.progress.inventory.push_back({"name" : item.name, "quantity" : quantity})
			_add_item_button(item, quantity)
			quantity = 0
		else:
			File.progress.inventory.push_back({"name" : item.name, "quantity" : item.stack_limit})
			_add_item_button(item, item.stack_limit)
			quantity -= item.stack_limit
		

	## If the existing stacks are full, create new ones
	#while quantity > 0:
		#var new_stack_quantity = min(quantity, item.stack_limit)
		#File.progress.inventory.push_back({"name": item.name, "quantity": new_stack_quantity})
		#_add_item_button(item, new_stack_quantity)
		#quantity -= new_stack_quantity

func _add_item_button(item : Item, quantity : int = 1):
	var new_item_button : Button = PREFAB.instantiate()
	new_item_button.get_node("Icon").texture = item.icon
	_update_quantity(new_item_button, quantity)
	_item_container.add_child(new_item_button)
	new_item_button.focus_entered.connect(_display_item_information.bind(item, new_item_button))
	new_item_button.focus_exited.connect(_display_item_information.bind(null, null))

func _update_quantity(button : Button, quantity : int):
	if quantity != 1:
		button.get_node("Label").text = str(quantity)
	else:
		button.get_node("Label").visible = false


func _display_item_information(item : Item = null, button : Button = null):
	_item_name.text = item.name if item else ""
	_item_description.text = item.description if item else ""
	_selected_item = item
	_previously_selected_button = _selected_button
	_selected_button = button
	
	if item && item.is_usable:
		_auxillary.text = "X Use"
		_auxillary.disabled = false
	else:
		_auxillary.disabled = true
	_drop.disabled = not item


func _input(event: InputEvent):
	if not is_open:
		return
	
	if event.is_action_pressed('use_item'):
		if _auxillary.disabled == false:
			_auxillary.pressed.emit()
		
		if event.is_action_pressed('drop_item'):
			if _drop.disabled == false:
				_drop.pressed.emit()


func _on_action_button_focus_entered():
	if _previously_selected_button:
		_previously_selected_button.grab_focus()


func _on_auxillary_pressed():
	if _selected_button:
		if _selected_button.is_usable:
			_use_selected_item()

func _use_selected_item():
	if _character.is_on_floor() && _character._can_move:
		_character.use_item(_selected_item)
		if _selected_item.is_consumable:
			_remove_item(_selected_item, 1, _selected_button)
		close()


func _on_drop_pressed():
	if _selected_item:
		var instance : Node3D = load(_selected_item.scene).instantiate()
		var direction : float = randf_range(0, TAU)
		$/root/Game.add_child(instance)
		instance.global_position = _character.global_position + Vector3(sin(direction), 1, cos(direction))
		_remove_item(_selected_item, 1, _selected_button)


func _remove_item(item : Item, quantity : int = 1, button : Button = null):
	if item is Stackable:
		_remove_stackable_item(item, quantity, button)
	else:
		for i in quantity:
			_remove_single_item(item, button if i == 0 else null)

func _remove_single_item(item: Item, button : Button):
	if button:
		File.progress.inventory.remove_at(_item_container.get_children().find(button))
		_remove_item_button(button)
		return
	for i in File.progress.inventory.size():
		if File.progress.inventory[i].name == item.name:
			File.progress.inventory.remove_at(i)
			_remove_item_button(_item_container.get_child(i))
			return

func _remove_stackable_item(item : Item, quantity : int = 1, button : Button = null):
	if button:
		var index : int = _item_container.get_children().find(button)
		File.progress.inventory[index].quantity -= quantity 
		if File.progress.inventory[index].quantity <= 0:
			quantity = -File.progress.inventory[index].quantity
			File.progress.inventory.remove_at(index)
			_remove_item_button(button)
		else:
			_update_quantity(button, File.progress.inventory[index].quantity)
			return
	if quantity == 0:
		return
	for i in File.progress.inventory.size():
		if File.progress.inventory[i].name == item.name:
			File.progress.inventory[i].quantity -= quantity 
			if File.progress.inventory[i].quantity <= 0:
				quantity = -File.progress.inventory[i].quantity
				File.progress.inventory.remove_at(i)
				_remove_item_button(_item_container.get_child(i))
			else:
				_update_quantity(_item_container.get_child(i), File.progress.inventory[i].quantity)
				return
		if quantity == 0:
			return
	

func _remove_item_button(button : Button):
	if button == _selected_button:
		_focus_next()
	if button == _previously_selected_button:
		_previously_selected_button = null
	button.free()

func _focus_next(button : Button = null):
	var children : int = _item_container.get_child_count()
	if children < 2:
		return
	if not button:
		_item_container.get_child(0).grab_focus()
		return
	var index : int = _item_container.get_children().find(button)
	_item_container.get_child(index + (1 if index + 1 < children else -1)).grab_focus()

func close():
	if not _breadcrumb:
		player.enabled = true
	super.close()
	is_open = false



