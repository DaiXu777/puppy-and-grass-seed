extends Control

## 主调查界面 - 五份档案的选择大厅
## 顺序解锁，未完成的档案不可访问

var _story_data: StoryData
var _document_cards: Array[Control] = []
var _pedigree_button: Button


func _ready() -> void:
    _story_data = StoryData.new()
    _story_data.load_data()
    
    if not GameState.has_seen_intro:
        GameState.start_investigation()
        GameState.has_seen_intro = true
    
    _setup_ui()
    _refresh_cards()


func _setup_ui() -> void:
    # 温暖纸张背景
    var bg := ColorRect.new()
    bg.color = Color("#FAF3E3")
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    
    # 装饰纹理（模拟厚涂画笔触质感）
    var texture_overlay := ColorRect.new()
    texture_overlay.color = Color(0.95, 0.91, 0.85, 0.3)
    texture_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    texture_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(texture_overlay)
    
    # 主布局
    var main_vbox := VBoxContainer.new()
    main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
    main_vbox.add_theme_constant_override("margin_left", 50)
    main_vbox.add_theme_constant_override("margin_top", 30)
    main_vbox.add_theme_constant_override("margin_right", 50)
    main_vbox.add_theme_constant_override("margin_bottom", 30)
    add_child(main_vbox)
    
    # 顶部标题
    var title_row := HBoxContainer.new()
    
    var title := Label.new()
    title.text = "📋 吠星文明群 · 调查档案"
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color("#3E2723"))
    title_row.add_child(title)
    
    title_row.add_child(_make_spacer())
    
    # 谱系按钮（始终可用）
    _pedigree_button = _make_button("🌿 谱系图", _on_pedigree)
    _pedigree_button.add_theme_font_size_override("font_size", 16)
    title_row.add_child(_pedigree_button)
    
    main_vbox.add_child(title_row)
    main_vbox.add_child(_make_separator())
    
    # 副标题
    var subtitle := Label.new()
    subtitle.text = "外星人给了你五份可能的狗文明档案。按顺序逐一调查，梳理探险队员的去向。"
    subtitle.add_theme_font_size_override("font_size", 15)
    subtitle.add_theme_color_override("font_color", Color("#8D6E63"))
    subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    main_vbox.add_child(subtitle)
    main_vbox.add_child(_make_separator())
    
    # 档案卡片网格
    var grid := GridContainer.new()
    grid.columns = 5
    grid.add_theme_constant_override("h_separation", 20)
    grid.add_theme_constant_override("v_separation", 20)
    grid.size_flags_horizontal = Control.SIZE_EXPAND
    grid.size_flags_vertical = Control.SIZE_EXPAND
    
    for i in range(_story_data.get_document_count()):
        var card := _create_document_card(i)
        _document_cards.append(card)
        grid.add_child(card)
    
    main_vbox.add_child(grid)


func _create_document_card(index: int) -> Control:
    var card := PanelContainer.new()
    card.size_flags_horizontal = Control.SIZE_EXPAND
    card.size_flags_vertical = Control.SIZE_EXPAND
    
    var style := StyleBoxFlat.new()
    style.corner_radius_top_left = 12
    style.corner_radius_top_right = 12
    style.corner_radius_bottom_left = 12
    style.corner_radius_bottom_right = 12
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 20
    style.content_margin_bottom = 20
    
    var status := GameState.get_document_status(index)
    var can_access := GameState.can_access_document(index)
    var cover_color := Color(_story_data.get_document(index).get("cover_color", "#CCCCCC"))
    
    if status == 2:
        style.bg_color = Color(cover_color.r, cover_color.g, cover_color.b, 0.7)
    elif can_access:
        style.bg_color = Color(cover_color.r, cover_color.g, cover_color.b, 0.9)
    else:
        style.bg_color = Color(0.6, 0.6, 0.6, 0.4)
    
    card.add_theme_stylebox_override("panel", style)
    
    # 卡片内容
    var vbox := VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 10)
    
    # 编号
    var number_label := Label.new()
    number_label.text = "档案 %d" % (index + 1)
    number_label.add_theme_font_size_override("font_size", 14)
    number_label.add_theme_color_override("font_color", Color("#FFFFFF" if can_access else "#999999"))
    number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(number_label)
    
    # 状态图标
    var status_icon := Label.new()
    if status == 2:
        status_icon.text = "✅"
    elif can_access:
        status_icon.text = "📖"
    else:
        status_icon.text = "🔒"
    status_icon.add_theme_font_size_override("font_size", 40)
    status_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(status_icon)
    
    # 标题
    var doc := _story_data.get_document(index)
    var doc_title := Label.new()
    doc_title.text = doc.get("title", "")
    doc_title.add_theme_font_size_override("font_size", 16)
    doc_title.add_theme_color_override("font_color", Color("#3E2723" if can_access else "#999999"))
    doc_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    doc_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(doc_title)
    
    # 简介
    var desc := Label.new()
    desc.text = doc.get("description", "")
    desc.add_theme_font_size_override("font_size", 12)
    desc.add_theme_color_override("font_color", Color("#5D4037" if can_access else "#999999"))
    desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(desc)
    
    card.add_child(vbox)
    
    # 点击事件
    if can_access:
        card.gui_input.connect(_on_card_clicked.bind(index))
        card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    
    return card


func _on_card_clicked(event: InputEvent, index: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        GameState.current_document_index = index
        get_tree().change_scene_to_file("res://scenes/document_viewer.tscn")


func _on_pedigree() -> void:
    get_tree().change_scene_to_file("res://scenes/pedigree_view.tscn")


func _refresh_cards() -> void:
    for i in _document_cards.size():
        var can_access := GameState.can_access_document(i)
        var status := GameState.get_document_status(i)
        var doc := _story_data.get_document(i)
        var cover_color := Color(doc.get("cover_color", "#CCCCCC"))
        
        var style := StyleBoxFlat.new()
        style.corner_radius_top_left = 12
        style.corner_radius_top_right = 12
        style.corner_radius_bottom_left = 12
        style.corner_radius_bottom_right = 12
        style.content_margin_left = 16
        style.content_margin_right = 16
        style.content_margin_top = 20
        style.content_margin_bottom = 20
        
        if status == 2:
            style.bg_color = Color(cover_color.r, cover_color.g, cover_color.b, 0.7)
        elif can_access:
            style.bg_color = Color(cover_color.r, cover_color.g, cover_color.b, 0.9)
        else:
            style.bg_color = Color(0.6, 0.6, 0.6, 0.4)
        
        _document_cards[i].add_theme_stylebox_override("panel", style)


# --- 辅助 ---
func _make_button(text: String, callback: Callable) -> Button:
    var btn := Button.new()
    btn.text = text
    btn.pressed.connect(callback)
    return btn

func _make_spacer() -> Control:
    var s := Control.new()
    s.size_flags_horizontal = Control.SIZE_EXPAND
    return s

func _make_separator() -> HSeparator:
    var s := HSeparator.new()
    s.add_theme_constant_override("separation", 16)
    return s
