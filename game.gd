extends MultiMeshInstance

class Tile:
	var v : bool
	var life : int
	var others : Array
	
	func _init():
		self.v = false
		self.life = 0
		self.others = Array()
		
	func get_total() -> int:
		var result : int = 0
		
		for other in others:
			result += other.get_value()
		
		return result
		
	func get_value():
		if v:
			return 1
			
		return 0
		
class Map:
	var data : Array
	var next : Array
	var empty : Tile
	
	var w : int
	var h : int
	
	func _init(width : int, height : int):
		self.empty = Tile.new()
		
		self.w = width
		self.h = height
		
		data = Array()
		next = Array()

		for i in self.w * self.h:
			data.append(Tile.new())
			next.append(false)

		var i = 0
		for y in self.h:
			for x in self.w:
				var t = data[i]
				t.others = [
					at(x - 1, y - 1), at(x, y - 1), at(x + 1, y - 1),
					at(x - 1, y), at(x + 1, y),
					at(x - 1, y + 1), at(x, y + 1), at(x + 1, y + 1)]
				i += 1
		
	func get_index(x, y):
		if x < 0 || x >= w || y < 0 || y >= h:
			return -1
		
		return x + y * w
		
	func put(x, y, v):
		var index = get_index(x, y)
		if index == -1:
			return
			
		data[index].v = v
		
	func at(x, y):
		var index = get_index(x, y)
		if index == -1:
			return empty
			
		return data[index]
		
	func process():
		for i in w * h:
			var t = data[i]
			var v = t.get_total()
				
			if data[i].v:
				next[i] = v == 2 || v == 3
			else:
				next[i] = v == 3
					
		for i in w * h:
			data[i].v = next[i]

			if data[i].v:
				data[i].life = 20

			data[i].life = max(0, data[i].life - 1)
		
var map : Map

func _ready():
	map = Map.new(100, 100)
	self.multimesh.instance_count = map.w * map.h

	var l = int(sqrt(self.multimesh.instance_count))

	var index : int = 0
	
	for y in l:
		for x in l:
			self.multimesh.set_instance_transform(index, Transform(Basis(), Vector3(x, randi() % 10 * 0.1, y)))
			self.multimesh.set_instance_color(index, Color(255, x, y))
			
			index += 1

var frame : int

func _process(_delta):
	frame += 1
	if frame == 10:
		map.put(25, 25, true)
		map.put(24, 25, true)
		map.put(26, 25, true)
		map.put(25, 24, true)
		map.put(75, 75, true)
		map.put(74, 75, true)
		map.put(76, 75, true)
		map.put(75, 74, true)

		frame = 0

	map.process()
	
	for i in self.multimesh.instance_count:
		var tile = map.data[i]
		if tile.v:
			self.multimesh.set_instance_color(i, Color(1.0, 0, 0))
		else:
			self.multimesh.set_instance_color(i, Color(0, tile.life / 50.0, 0))
