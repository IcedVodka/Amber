AtimeLog2 开发文档 (Lyubishchev Edition)
1. 核心理念与范围
哲学：柳比歇夫时间统计法。关注时间的质（纯时间 + 权重），而非单纯的流水账。

核心形态：Unified Stream (统一流)。将“时间记录（定量）”与“日记随笔（定性）”融合在同一条时间轴上。

交互原则：

当下 (Focus Now)：通过计时器捕捉高价值工作的纯时间（需手动暂停过滤水分）。

过时不候 (Today Only)：原则上只允许操作当天数据，强化“今日事今日毕”的心理约束。

文本优先 (Text First)：通过底部命令栏快速补录或记录随笔。

2. 数据存储架构 (JSON)
2.1 目录结构
Plaintext

<app_dir>/
  meta.json                 # 全局元数据
  current/
    categories.json         # 分类配置（含默认权重）
    session.json            # 灾备：当前正在运行的计时器状态
  data/
    2025-01/
      2025-01-12.json     # 核心：每日数据文件
2.2 数据文件定义
A. current/categories.json
增加 defaultWeight 字段，用于自动计算效率。

JSON

{
  "lastModified": 1736647200000,
  "items": [
    {
      "id": "coding",
      "name": "编程开发",
      "icon": "code",
      "color": "#FF5722",
      "defaultWeight": 1.0,  // 高价值
      "order": 1
    },
    {
      "id": "commute",
      "name": "通勤",
      "icon": "train",
      "color": "#9E9E9E",
      "defaultWeight": 0.3,  // 低价值
      "order": 2
    }
  ]
}
B. data/yyyy-mm/yyyy-mm-dd.json (核心)
采用多态结构，items 数组中混合存储 record 和 note。

JSON

{
  "date": "2025-01-12",
  "items": [
    {
      "type": "record",
      "id": "uuid-001",
      "categoryId": "coding",
      "content": "AtimeLog2 架构重构",
      "startAt": "2025-01-12T09:00:00+08:00",  // 物理开始
      "endAt": "2025-01-12T11:00:00+08:00",    // 物理结束
      "durationSec": 6300,                     // 纯时间 (扣除暂停)
      "weight": 1.0                            // 最终权重
    },
    {
      "type": "note",
      "id": "uuid-002",
      "createdAt": 1736647200000,              // 毫秒时间戳
      "content": "中午吃的太饱，效率有点低，下午要注意。"
    }
  ]
}
C. current/session.json (灾备)
用于 App 被杀后恢复计时器状态。

JSON

{
  "isRunning": true,
  "categoryId": "coding",
  "content": "AtimeLog2",
  "startAt": "2025-01-12T09:00:00+08:00", 
  "accumulatedSec": 300,        // 暂停前已积累的时长
  "lastResumeAt": 1736647500000 // 最近一次恢复的时间点 (ms)
}
3. 领域模型定义 (Dart Models)
3.1 基础多态类 TimelineItem
Dart

enum ItemType { record, note }

abstract class TimelineItem {
  final String id;
  // 用于排序：Note取createdAt, Record取startAt
  DateTime get sortTime; 
  
  TimelineItem({required this.id});
  
  Map<String, dynamic> toJson();
  
  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'record') return TimeRecord.fromJson(json);
    if (json['type'] == 'note') return Note.fromJson(json);
    throw Exception('Unknown type');
  }
}
3.2 随笔模型 Note
Dart

class Note extends TimelineItem {
  final String content;
  final DateTime createdAt;

  Note({
    required String id,
    required this.content,
    required this.createdAt,
  }) : super(id: id);

  @override
  DateTime get sortTime => createdAt;
  
  // toJson / fromJson ...
}
3.3 记录模型 TimeRecord
包含柳比歇夫计算逻辑。

Dart

class TimeRecord extends TimelineItem {
  final String categoryId;
  final String content;
  final DateTime startAt;
  final DateTime endAt;
  final int durationSec; // 纯时间
  final double weight;

  TimeRecord({
    required String id,
    required this.categoryId,
    required this.content,
    required this.startAt,
    required this.endAt,
    required this.durationSec,
    required this.weight,
  }) : super(id: id);

  @override
  DateTime get sortTime => startAt;

  // 计算属性：有效产出时间
  double get effectiveSec => durationSec * weight;
  
  // 计算属性：物理流逝时间
  int get wallClockSec => endAt.difference(startAt).inSeconds;
}
4. 业务逻辑与状态管理 (Logic)
4.1 输入解析器 (Smart Input Parser)
负责将底部输入框的文本转换为 TimeRecord 或 Note。

Regex 逻辑：

模式：^#(\S+)\s+(.+?)(\s+(\d+)[hH:]((\d+)[mM]?)?)?(\s*\*([\d\.]+))?$

说明：捕获 #分类、内容、可选的时长、可选的*权重。

处理流程：

输入字符串 text。

如果 text 不以 # 开头 -> 生成 Note，createdAt = Now。

如果以 # 开头 -> 解析分类 ID。

如果有时长 (e.g., 1h30m) -> 生成 TimeRecord (补录模式)，startAt 倒推或设为当前，endAt 设为当前。

如果没有时长 -> 视为错误或纯文本Note (根据你的需求，建议如果不带时长，提示用户或转为Note)。

4.2 计时器控制器 (TimerController)
核心状态机，必须处理好“暂停”带来的时间差。

State:

Dart

class TimerState {
  final bool isRunning;
  final DateTime? startAt;
  final int accumulatedSec; // 之前积攒的
  final DateTime? lastResumeAt; // 最近一次开始的时刻

  // Getter: 实时显示的时间
  int get currentDuration {
    if (!isRunning) return accumulatedSec;
    return accumulatedSec + DateTime.now().difference(lastResumeAt!).inSeconds;
  }
}
Actions:

start(category, content): 初始化状态，写 session.json。

pause(): accumulatedSec += now - lastResumeAt，isRunning = false，更新 session.json。

resume(): lastResumeAt = now，isRunning = true，更新 session.json。

stop(): 读取 currentDuration，生成 TimeRecord，追加到当日 json，清空 session.json。

5. UI/UX 设计规范 (Three-Zone Layout)
页面结构：Scaffold -> Column (Header, Expanded List, Bottom Input)。

Zone A: 顶部控制区 (Focus Pannel)
Idle Mode (空闲)：

GridView：展示 Categories。

点击 Icon -> 弹窗输入 Content -> 调用 TimerController.start。

Running Mode (计时)：

背景色：取 Category 颜色。

中央大字：Ticket(builder: (context) => Text(format(timer.currentDuration)))。

下方按钮行：Pause/Resume (Icon Button), Stop (Solid Button)。

Zone B: 统一时间流 (Timeline)
ListView.builder 渲染 List<TimelineItem>。

Item 1: NoteTile:

布局：Row(TimeText, VerticalLine, ContentText).

样式：淡雅，文字为主。

Item 2: RecordTile:

布局：Card 或 Container。

左边框：Container(width: 4, color: categoryColor).

内容：

Title: [Icon] Category Name

Subtitle: Content

Trailing: 1h 20m (Bold) | Eff: 1.0 (Small).

Zone C: 智能输入栏 (Smart Input)
组件：Stack (输入框在下，建议列表在上)。

交互逻辑：

TextField 监听 onChanged。

如果 text.endsWith("#") 或正在输入 tag -> 显示 OverlayEntry (Tag Suggestions)。

点击 Tag -> 补全文本 -> 关闭 Overlay。

点击 Send -> 调用 Parser -> Repository.add(item) -> 清空输入框 -> 滚动列表到底部。