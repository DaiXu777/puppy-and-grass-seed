extends Node

## 游戏全局状态管理器 (Autoload)
## 管理文档进度、已解锁线索、谱系进度等核心状态

# 文档进度 (0=未开始, 1=调查中, 2=完成)
var document_progress: Array[int] = [0, 0, 0, 0, 0]
var current_document_index: int = -1

# 关键词与线索
var unlocked_keywords: Dictionary = {}       # { "keyword_id": bool }
var discovered_clues: Array[String] = []     # 已发现的线索描述
var clue_connections: Dictionary = {}        # { "clue_a": ["clue_b"] } 线索关联

# 谱系进度
var pedigree_nodes: Dictionary = {}          # { "node_id": {name, role, parent_of[], child_of, status} }
var pedigree_unlocked: int = 0
var pedigree_total: int = 8                  # 总共有8个关键谱系节点

# 剧情阶段
enum GamePhase {
    TITLE,
    INTRO,
    INVESTIGATION,
    PEDIGREE_REVIEW,
    ENDING
}
var current_phase: int = GamePhase.TITLE

# 标记
var has_seen_intro: bool = false
var all_documents_complete: bool = false
var final_seed_collected: bool = false

# 信号
signal document_unlocked(index: int)
signal document_completed(index: int)
signal keyword_discovered(keyword_id: String)
signal clue_found(clue_text: String)
signal pedigree_node_unlocked(node_id: String)
signal phase_changed(new_phase: int)
signal all_investigation_complete()


func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS


func reset_game() -> void:
    document_progress = [0, 0, 0, 0, 0]
    current_document_index = -1
    unlocked_keywords.clear()
    discovered_clues.clear()
    clue_connections.clear()
    pedigree_nodes.clear()
    pedigree_unlocked = 0
    current_phase = GamePhase.TITLE
    has_seen_intro = false
    all_documents_complete = false
    final_seed_collected = false


func start_investigation() -> void:
    current_phase = GamePhase.INVESTIGATION
    current_document_index = 0
    document_progress[0] = 1
    phase_changed.emit(current_phase)
    document_unlocked.emit(0)


## 标记文档完成
func complete_document(index: int) -> void:
    if index >= 0 and index < document_progress.size():
        document_progress[index] = 2
        document_completed.emit(index)
        
        # 解锁下一个文档
        if index + 1 < document_progress.size():
            document_progress[index + 1] = 1
            current_document_index = index + 1
            document_unlocked.emit(index + 1)
        else:
            all_documents_complete = true
            all_investigation_complete.emit()


## 解锁关键词并返回是否为新发现
func discover_keyword(keyword_id: String) -> bool:
    if not unlocked_keywords.has(keyword_id):
        unlocked_keywords[keyword_id] = true
        keyword_discovered.emit(keyword_id)
        return true
    return false


## 记录新线索
func add_clue(clue_text: String) -> void:
    if clue_text not in discovered_clues:
        discovered_clues.append(clue_text)
        clue_found.emit(clue_text)


## 解锁谱系节点
func unlock_pedigree_node(node_id: String, node_data: Dictionary) -> void:
    if not pedigree_nodes.has(node_id):
        pedigree_nodes[node_id] = node_data
        pedigree_unlocked += 1
        pedigree_node_unlocked.emit(node_id)


func get_document_status(index: int) -> int:
    if index >= 0 and index < document_progress.size():
        return document_progress[index]
    return 0


func can_access_document(index: int) -> bool:
    if index == 0:
        return current_phase >= GamePhase.INVESTIGATION
    return document_progress[index] > 0
