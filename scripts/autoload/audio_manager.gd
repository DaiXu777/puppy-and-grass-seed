extends Node

## 音频管理器 (Autoload) - 管理背景音乐与音效

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var current_bgm: String = ""
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var is_muted: bool = false


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    music_player = AudioStreamPlayer.new()
    music_player.bus = &"Music" if AudioServer.get_bus_index("Music") >= 0 else &"Master"
    add_child(music_player)
    
    sfx_player = AudioStreamPlayer.new()
    sfx_player.bus = &"SFX" if AudioServer.get_bus_index("SFX") >= 0 else &"Master"
    add_child(sfx_player)


func play_bgm(stream: AudioStream, fade_in: float = 1.0) -> void:
    if is_muted: return
    music_player.stream = stream
    music_player.volume_db = linear_to_db(music_volume)
    music_player.play(fade_in)


func play_sfx(stream: AudioStream) -> void:
    if is_muted: return
    sfx_player.stream = stream
    sfx_player.volume_db = linear_to_db(sfx_volume)
    sfx_player.play()


func stop_bgm(fade_out: float = 1.0) -> void:
    if music_player.playing:
        var tween = create_tween()
        tween.tween_property(music_player, "volume_db", -80, fade_out)
        tween.tween_callback(music_player.stop)


func set_music_volume(vol: float) -> void:
    music_volume = clampf(vol, 0.0, 1.0)
    music_player.volume_db = linear_to_db(music_volume)


func set_sfx_volume(vol: float) -> void:
    sfx_volume = clampf(vol, 0.0, 1.0)
    sfx_player.volume_db = linear_to_db(sfx_volume)


func toggle_mute() -> void:
    is_muted = not is_muted
    if is_muted:
        music_player.volume_db = -80
        sfx_player.volume_db = -80
    else:
        music_player.volume_db = linear_to_db(music_volume)
        sfx_player.volume_db = linear_to_db(sfx_volume)
