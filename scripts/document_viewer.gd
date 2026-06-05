extends Control

## 文档阅读器 - 核心游戏机制
## 展示文档文本，关键词可点击检索，解锁线索

@export var document_index: int = 0

# UI 节点
var _title_label: Label
var _subtitle_label: Label
var _document_text: RichTextLabel
var _clue_panel: PanelContainer
var _clue_label: Label
var _progress_indicator: HBoxContainer
var _keyword_list: VBoxContainer
var _back_button: Button
var _complete_button: Button
var _kw_info_label: Label

# 数据
var _story_data: StoryData
var _document_data: Dictionary = {}
var _found_keywords: Array[String] = []
var _current_clue: String = ""

# 样式
const COLOR_KEYWORD := Color("#C0392B")         # 可点击关键词颜色
const COLOR_KEYWORD_FOUND := Color("#7DCEA0")   # 已发现关键词颜色
const COLOR_PAPER := Color("#FFF8EE")           # 纸张底色
const COLOR_TEXT := Color("#2C1810")             # 文字颜色
const COLOR_CLUE_BG := Color("#FFF3E0")         # 线索提示背景


func _ready() -> void:
    _story_data = StoryData.new()
    _story_data.load_data()
    _setup_ui()
    _load_document()


func _setup_ui() -> void:
    # 设置全屏背景
    var bg := ColorRect.new()
    bg.color = COLOR_PAPER
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    
    # 主容器
    var main_vbox := VBoxContainer.new()
    main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
    main_vbox.add_theme_constant_override("margin_left", 60)
    main_vbox.add_theme_constant_override("margin_top", 40)
    main_vbox.add_theme_constant_override("margin_right", 60)
    main_vbox.add_theme_constant_override("margin_bottom", 40)
    add_child(main_vbox)
    
    # 标题区
    var header := HBoxContainer.new()
    _title_label = Label.new()
    _title_label.add_theme_font_size_override("font_size", 32)
    _title_label.add_theme_color_override("font_color", Color("#3E2723"))
    header.add_child(_title_label)
    
    _subtitle_label = Label.new()
    _subtitle_label.add_theme_font_size_override("font_size", 16)
    _subtitle_label.add_theme_color_override("font_color", Color("#8D6E63"))
    header.add_child(_subtitle_label)
    main_vbox.add_child(header)
    
    # 分隔线
    var sep := HSeparator.new()
    sep.add_theme_constant_override("separation", 20)
    main_vbox.add_child(sep)
    
    # 文档文本区（带滚动）
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND
    scroll.size_flags_horizontal = Control.SIZE_EXPAND
    
    _document_text = RichTextLabel.new()
    _document_text.bbcode_enabled = true
    _document_text.fit_content = true
    _document_text.size_flags_horizontal = Control.SIZE_EXPAND
    _document_text.add_theme_font_size_override("normal_font_size", 18)
    _document_text.add_theme_color_override("default_color", COLOR_TEXT)
    _document_text.selection_enabled = false
    _document_text.scroll_active = false
    _document_text.meta_clicked.connect(_on_keyword_clicked)
    _document_text.meta_hover_started.connect(_on_keyword_hover)
    _document_text.meta_hover_ended.connect(_on_keyword_unhover)
    scroll.add_child(_document_text)
    main_vbox.add_child(scroll)
    
    # 线索面板
    _clue_panel = PanelContainer.new()
    _clue_panel.hide()
    var clue_style := StyleBoxFlat.new()
    clue_style.bg_color = COLOR_CLUE_BG
    clue_style.border_width_left = 4
    clue_style.border_color = Color("#F39C12")
    clue_style.corner_radius_top_left = 8
    clue_style.corner_radius_top_right = 8
    clue_style.corner_radius_bottom_left = 8
    clue_style.corner_radius_bottom_right = 8
    clue_style.content_margin_left = 16
    clue_style.content_margin_right = 16
    clue_style.content_margin_top = 12
    clue_style.content_margin_bottom = 12
    _clue_panel.add_theme_stylebox_override("panel", clue_style)
    
    _clue_label = Label.new()
    _clue_label.add_theme_font_size_override("font_size", 16)
    _clue_label.add_theme_color_override("font_color", Color("#5D4037"))
    _clue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _clue_panel.add_child(_clue_label)
    main_vbox.add_child(_clue_panel)
    
    # 底部按钮区
    var bottom_bar := HBoxContainer.new()
    bottom_bar.add_theme_constant_override("separation", 20)
    
    _back_button = _make_button("← 返回档案列表", _on_back)
    bottom_bar.add_child(_back_button)
    
    bottom_bar.add_child(_make_spacer())
    
    # 已发现关键词统计
    var kw_info := Label.new()
    kw_info.name = "KeywordInfo"; _kw_info_label = kw_info
    kw_info.add_theme_font_size_override("font_size", 14)
    kw_info.add_theme_color_override("font_color", Color("#9E9E9E"))
    bottom_bar.add_child(kw_info)
    
    _complete_button = _make_button("✓ 完成调查", _on_complete)
    _complete_button.disabled = true
    _complete_button.add_theme_color_override("font_color", Color("#999999"))
    bottom_bar.add_child(_complete_button)
    
    main_vbox.add_child(bottom_bar)


func _load_document() -> void:
    document_index = GameState.current_document_index
    _document_data = _story_data.get_document(document_index)
    if _document_data.is_empty():
        return
    
    _title_label.text = _document_data.get("title", "")
    _subtitle_label.text = _document_data.get("subtitle", "")
    
    # 渲染文档文本，关键词用 BBCode 高亮
    _render_document_text()


func _render_document_text() -> void:
    var raw_text: String = _document_data.get("text", "")
    var keywords: Array = _document_data.get("keywords", [])
    
    var bbcode_text := raw_text
    
    for kw in keywords:
        var kw_id: String = kw.get("id", "")
        var kw_text: String = kw.get("text", "")
        var is_found := kw_id in _found_keywords or GameState.unlocked_keywords.has(kw_id)
        
        if kw_text in bbcode_text:
            if is_found:
                # 已发现关键词：绿色 + 删除线风格
                var replacement := "[color=#7DCEA0][url=%s]%s[/url] ✓[/color]" % [kw_id, kw_text]
                bbcode_text = bbcode_text.replace(kw_text, replacement)
            else:
                # 未发现关键词：红色 + 点击提示
                var replacement := "[color=#C0392B][url=%s]%s[/url][/color]" % [kw_id, kw_text]
                bbcode_text = bbcode_text.replace(kw_text, replacement)
    
    _document_text.text = bbcode_text
    _update_progress()


func _on_keyword_clicked(meta: String) -> void:
    var kw_id := str(meta)
    
    # 如果已发现，不重复处理
    if kw_id in _found_keywords or GameState.unlocked_keywords.has(kw_id):
        # 但依然显示线索
        var cached_clue := _story_data.get_keyword_clue(document_index, kw_id)
        if cached_clue != "":
            _show_clue(cached_clue)
        return
    
    # 新发现！
    _found_keywords.append(kw_id)
    
    var clue_text := _story_data.get_keyword_clue(document_index, kw_id)
    if clue_text != "":
        GameState.add_clue(clue_text)
        GameState.discover_keyword(kw_id)
        _show_clue(clue_text)
        _play_discovery_effect()
    
    # 重新渲染以更新关键词颜色
    _render_document_text()
    
    # 检查是否可以完成文档
    _check_completion()


func _on_keyword_hover(meta: String) -> void:
    # 鼠标悬停时显示小手
    pass


func _on_keyword_unhover(meta: String) -> void:
    pass


func _show_clue(text: String) -> void:
    _clue_label.text = "🔍 " + text
    _clue_panel.show()
    
    # 淡入动画
    _clue_panel.modulate.a = 0
    var tween := create_tween()
    tween.tween_property(_clue_panel, "modulate:a", 1.0, 0.3)
    
    # 5秒后自动隐藏
    tween = create_tween()
    tween.tween_interval(8.0)
    tween.tween_property(_clue_panel, "modulate:a", 0.0, 0.5)
    tween.tween_callback(_clue_panel.hide)


func _play_discovery_effect() -> void:
    # 简易发现特效 - 可以在后续加入粒子效果
    var flash := ColorRect.new()
    flash.color = Color(1, 0.9, 0.5, 0.3)
    flash.set_anchors_preset(Control.PRESET_FULL_RECT)
    flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(flash)
    
    var tween := create_tween()
    tween.tween_property(flash, "color:a", 0.0, 0.5)
    tween.tween_callback(flash.queue_free)


func _update_progress() -> void:
    var total := _document_data.get("required_keywords", []).size()
    var found := 0
    for req_id in _document_data.get("required_keywords", []):
        if req_id in _found_keywords or GameState.unlocked_keywords.has(req_id):
            found += 1
    
    var kw_info := _kw_info_label
    if kw_info:
        kw_info.text = "关键线索: %d/%d" % [found, total]
    
    _complete_button.disabled = (found < total and total > 0)


func _check_completion() -> void:
    var total := _document_data.get("required_keywords", []).size()
    var found := 0
    for req_id in _document_data.get("required_keywords", []):
        if req_id in _found_keywords or GameState.unlocked_keywords.has(req_id):
            found += 1
    
    if total > 0 and found >= total:
        _complete_button.disabled = false
        _complete_button.add_theme_color_override("font_color", Color("#27AE60"))


func _on_back() -> void:
    get_tree().change_scene_to_file("res://scenes/main_investigation.tscn")


func _on_complete() -> void:
    # 完成当前文档，解锁下一个
    GameState.complete_document(document_index)
    
    if GameState.all_documents_complete:
        get_tree().change_scene_to_file("res://scenes/pedigree_review.tscn")
    else:
        get_tree().change_scene_to_file("res://scenes/main_investigation.tscn")


## --- 工厂方法 ---

func _make_button(text: String, callback: Callable) -> Button:
    var btn := Button.new()
    btn.text = text
    btn.add_theme_font_size_override("font_size", 18)
    btn.pressed.connect(callback)
    
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#EFEBE9")
    style.corner_radius_top_left = 6
    style.corner_radius_top_right = 6
    style.corner_radius_bottom_left = 6
    style.corner_radius_bottom_right = 6
    style.content_margin_left = 20
    style.content_margin_right = 20
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    btn.add_theme_stylebox_override("normal", style)
    
    var hover_style := style.duplicate()
    hover_style.bg_color = Color("#D7CCC8")
    btn.add_theme_stylebox_override("hover", hover_style)
    
    return btn


func _make_spacer() -> Control:
    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND
    return spacer
