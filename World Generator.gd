extends Node2D

export var width  = 600
export var height  = 200
onready var tilemap = $TileMap
var temperature = {}
var moisture = {}
var altitude = {}
var biome = {}
var openSimplexNoise = OpenSimplexNoise.new()

var objects = {}


var tiles = {"grass": 0, "jungle_grass": 1, "sand": 2, "water": 3, "snow": 4, "stone": 5}


var object_tiles = {"tree": preload("res://Tree.tscn"), "cactus": preload("res://Cactus.tscn"), "spruce_tree": preload("res://Spruce_tree.tscn")}


var biome_data = {
	"plains": {"grass": 1},
	"beach": {"sand": 0.99, "stone": 0.01}, 
	"jungle": {"jungle_grass": 1},
	"desert": {"sand": 0.98, "stone": 0.02}, 
	"lake": {"water": 1},
	"mountain": {"stone": 0.98, "grass":0.02},
	"snow": {"snow": 0.97, "stone": 0.02, "grass": 0.02},
	"ocean":{"water": 1}
}

var object_data = {
	"plains": {"tree": 0.03},
	"beach": {"tree": 0.01}, 
	"jungle": {"tree": 0.04},
	"desert": {"cactus": 0.03}, 
	"lake": {},
	"mountain": {"spruce_tree":0.02},
	"snow": {"spruce_tree": 0.02},
	"ocean":{}
}


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
				biome[pos] = "ocean"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"ocean")])
			
			#Beach
			elif between(alt, 0.2, 0.25):
				biome[pos] = "beach"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"beach")])
			#Other Biomes
			elif between(alt, 0.25, 0.8):
				#plains
				if between(moist, 0, 0.9) and between(temp, 0, 0.6):
					biome[pos] = "plains"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"plains")])
				#jungle
				elif between(moist, 0.4, 0.9) and temp > 0.6:
					biome[pos] = "jungle"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"jungle")])
				#desert
				elif temp > 0.6 and moist < 0.4:
					biome[pos] = "desert"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"desert")])
				#lakes
				elif moist >= 0.9:
					biome[pos] = "lake"
					tilemap.set_cellv(pos, tiles[random_tile(biome_data,"lake")])
			#Mountains
			elif between(alt, 0.8, 0.95):
				biome[pos] = "mountain"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"mountain")])
			#Snow
			else:
				biome[pos] = "snow"
				tilemap.set_cellv(pos, tiles[random_tile(biome_data,"snow")])
	set_objects()
				
				
func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()

func between(val, start, end):
	if start <= val and val < end:
		return true
		

func random_tile(data, biome):
	var current_biome = data[biome]
	var rand_num = rand_range(0,1)
	var running_total = 0
	for tile in current_biome:
			running_total = running_total+current_biome[tile]
			if rand_num <= running_total:
				return tile
				
func set_objects():
	objects = {}
	for pos in biome:
		var current_biome = biome[pos]
		var random_object = random_tile(object_data, current_biome)
		objects[pos] = random_object
		if random_object != null:
			tile_to_scene(random_object, pos)
			
func tile_to_scene(random_object, pos):
	var instance = object_tiles[str(random_object)].instance()
	instance.position = tilemap.map_to_world(pos) + Vector2(4, 4)
	$YSort.add_child(instance)

