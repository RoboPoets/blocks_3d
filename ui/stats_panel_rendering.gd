extends Control


var gpu_time:float = 0.0
var draw_time:float = 0.0
var game_time:float = 0.0

var _viewports:Array[RID] = []


func _ready():
	_viewports.append(get_viewport().get_viewport_rid())
	for node:Viewport in get_tree().get_nodes_in_group(&"Viewport"):
		_viewports.append(node.get_viewport_rid())

	for rid in _viewports:
		RenderingServer.viewport_set_measure_render_time(rid, true)


func _process(delta:float):
	var gpu:float = 0.0
	var draw:float = RenderingServer.get_frame_setup_time_cpu()
	for rid in _viewports:
		gpu += RenderingServer.viewport_get_measured_render_time_gpu(rid)
		draw += RenderingServer.viewport_get_measured_render_time_cpu(rid)

	gpu_time = lerpf(gpu_time, gpu, delta)
	draw_time = lerpf(draw_time, draw, delta)
	game_time = lerpf(game_time, delta * 1000.0 - draw, delta)

	%Game.text = "%.2f ms" % game_time
	%Draw.text = "%.2f ms" % draw_time
	%GPU.text = "%.2f ms" % gpu_time
