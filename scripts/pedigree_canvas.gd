class_name PedigreeCanvas
extends Control

## 谱系画布 - 自定义 _draw 实现
## 在 pedigree_view 中使用

var connections: Array = []

func set_connections(conns: Array) -> void:
    connections = conns
    queue_redraw()

func _draw() -> void:
    for conn in connections:
        var from_pos: Vector2 = conn.get("from", Vector2.ZERO)
        var to_pos: Vector2 = conn.get("to", Vector2.ZERO)
        var color: Color = conn.get("color", Color.WHITE)
        
        if from_pos == Vector2.ZERO or to_pos == Vector2.ZERO:
            continue
        
        draw_line(from_pos, to_pos, color, 3, true)
        
        # 小箭头
        var dir := (to_pos - from_pos).normalized()
        if dir == Vector2.ZERO:
            continue
        var arrow_size := 8.0
        var arrow_tip := to_pos - dir * 5
        var arrow_left := arrow_tip - dir.rotated(PI / 6.0) * arrow_size
        var arrow_right := arrow_tip - dir.rotated(-PI / 6.0) * arrow_size
        var arrow_points := PackedVector2Array([arrow_tip, arrow_left, arrow_right])
        draw_colored_polygon(arrow_points, color)
