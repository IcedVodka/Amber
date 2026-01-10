# AtimeLog2 开发文档（Feature-First + MVVM）

## 0. 说明
- 本文档用于指导 AtimeLog2 的后续开发与重构。
- 目标是轻量、易迭代：先跑通核心功能，再逐步扩展。
- 当前只关注本地数据与核心功能，暂不展开同步/备份等内容。

## 1. 目标与范围
- 以“计时/时间记录”为核心，支持桌面与移动端一致体验。
- 采用 Feature-First + MVVM：按功能分包，功能内用 ViewModel 管理状态。
- Core 层只保留通用服务与工具，避免过度设计。
- 数据本地为真；读写逻辑集中在 Repository。

## 2. 当前功能清单
- 计时：开始、暂停、停止、继续、切换分类（含自动停止当前任务）。
- 手动补录：支持跨日拆分与校验。
- 编辑记录：修改开始/结束时间、分类、备注；支持删除记录。
- 重叠校正：none/ask/auto 三种策略（先实现最简单策略）。
- 活动/分类管理：新增、编辑、排序、启用/禁用、软删除。
- 最近上下文：快速开始最近分类与备注，保留累计时长。
- 统计分析：日统计、范围统计、按分类聚合、时间轴查看。
- 设置：主题模式、时间显示、重叠策略。

## 3. 架构原则
- Feature-First：代码按功能归属，避免横向分层过深。
- MVVM：View 只负责渲染；ViewModel 负责状态与业务流程；Repository 负责数据读写。
- 状态管理统一使用 Riverpod v2 + code generation（`@riverpod`），用 `AsyncValue` 处理 Loading/Error/Data。
- Model 兼顾 Entity/DTO，直接用于序列化，保持简单。
- 业务逻辑尽量贴近 Feature；跨 Feature 的共用逻辑放入 Core。
- I/O 只在 Repository/Core 中发生，ViewModel 不直接读写文件。

## 4. 目录结构建议
```text
lib/
  core/
    services/
      file_service.dart        # [核心] 按天读写 JSON
    utils/
      date_utils.dart
  features/
    activity/
      models/
        activity_record.dart
        current_session.dart
      repositories/
        activity_repository.dart
      view_models/
        timer_view_model.dart
        daily_list_view_model.dart
      views/
        activity_page.dart
        history_page.dart
    stats/
      view_models/
        chart_view_model.dart
      views/
        stats_page.dart
    categories/
      models/
        category.dart
      repositories/
        category_repository.dart
      view_models/
        categories_view_model.dart
      views/
        categories_page.dart
    settings/
      models/
        app_settings.dart
      repositories/
        settings_repository.dart
      view_models/
        settings_view_model.dart
      views/
        settings_page.dart
  shared/
    routes/
    widgets/
    theme/
```

## 5. Core 设计
- `core/services/file_service.dart`：统一处理文件路径、按天文件读写、JSON 编解码与容错。
  - 建议提供：`readJson(path)`、`writeJson(path, data)`、`list(path)`。
- `core/utils/date_utils.dart`：日期格式化、日/月 key 计算、跨日拆分辅助。
- `core/services/id_generator.dart`：统一 ID 生成（基于 `uuid`），由 Repository 调用，ViewModel 不直接生成。

## 6. Feature 结构与职责
- `models/`：数据模型（实体/DTO），包含 `fromJson/toJson`。
- `repositories/`：负责调用 Core 的 FileService，提供面向业务的 API。
- `view_models/`：Riverpod 状态管理，负责加载、校验、保存、错误处理。
- `views/`：页面与组件，订阅 ViewModel 状态，触发行为。

## 7. 数据存储格式（本地）

### 7.1 目录结构
```text
<baseDir>/
  meta.json
  current/
    session.json
    categories.json
    settings.json
  data/
    2025-01/
      2025-01-01.json
```

### 7.2 字段约定
- 时间使用 ISO8601 字符串（含时区）：`startAt`、`endAt`。
- `createdAt/updatedAt/lastModified` 使用 epoch ms。
- 删除采用软删除：`deleted=true`。
- `durationSec` 不落盘，按 `endAt - startAt` 计算。
- 跨日活动拆分为单日记录，各记录共享同一 `sessionId`。
- **核心规则：物理存储不跨天**。停止计时时必须拆分：
  1) 23:00 ~ 23:59:59.999（落在当天文件）
  2) 00:00 ~ 01:00（落在次日文件）

### 7.3 示例
`meta.json`：
```json
{
  "app": "AtimeLog2",
  "schemaVersion": 2,
  "deviceId": "device-uuid",
  "createdAt": 1735660800000,
  "timezone": "Asia/Shanghai"
}
```

`current/session.json`：
```json
{
  "schemaVersion": 2,
  "lastModified": 1735660800000,
  "deviceId": "device-uuid",
  "current": {
    "sessionId": "session-uuid",
    "categoryId": "工作",
    "startAt": "2025-01-01T09:00:00.000+08:00",
    "note": ""
  },
  "recents": [
    {
      "categoryId": "工作",
      "note": "",
      "lastUsedAt": 1735660700000,
      "accumulatedSec": 3600
    }
  ]
}
```

`current/categories.json`：
```json
{
  "schemaVersion": 2,
  "lastModified": 1735660800000,
  "items": [
    {
      "id": "工作",
      "name": "工作",
      "iconCode": "briefcase",
      "colorHex": "#FFB000",
      "order": 1,
      "enabled": true,
      "deleted": false
    }
  ]
}
```

`current/settings.json`：
```json
{
  "schemaVersion": 2,
  "lastModified": 1735660800000,
  "themeMode": "system",
  "timeFormat": "24h",
  "overlapPolicy": "ask"
}
```

`data/2025-01/2025-01-01.json`：
```json
{
  "schemaVersion": 2,
  "date": "2025-01-01",
  "lastModified": 1735660800000,
  "records": [
    {
      "id": "record-uuid",
      "sessionId": "session-uuid",
      "categoryId": "工作",
      "startAt": "2025-01-01T09:00:00.000+08:00",
      "endAt": "2025-01-01T10:00:00.000+08:00",
      "note": "工作写代码",
      "createdAt": 1735660700000,
      "updatedAt": 1735660800000,
      "deleted": false,
      "source": "timer"
    }
  ]
}
```

## 8. 基于“垂直切片”策略的里程碑

### 🏁 里程碑 1：配置与主题 (Settings Feature)
**目标**：跑通 Feature-First + MVVM 的完整链路，实现主题切换。
**核心价值**：搭建 FileService，熟悉状态流转。

* **步骤 1.1 (Core)**：实现 `FileService`。
* 使用 `path_provider` 获取路径，实现 `readJson` / `writeJson`。

* **步骤 1.2 (Model)**：定义 `AppSettings`。
* 字段：`themeMode` (System/Light/Dark), `timeFormat` (24h/12h), `overlapPolicy`。

* **步骤 1.3 (Repository)**：实现 `SettingsRepository`。
* 读写 `current/settings.json`，处理首次启动默认值。

* **步骤 1.4 (ViewModel + View)**：
* 创建 `SettingsViewModel`，启动时加载配置。
* `SettingsPage` 放置切换 UI，联动 `MaterialApp.themeMode`。

✅ **验收标准**：重启 App 后，主题模式仍保持上次选择。

---

### 🏁 里程碑 2：分类管理 (Categories Feature)
**目标**：实现分类 CRUD，为计时功能做铺垫。
**核心价值**：处理列表数据与持久化。

* **步骤 2.1 (Model)**：定义 `Category`。
* 字段：`id`, `name`, `colorHex`, `iconCode`, `order`, `enabled`, `deleted`。

* **步骤 2.2 (Repository)**：实现 `CategoryRepository`。
* 读写 `current/categories.json`。

* **步骤 2.3 (ViewModel + List)**：
* `CategoriesViewModel` 负责加载、排序、保存。
* `CategoriesPage` 展示列表（可先不做拖拽）。

* **步骤 2.4 (View - Edit)**：
* 新增/编辑分类的弹窗或页面，颜色用预设色块即可。
* 删除采用软删除（`deleted=true`）。

✅ **验收标准**：可以新建“工作”、“休息”分类并持久化。

---

### 🏁 里程碑 3：核心计时器 (Activity Feature - MVP)
**目标**：实现开始/停止，生成最基础记录。
**核心价值**：处理动态状态与实时 UI。

* **步骤 3.1：内存版计时器**：
* 先做纯内存计时逻辑（开始/暂停/继续/停止），不写文件。
* `TimerViewModel` 负责计时状态，UI 使用 `Ticker` 或 `Stream.periodic` 刷新，**但不要每秒写文件**。

* **步骤 3.2：持久化接入**：
* 定义 `ActivityRecord` 与 `CurrentSession`。
* `ActivityRepository` 处理两个文件：
  1) `current/session.json`（实时保存当前任务）
  2) `data/yyyy-mm/yyyy-mm-dd.json`（停止时写入历史记录）
* 约定：如当前有任务运行，启动新任务时自动停止旧任务。

* **步骤 3.3：应用生命周期处理**：
* 监听 `didChangeAppLifecycleState`，在 `resumed` 时检查 `current/session.json`。
* 如果存在未结束的任务，按 `DateTime.now() - startAt` 计算显示时间，而不是依赖内存计时器。

✅ **验收标准**：开始计时 -> 杀掉 App -> 重启 -> 计时继续正确 -> 停止生成记录。

---

### 🏁 里程碑 4：历史记录与时间轴 (Activity Feature)
**目标**：展示保存的 JSON 数据。
**核心价值**：复杂列表渲染与日期处理。

* **步骤 4.1 (Repository)**：
* 实现 `loadDayRecords(date)`，必要时做跨日拆分辅助。

* **步骤 4.2 (ViewModel + View)**：
* `DailyListViewModel` 提供当天列表数据。
* `HistoryPage` 使用 `ListView` 展示，顶部放日期选择器。

✅ **验收标准**：能看到当天记录列表，时间段与时长计算正确。

---

### 🏁 里程碑 5：补录与编辑 (Refinement)
**目标**：修复错误数据。
**核心价值**：表单处理与重叠时间校验。

* **步骤 5.1 (Activity 内部逻辑)**：
* 在 Activity Feature 内实现重叠检测与简单策略（先做 ask 或 auto 的简化版）。
* 跨日补录拆分逻辑可先放在 Activity 的 helper 中。

* **步骤 5.2 (View)**：
* 历史列表点击记录进入编辑页。
* 首页添加“手动补录”入口，使用 `showTimePicker`。

✅ **验收标准**：可以修改记录备注或调整开始/结束时间。

---

### 🏁 里程碑 6：统计图表 (Stats Feature)
**目标**：数据可视化。
**核心价值**：聚合算法与图表库使用。

* **步骤 6.1 (ViewModel)**：
* `ChartViewModel` 输入 `List<ActivityRecord>`，输出 `Map<Category, Duration>`。

* **步骤 6.2 (View)**：
* 引入 `fl_chart`，绘制饼图展示今日/本周分布。

✅ **验收标准**：能看到饼图，显示各分类占比。

---

## 9. 小约定
- 文件命名：`snake_case.dart`。
- ViewModel 只暴露 UI 需要的状态与事件，避免泄露底层模型细节。
- Repository 只做数据读写与必要转换，不塞入复杂 UI 逻辑。
- 使用 Riverpod Generator（`@riverpod`）定义 Providers；ViewModel 使用 `BuildlessAutoDisposeAsyncNotifier` 或 `AutoDisposeAsyncNotifier`。
