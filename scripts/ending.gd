extends Control

## 结局场景 - 带回种子，返回母星

var _text_index: int = 0
var _ending_lines: Array[String] = []
var _text_label: RichTextLabel
var _continue_label: Label

const ENDING_TEXT := """你站在金毛港湾的向阳山坡上。

远处，金色的海浪轻轻拍打着沙滩。近处，蒲公英色的花朵在微风中摇曳。

一只金毛寻回犬叼着一个小小的种荚向你走来。它把种荚轻轻放在你的手心，用湿润的鼻子蹭了蹭你的手指。

"这就是它们留下的。"金毛犬的吠声通过翻译器传入你的耳中。
"小狗与草籽——它们的后代，也是我们的孩子。"

你低头看着手中的种荚。它温暖而光滑，表面泛着淡淡的金色绒毛。

在你的触感中，种荚微微裂开——一株嫩绿的新芽探出头来。
它有着植物的叶片，叶缘却生长着细密柔软的绒毛，像小狗的耳朵。

根长老的孢子在你耳边振动：
"带它回家吧，碳基推理者。你完成了我们的委托。"

你抬头望向星空。三百光年外的母星，正等待着这颗种子的归来。

而你知道——这不是结束。

在蒲公英号曾经走过的五个狗文明之间，草犬混种的后代们正在茁壮成长。
它们有自己的故事，有自己的归宿。

而你，只是为这个温暖的故事画上了一个分号。

—— END ——"""


func _ready() -> void:
    _ending_lines = ENDING_TEXT.split("\n")
    _setup_ui()
    _play_ending()


func _setup_ui() -> void:
    # 温暖夕阳背景
    var bg := ColorRect.new()
    bg.color = Color("#2D1B00")
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    
    # 金色光晕
    var glow := ColorRect.new()
    glow.color = Color("#FFD700", 0.1)
    glow.set_anchors_preset(Control.PRESET_FULL_RECT)
    glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(glow)
    
    var text_container := MarginContainer.new()
    text_container.set_anchors_preset(Control.PRESET_FULL_RECT)
    text_container.add_theme_constant_override("margin_left", 120)
    text_container.add_theme_constant_override("margin_top", 50)
    text_container.add_theme_constant_override("margin_right", 120)
    text_container.add_theme_constant_override("margin_bottom", 50)
    add_child(text_container)
    
    var vbox := VBoxContainer.new()
    vbox.size_flags_vertical = Control.SIZE_EXPAND
    text_container.add_child(vbox)
    
    var title := Label.new()
    title.text = "🌅 小狗与草籽 · 归途"
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color("#FFD700"))
    vbox.add_child(title)
    vbox.add_child(_make_sep())
    
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND
    
    _text_label = RichTextLabel.new()
    _text_label.bbcode_enabled = true
    _text_label.fit_content = true
    _text_label.add_theme_font_size_override("normal_font_size", 18)
    _text_label.add_theme_color_override("default_color", Color("#FFE0B2"))
    _text_label.scroll_active = false
    scroll.add_child(_text_label)
    vbox.add_child(scroll)
    
    _continue_label = Label.new()
    _continue_label.text = ""
    _continue_label.add_theme_font_size_override("font_size", 16)
    _continue_label.add_theme_color_override("font_color", Color("#FFD700"))
    _continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(_continue_label)
    
    # 重新开始按钮
    var restart_btn := Button.new()
    restart_btn.text = "🔄 重新开始"
    restart_btn.add_theme_font_size_override("font_size", 16)
    restart_btn.flat = true
    restart_btn.add_theme_color_override("font_color", Color("#8D6E63"))
    restart_btn.pressed.connect(_on_restart)
    restart_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    restart_btn.position = Vector2(1120, 10)
    add_child(restart_btn)


func _play_ending() -> void:
    GameState.final_seed_collected = true
    if _text_index < _ending_lines.size():
        _typewriter_line(_ending_lines[_text_index])
    else:
        _continue_label.text = "[ 感谢游玩 ♥ ]"


func _typewriter_line(line: String) -> void:
    _text_label.text = ""
    var tween := create_tween()
    var display := ""
    for i in line.length():
        display += line[i]
        var captured := display
        tween.tween_callback(func(): _text_label.text = captured).set_delay(0.04)
    tween.tween_callback(func():
        _text_index += 1
        _continue_label.text = "[ 点击继续 ]"
    )


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        if _text_index < _ending_lines.size():
            _text_label.text = _ending_lines[_text_index]
            _text_index += 1
            _continue_label.text = "[ 点击继续 ]" if _text_index < _ending_lines.size() else "[ 感谢游玩 ♥ ]"
        else:
            pass


func _on_restart() -> void:
    GameState.reset_game()
    get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _make_sep() -> HSeparator:
    var s := HSeparator.new()
    s.add_theme_constant_override("separation", 12)
    return s
