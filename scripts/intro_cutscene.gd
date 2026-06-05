extends Control

## 片头动画 - 外星人绑架与任务简报

var _story_data: StoryData
var _text_index: int = 0
var _text_lines: Array[String] = []
var _text_label: RichTextLabel
var _continue_label: Label

# 逐个文字显示的速度
const CHAR_SPEED := 0.03
var _char_tween: Tween


func _ready() -> void:
    _story_data = StoryData.new()
    _story_data.load_data()
    
    var intro := _story_data.get_intro_text()
    _text_lines = _split_into_lines(intro)
    
    _setup_ui()
    _play_intro()


func _split_into_lines(text: String) -> Array[String]:
    var lines: Array[String] = []
    var paragraphs := text.split("\n")
    for para in paragraphs:
        var trimmed := para.strip_edges()
        if trimmed != "":
            lines.append(trimmed)
    return lines


func _setup_ui() -> void:
    # 深色背景
    var bg := ColorRect.new()
    bg.color = Color("#1a1520")
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    
    # 温暖光晕
    var glow := ColorRect.new()
    glow.color = Color("#E8C56D", 0.08)
    glow.set_anchors_preset(Control.PRESET_FULL_RECT)
    glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(glow)
    
    # 文本容器
    var text_container := MarginContainer.new()
    text_container.set_anchors_preset(Control.PRESET_FULL_RECT)
    text_container.add_theme_constant_override("margin_left", 100)
    text_container.add_theme_constant_override("margin_top", 60)
    text_container.add_theme_constant_override("margin_right", 100)
    text_container.add_theme_constant_override("margin_bottom", 60)
    add_child(text_container)
    
    var vbox := VBoxContainer.new()
    vbox.size_flags_vertical = Control.SIZE_EXPAND
    text_container.add_child(vbox)
    
    # 标题
    var title := Label.new()
    title.text = "🌌 蒲公英号 · 最后的信号"
    title.add_theme_font_size_override("font_size", 30)
    title.add_theme_color_override("font_color", Color("#FFD700"))
    vbox.add_child(title)
    vbox.add_child(_make_sep())
    
    # 文本
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND
    
    _text_label = RichTextLabel.new()
    _text_label.bbcode_enabled = true
    _text_label.fit_content = true
    _text_label.add_theme_font_size_override("normal_font_size", 18)
    _text_label.add_theme_color_override("default_color", Color("#D7CCC8"))
    _text_label.scroll_active = false
    scroll.add_child(_text_label)
    vbox.add_child(scroll)
    
    # 继续提示
    _continue_label = Label.new()
    _continue_label.text = ""
    _continue_label.add_theme_font_size_override("font_size", 16)
    _continue_label.add_theme_color_override("font_color", Color("#FFD700"))
    _continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(_continue_label)
    
    # 跳过按钮
    var skip_btn := Button.new()
    skip_btn.text = "跳过 >>"
    skip_btn.add_theme_font_size_override("font_size", 14)
    skip_btn.flat = true
    skip_btn.add_theme_color_override("font_color", Color("#757575"))
    skip_btn.pressed.connect(_on_skip)
    skip_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    skip_btn.position = Vector2(1150, 10)
    add_child(skip_btn)


func _play_intro() -> void:
    if _text_index < _text_lines.size():
        _typewriter_effect(_text_lines[_text_index])
    else:
        _show_continue_button()


func _typewriter_effect(line: String) -> void:
    _text_label.text = ""
    
    if _char_tween and _char_tween.is_valid():
        _char_tween.kill()
    
    _char_tween = create_tween()
    var display_text := ""
    
    for i in line.length():
        display_text += line[i]
        var captured := display_text
        _char_tween.tween_callback(func(): _text_label.text = captured).set_delay(CHAR_SPEED)
    
    _char_tween.tween_callback(func():
        _text_index += 1
        _show_continue_prompt()
    )


func _show_continue_prompt() -> void:
    _continue_label.text = "[ 点击继续 ]"
    
    # 闪烁效果
    var blink := create_tween()
    blink.set_loops()
    blink.tween_property(_continue_label, "modulate:a", 0.3, 0.6)
    blink.tween_property(_continue_label, "modulate:a", 1.0, 0.6)


func _show_continue_button() -> void:
    _continue_label.text = "[ 开始调查 → ]"
    _continue_label.add_theme_color_override("font_color", Color("#FFD700"))


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        if _text_index < _text_lines.size():
            # 跳过当前打字效果
            if _char_tween and _char_tween.is_valid():
                _char_tween.kill()
            _text_label.text = _text_lines[_text_index]
            _text_index += 1
            _show_continue_prompt()
            
            if _text_index >= _text_lines.size():
                _show_continue_button()
        else:
            # 进入主调查
            _on_skip()


func _on_skip() -> void:
    GameState.has_seen_intro = true
    GameState.start_investigation()
    get_tree().change_scene_to_file("res://scenes/main_investigation.tscn")


func _make_sep() -> HSeparator:
    var s := HSeparator.new()
    s.add_theme_constant_override("separation", 12)
    return s
