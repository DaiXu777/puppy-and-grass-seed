extends Control

## 谱系视图 - 展示蒲公英号探险队员的后代谱系
## 使用自定义 PedigreeCanvas 进行绘制

var _story_data: StoryData
var _node_controls: Dictionary = {}
var _pedigree_canvas: PedigreeCanvas

const NODE_SIZE := Vector2(180, 100)
const NODE_COLOR_ROOT := Color("#E8C56D")
const NODE_COLOR_HYBRID := Color("#7DCEA0")
const NODE_COLOR_GREEN := Color("#4CAF50")
const NODE_COLOR_FUR := Color("#F4A460")
const NODE_COLOR_FINAL := Color("#FFD700")


func _ready() -> void:
    _story_data = StoryData.new()
    _story_data.load_data()
    _setup_ui()
    _build_pedigree()


func _setup_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#FAF3E3")
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    
    var main_vbox := VBoxContainer.new()
    main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
    main_vbox.add_theme_constant_override("margin_left", 30)
    main_vbox.add_theme_constant_override("margin_top", 20)
    main_vbox.add_theme_constant_override("margin_right", 30)
    main_vbox.add_theme_constant_override("margin_bottom", 20)
    add_child(main_vbox)
    
    var header := HBoxContainer.new()
    var title := Label.new()
    title.text = "🌿 蒲公英号 · 后代谱系"
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color("#3E2723"))
    header.add_child(title)
    
    header.add_child(_make_spacer())
    
    var back_btn := Button.new()
    back_btn.text = "← 返回调查"
    back_btn.pressed.connect(_on_back)
    back_btn.add_theme_font_size_override("font_size", 16)
    header.add_child(back_btn)
    
    main_vbox.add_child(header)
    main_vbox.add_child(_make_sep())
    
    _pedigree_canvas = PedigreeCanvas.new()
    _pedigree_canvas.size_flags_horizontal = Control.SIZE_EXPAND
    _pedigree_canvas.size_flags_vertical = Control.SIZE_EXPAND
    _pedigree_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
    main_vbox.add_child(_pedigree_canvas)
    
    var legend := HBoxContainer.new()
    legend.add_theme_constant_override("separation", 20)
    for item in [
        ["🟡 初代探险队", NODE_COLOR_ROOT],
        ["🟢 草犬混种", NODE_COLOR_HYBRID],
        ["🌿 绿崽谱系", NODE_COLOR_GREEN],
        ["🐕 毛芽谱系", NODE_COLOR_FUR],
        ["⭐ 小狗与草籽", NODE_COLOR_FINAL],
    ]:
        var lbl := Label.new()
        lbl.text = item[0]
        lbl.add_theme_font_size_override("font_size", 14)
        lbl.add_theme_color_override("font_color", item[1])
        legend.add_child(lbl)
    main_vbox.add_child(legend)


func _build_pedigree() -> void:
    var all_nodes := _story_data.get_all_pedigree_nodes()
    if all_nodes.is_empty():
        return
    
    var node_positions := _calculate_positions(all_nodes)
    var connections: Array = []
    
    for node_id in all_nodes:
        var node_data := all_nodes[node_id]
        var pos := node_positions.get(node_id, Vector2.ZERO)
        var node_ctrl := _create_node_widget(node_data)
        node_ctrl.position = pos
        _pedigree_canvas.add_child(node_ctrl)
        _node_controls[node_id] = node_ctrl
    
    for node_id in all_nodes:
        var node_data := all_nodes[node_id]
        var from_pos := node_positions.get(node_id, Vector2.ZERO)
        for child_id in node_data.get("parent_of", []):
            var to_pos := node_positions.get(child_id, Vector2.ZERO)
            if to_pos != Vector2.ZERO:
                connections.append({
                    "from": from_pos + Vector2(NODE_SIZE.x / 2.0, NODE_SIZE.y),
                    "to": to_pos + Vector2(NODE_SIZE.x / 2.0, 0),
                    "color": NODE_COLOR_HYBRID,
                })
    
    _pedigree_canvas.set_connections(connections)


func _calculate_positions(nodes: Dictionary) -> Dictionary:
    var generations: Dictionary = {}
    for node_id in nodes:
        var gen: int = nodes[node_id].get("generation", 0)
        if not generations.has(gen):
            generations[gen] = []
        generations[gen].append(node_id)
    
    var positions := {}
    var start_y := 40.0
    var y_spacing := 160.0
    var x_center := 640.0
    
    for gen in generations:
        var node_ids: Array = generations[gen]
        var total_width := node_ids.size() * 220.0
        var start_x := x_center - total_width / 2.0 + 110.0
        for j in node_ids.size():
            positions[node_ids[j]] = Vector2(start_x + j * 220.0 - NODE_SIZE.x / 2.0, start_y + gen * y_spacing)
    
    return positions


func _create_node_widget(node_data: Dictionary) -> Control:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = NODE_SIZE
    
    var style := StyleBoxFlat.new()
    style.corner_radius_top_left = 10
    style.corner_radius_top_right = 10
    style.corner_radius_bottom_left = 10
    style.corner_radius_bottom_right = 10
    style.content_margin_left = 10
    style.content_margin_right = 10
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    style.border_width_left = 3
    
    var gen: int = node_data.get("generation", 0)
    match gen:
        0: style.bg_color = NODE_COLOR_ROOT; style.border_color = Color("#D4A520")
        1: style.bg_color = NODE_COLOR_HYBRID; style.border_color = Color("#5D9C6E")
        2:
            if "绿崽" in str(node_data.get("name", "")):
                style.bg_color = NODE_COLOR_GREEN; style.border_color = Color("#388E3C")
            else:
                style.bg_color = NODE_COLOR_FUR; style.border_color = Color("#D2691E")
        3: style.bg_color = NODE_COLOR_GREEN; style.border_color = Color("#2E7D32")
        4: style.bg_color = NODE_COLOR_FINAL; style.border_color = Color("#FFA000")
    
    panel.add_theme_stylebox_override("panel", style)
    
    var vbox := VBoxContainer.new()
    
    var name_label := Label.new()
    name_label.text = node_data.get("name", "")
    name_label.add_theme_font_size_override("font_size", 13)
    name_label.add_theme_color_override("font_color", Color("#3E2723"))
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(name_label)
    
    var title_label := Label.new()
    title_label.text = node_data.get("title", "")
    title_label.add_theme_font_size_override("font_size", 11)
    title_label.add_theme_color_override("font_color", Color("#5D4037"))
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title_label)
    
    panel.mouse_entered.connect(_on_node_hover.bind(panel, node_data))
    panel.mouse_exited.connect(_on_node_unhover.bind(panel))
    
    panel.add_child(vbox)
    return panel


func _on_node_hover(panel: PanelContainer, node_data: Dictionary) -> void:
    var bio: String = node_data.get("bio", "")
    if bio == "":
        return
    
    var tooltip := PanelContainer.new()
    tooltip.name = "Tooltip"
    var ts := StyleBoxFlat.new()
    ts.bg_color = Color("#FFF8E1")
    ts.corner_radius_top_left = 6
    ts.corner_radius_top_right = 6
    ts.corner_radius_bottom_left = 6
    ts.corner_radius_bottom_right = 6
    ts.content_margin_left = 10
    ts.content_margin_right = 10
    ts.content_margin_top = 6
    ts.content_margin_bottom = 6
    tooltip.add_theme_stylebox_override("panel", ts)
    
    var tip_label := Label.new()
    tip_label.text = bio
    tip_label.add_theme_font_size_override("font_size", 13)
    tip_label.add_theme_color_override("font_color", Color("#5D4037"))
    tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    tip_label.custom_minimum_size = Vector2(220, 0)
    tooltip.add_child(tip_label)
    
    tooltip.position = panel.position + Vector2(panel.size.x + 10, 0)
    panel.get_parent().add_child(tooltip)


func _on_node_unhover(panel: PanelContainer) -> void:
    var parent := panel.get_parent()
    if parent:
        var tip := parent.get_node_or_null("Tooltip")
        if tip:
            tip.queue_free()


func _on_back() -> void:
    if GameState.all_documents_complete and not GameState.final_seed_collected:
        get_tree().change_scene_to_file("res://scenes/ending.tscn")
    else:
        get_tree().change_scene_to_file("res://scenes/main_investigation.tscn")


func _make_spacer() -> Control:
    var s := Control.new()
    s.size_flags_horizontal = Control.SIZE_EXPAND
    return s

func _make_sep() -> HSeparator:
    var s := HSeparator.new()
    s.add_theme_constant_override("separation", 12)
    return s
