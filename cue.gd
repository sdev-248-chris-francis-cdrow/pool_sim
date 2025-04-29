extends RigidBody3D

@export var move_speed := 0.5
@export var angle_speed := 20.0  # degrees per second
@export var minpower := 0
@export var maxpower := 2
@export var passive_material: PhysicsMaterial
@export var active_material: PhysicsMaterial

var power := 0.0
var charging := false
var shooting = false
var start_position := Vector3.ZERO  # Cue's starting position

const CHARGE_RATE := 0.009
const PASSIVE_MASS := 0.0001
const ACTIVE_MASS := 0.595

signal changed_power(power: float)

func _ready():
	mass = PASSIVE_MASS
	physics_material_override = passive_material
	start_position = global_position
	linear_damp = 3.0  # Some damping to help with movement stop
	angular_damp = 3.0

func reset():
	mass = PASSIVE_MASS
	physics_material_override = passive_material
	position = Vector3(0, 0.105, 1.972)
	rotation = Vector3(0, deg_to_rad(180), 0)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	power = 0.0
	charging = false
	shooting = false
	
func _physics_process(delta):
	# Lock the cue's y position
	global_position.y = 0.105
	rotation.x = 0

	


	if Input.is_action_just_pressed("charge_shot"):
		charging = true
		mass = ACTIVE_MASS
		physics_material_override = active_material
	elif Input.is_action_just_released("charge_shot"):
		charging = false
		shoot()
	
	if charging:
		power += CHARGE_RATE
		power = clamp(power, minpower, maxpower)
		changed_power.emit(power)
		print(power)
		return
		
	if shooting:
		return
	handle_movement_input(delta)

func handle_movement_input(delta):
	var direction := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction.z += 1
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
	if Input.is_action_pressed("move_left"):
		direction.x += 1
	if Input.is_action_pressed("move_right"):
		direction.x -= 1

	if direction != Vector3.ZERO:
		var move = global_transform.basis * direction.normalized() * move_speed
		apply_central_impulse(move * delta * mass)

	if Input.is_action_pressed("angle_left"):
		apply_torque_impulse(Vector3.UP * -deg_to_rad(angle_speed * delta) * mass)
	if Input.is_action_pressed("angle_right"):
		apply_torque_impulse(Vector3.UP * deg_to_rad(angle_speed * delta) * mass)

func shoot():
	shooting = true

	var shoot_dir = global_transform.basis.z.normalized()
	apply_central_impulse(shoot_dir * power * mass)
	print("Shoot impulse:", shoot_dir * power * mass)
	power = 0
	
	await get_tree().create_timer(1).timeout

	changed_power.emit(power)
	physics_material_override = passive_material
	mass = PASSIVE_MASS
	shooting = false
