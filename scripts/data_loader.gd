extends RefCounted
class_name StoryData

## 剧情数据管理器
## 解析 story_data.json 并提供结构化访问接口

const DATA_PATH := "res://data/story_data.json"

var _documents: Array = []
var _pedigree: Dictionary = {}
var _global_text: Dictionary = {}


func load_data() -> void:
    var file := FileAccess.open(DATA_PATH, FileAccess.READ)
    if file == null:
        printerr("Failed to open story data: ", DATA_PATH)
        return
    
    var text := file.get_as_text()
    file.close()
    
    var json := JSON.new()
    var err := json.parse(text)
    if err != OK:
        printerr("Failed to parse story data JSON: ", json.get_error_message())
        return
    
    var data: Dictionary = json.get_data()
    if data.is_empty():
        printerr("Story data is empty")
        return
    
    _global_text = data.get("global", {})
    _documents = data.get("documents", [])
    _pedigree = data.get("pedigree", {})


## --- Public API ---

func get_intro_text() -> String:
    return _global_text.get("intro_text", "")


func get_document(index: int) -> Dictionary:
    if index >= 0 and index < _documents.size():
        return _documents[index]
    return {}


func get_document_count() -> int:
    return _documents.size()


func get_document_title(index: int) -> String:
    var doc := get_document(index)
    return doc.get("title", "")


func get_document_keywords(index: int) -> Array:
    var doc := get_document(index)
    return doc.get("keywords", [])


func get_document_text(index: int) -> String:
    var doc := get_document(index)
    return doc.get("text", "")


func get_document_required_keywords(index: int) -> Array:
    var doc := get_document(index)
    return doc.get("required_keywords", [])


func get_keyword_clue(doc_index: int, kw_id: String) -> String:
    for kw in get_document_keywords(doc_index):
        if kw.get("id") == kw_id:
            return kw.get("clue", "")
    return ""


func get_all_pedigree_nodes() -> Dictionary:
    return _pedigree


func get_pedigree_node(node_id: String) -> Dictionary:
    return _pedigree.get(node_id, {})
