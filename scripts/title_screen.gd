extends Control

## 标题画面 - 游戏入口

func _ready() -> void:
    _setup_ui()
    # 在标题画面播放时重置游戏状态
    GameState.reset_game()


func _setup_ui() -> void:
    # 星空+暖色渐变背景
    var bg := ColorRect.new()
    bg.color = Color("#1a1a2e")
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    
    # 装饰圆（模拟星球/种子）
    var circle := ColorRect.new()
    circle.color = Color("#E8C56D", 0.15)
    circle.size = Vector2(400, 400)
    circle.pivot_offset = Vector2(200, 200)
    circle.position = Vector2(440, 160)
    _add_rounded_corners(circle, 200)
    add_child(circle)
    
    var circle2 := ColorRect.new()
    circle2.color = Color("#7DCEA0", 0.1)
    circle2.size = Vector2(250, 250)
    circle2.pivot_offset = Vector2(125, 125)
    circle2.position = Vector2(800, 350)
    _add_rounded_corners(circle2, 125)
    add_child(circle2)
    
    # 主容器
    var main_vbox := VBoxContainer.new()
    main_vbox.set_anchors_preset(Control.PRESET_CENTER)
    main_vbox.add_theme_constant_override("separation", 20)
    add_child(main_vbox)
    
    # 游戏标题
    var title := Label.new()
    title.text = "小狗与草籽"
    title.add_theme_font_size_override("font_size", 56)
    title.add_theme_color_override("font_color", Color("#FFD700"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    main_vbox.add_child(title)
    
    # 英文副标题
    var subtitle := Label.new()
    subtitle.text = "Puppy & Grass Seed"
    subtitle.add_theme_font_size_override("font_size", 22)
    subtitle.add_theme_color_override("font_color", Color("#A5D6A7"))
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    main_vbox.add_child(subtitle)
    
    main_vbox.add_child(_make_spacer(20))
    
    # 剧情简介
    var intro := Label.new()
    intro.text = "一则关于星际推理、狗文明与生命种子的温暖故事"
    intro.add_theme_font_size_override("font_size", 16)
    intro.add_theme_color_override("font_color", Color("#BCAAA4"))
    intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    main_vbox.add_child(intro)
    
    main_vbox.add_child(_make_spacer(40))
    
    # 开始按钮
    var start_btn := Button.new()
    start_btn.text = "🌱  开始调查"
    start_btn.add_theme_font_size_override("font_size", 24)
    start_btn.custom_minimum_size = Vector2(250, 60)
    start_btn.pressed.connect(_on_start)
    
    var btn_style := StyleBoxFlat.new()
    btn_style.bg_color = Color("#E8C56D", 0.8)
    btn_style.corner_radius_top_left = 30
    btn_style.corner_radius_top_right = 30
    btn_style.corner_radius_bottom_left = 30
    btn_style.corner_radius_bottom_right = 30
    start_btn.add_theme_stylebox_override("normal", btn_style)
    
    var btn_hover := btn_style.duplicate()
    btn_hover.bg_color = Color("#FFD700", 0.9)
    start_btn.add_theme_stylebox_override("hover", btn_hover)
    
    start_btn.add_theme_color_override("font_color", Color("#3E2723"))
    main_vbox.add_child(start_btn)
    
    main_vbox.add_child(_make_spacer(30))
    
    # 版本信息
    var version := Label.new()
    version.text = "v0.1.0 · 基于Godot 4引擎构建"
    version.add_theme_font_size_override("font_size", 12)
    version.add_theme_color_override("font_color", Color("#616161"))
    version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    main_vbox.add_child(version)


func _on_start() -> void:
    get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn")


func _add_rounded_corners(_rect: ColorRect, _radius: float) -> void:
    # 简单处理：使用样式的圆角
    pass

func _make_spacer(h: float) -> Control:
    var s := Control.new()
    s.custom_minimum_size = Vector2(0, h)
    return s
