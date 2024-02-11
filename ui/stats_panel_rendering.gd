extends Control


var gpu_time:float = 0.0
var draw_time:float = 0.0
var game_time:float = 0.0

var _viewports:Array[RID] = []


func _enter_tree():
	StatEvents.viewport_activated.connect(add_viewport)
	StatEvents.viewport_deactivated.connect(remove_viewport)


func _exit_tree():
	StatEvents.viewport_activated.disconnect(add_viewport)
	StatEvents.viewport_deactivated.disconnect(remove_viewport)


func _ready():
	_viewports.append(get_viewport().get_viewport_rid())
	for node in get_tree().root.find_children("", "Viewport", true, false):
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


func add_viewport(rid:RID):
	if not _viewports.has(rid):
		RenderingServer.viewport_set_measure_render_time(rid, true)
		_viewports.append(rid)


func remove_viewport(rid:RID):
	if _viewports.has(rid):
		RenderingServer.viewport_set_measure_render_time(rid, false)
		_viewports.remove_at(_viewports.find(rid))
