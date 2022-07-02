extends Node2D

export var width  = 600
export var height  = 200
onready var tilemap = $TileMap
var temperature = {}
var moisture = {}
var altitude = {}
var biome = {}
var openSimplexNoise = OpenSimplexNoise.new()

func generate_map(per, oct):
	openSimplexNoise.seed = randi()
	openSimplexNoise.period = per
	openSimplexNoise.octaves = oct
	var gridName = {}
	for x in width:
		for y in height:
			var rand := 2*(abs(openSimplexNoise.get_noise_2d(x,y)))
			gridName[Vector2(x,y)] = rand
	return gridName


func _ready():
	temperature = generate_map(300, 5)
	moisture = generate_map(300, 5)
	altitude = generate_map(150, 5)
	set_tile(width, height)
	
	
	
func set_tile(width, height):
	for x in width:
		for y in height:
			var pos = Vector2(x, y)
			var alt = altitude[pos]
			var temp = temperature[pos]
			var moist = moisture[pos]
			
			#Ocean
			if alt < 0.2:
				tilemap.set_cellv(pos, 3)
			
			#Beach
			elif between(alt, 0.2, 0.25):
				tilemap.set_cellv(pos, 2)
				
			#Other Biomes
			elif between(alt, 0.25, 0.8):
				#plains
				if between(moist, 0, 0.9) and between(temp, 0, 0.6):
					tilemap.set_cellv(pos, 0)
				#jungle
				elif between(moist, 0.4, 0.9) and temp > 0.6:
					tilemap.set_cellv(pos, 1)
				#desert
				elif temp > 0.6 and moist < 0.4:
					tilemap.set_cellv(pos, 2)
				#lakes
				elif moist >= 0.9:
					tilemap.set_cellv(pos, 0)
			#Mountains
			elif between(alt, 0.8, 0.95):
				tilemap.set_cellv(pos, 5)
			else:
				tilemap.set_cellv(pos, 4)
				
				
func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()

func between(val, start, end):
	if start <= val and val < end:
		return true
