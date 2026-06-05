# 🐕 小狗与草籽 · Puppy & Grass Seed

> 一则关于星际推理、狗文明与生命种子的温暖故事

![Godot](https://img.shields.io/badge/Godot-4.3-478CBF?logo=godot-engine)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-prototype-orange)

## 📖 剧情背景

你被一个植物系外星文明绑架了。它们看中了你的推理天赋，委托你调查一支失联多年的宇宙探险队——「蒲公英号」。

探险队最后传回的消息是：它们被一种狗型智慧生物收留了。

外星人给了你**五份狗文明档案**。你的任务：按顺序调查五份文档，通过检索关键词获取隐藏线索，层层推理——
- 探险队员究竟去了哪里？
- 它们的后代谱系是怎样的？
- 那颗象征着希望的**种子**，还在吗？

## 🎮 玩法机制

### 关键词检索系统（灵感来源：《Return of the Obra Dinn》）

1. **阅读档案**：每份档案包含大量文本，其中嵌入了高亮关键词
2. **点击检索**：点击红色关键词 → 解锁对应线索，关键词变绿
3. **收集线索**：每条线索都是推理拼图的一部分
4. **完成档案**：找到足够的关键线索后即可标记档案完成，解锁下一份
5. **谱系拼图**：所有档案的调查线索会逐步填充后代谱系图
6. **带回种子**：找到最后的混种后代——「小狗与草籽」

### 五份档案（按顺序解锁）

| # | 档案 | 文明 | 简介 |
|---|------|------|------|
| 1 | 牧歌草原 | 🐑 边牧议会 | 极致理性的逻辑文明，曾为探险队重新计算航道 |
| 2 | 腊肠犬丘陵 | 🌭 丘陵商会 | 地下贸易霸主，探险队用种子换取通行证 |
| 3 | 育种洞窟 | 🐾 柯基育幼所 | 生命科学的圣地，跨物种基因融合在此发生 |
| 4 | 雪原哨站 | 🛷 哈士奇前哨 | 忠诚守卫者，用嚎叫传承记录了混种后代的迁徙 |
| 5 | 金毛港湾 | 🏠 金色归途 | 温暖的终点，蒲公英号后代的最终归宿 |

## 🎨 美术风格

- **三渲二（Cel-Shading）**：通过着色器对画面进行色彩量化处理
- **厚涂风（Impasto）**：模拟画笔笔触的纹理质感
- **温馨插画风**：暖色调 + 纸张质感 + 暗角效果
- 着色器位于 `assets/shaders/painterly_style.gdshader`

## 🚀 如何运行

### 前置要求

- [Godot Engine 4.3+](https://godotengine.org/download)

### 步骤

```bash
# 1. 克隆仓库
git clone https://github.com/YOUR_USERNAME/puppy-and-grass-seed.git
cd puppy-and-grass-seed

# 2. 用 Godot 打开项目
#    启动 Godot → 导入 → 选择项目文件夹中的 project.godot

# 3. 运行
#    按 F5 或点击右上角「运行项目」
```

### 首次导入注意事项

1. 如果提示缺少字体，Godot 会使用默认字体，无需额外操作
2. 项目使用 Forward+ 渲染器，着色器为 CanvasItem 类型（2D）
3. 最低分辨率：1280×720

## 📁 项目结构

```
小狗与草籽/
├── project.godot                 # 项目配置
├── .gitignore
├── README.md
├── assets/
│   ├── fonts/                    # 字体（可自定义添加）
│   ├── images/                   # 图片资源
│   ├── sounds/                   # 音效和BGM
│   └── shaders/
│       └── painterly_style.gdshader   # 三渲二厚涂风着色器
├── scenes/
│   ├── title_screen.tscn         # 标题画面
│   ├── intro_cutscene.tscn       # 片头剧情
│   ├── main_investigation.tscn   # 主调查界面（档案选择）
│   ├── document_viewer.tscn      # 文档阅读器（核心玩法）
│   ├── pedigree_view.tscn        # 后代谱系图
│   └── ending.tscn               # 结局
├── scripts/
│   ├── autoload/
│   │   ├── game_state.gd         # 全局游戏状态
│   │   └── audio_manager.gd      # 音频管理
│   ├── data_loader.gd            # 剧情数据加载器
│   ├── title_screen.gd
│   ├── intro_cutscene.gd
│   ├── main_investigation.gd
│   ├── document_viewer.gd        # 关键词检索核心逻辑
│   ├── pedigree_view.gd
│   └── ending.gd
└── data/
	└── story_data.cfg            # 全部剧情文本和关键词数据
```

## 🔧 自定义剧情

所有剧情数据集中在 `data/story_data.cfg` 中，使用 Godot ConfigFile 格式。

### 添加新关键词

在对应档案的 `[document.X.keyword.N]` 段落中添加：

```ini
[document.0.keyword.10]
id = "my_keyword"
text = "关键词文本"
clue = "点击关键词后显示的推理线索"
```

### 修改完成条件

修改每个档案的 `required_keywords_for_completion` 字段。

## 🗺️ 开发路线图

- [x] 核心玩法框架（文档阅读器 + 关键词检索）
- [x] 五份档案剧情数据
- [x] 后代谱系视图
- [x] 三渲二厚涂风着色器
- [x] 片头/结局场景
- [ ] 美术资源（插画、图标、动画）
- [ ] 音效和背景音乐
- [ ] 本地化支持（英文版）
- [ ] 存档系统
- [ ] 更多的交互反馈和粒子特效

## 📄 许可

MIT License

---

*"碳基推理者，带种子回家吧。" —— 根长老*
