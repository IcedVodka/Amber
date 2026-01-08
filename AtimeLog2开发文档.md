# AtimeLog2 开发文档（Clean Architecture）

## 0. 说明
- 本文档用于从零开发 AtimeLog2。
- 未来可能加入更多功能与多端能力，因此要求架构与数据具备良好的扩展性。

## 1. 目标与范围
- 以“计时/时间记录”为核心，支持桌面与移动端一致体验。
- 采用 Clean Architecture：Data / Domain / Presentation，严格依赖方向。
- 离线优先，本地为真；同步作为副本与协同机制。
- 可测试、可维护、可扩展，方便后续新增功能与新同步服务。

## 2. 功能清单、
- 计时：开始、暂停、停止、继续、切换分类（含自动停止当前任务）。
- 手动补录：支持跨日拆分与校验。
- 编辑记录：修改开始/结束时间、分类、备注；支持删除记录。
- 重叠校正：支持 none/ask/auto 三种策略。
- 活动/分类管理：新增、编辑、排序、启用/禁用、软删除；名称允许 `xx.yy`（如“睡眠.午睡”）用于展示分组。
- 最近上下文：快速开始最近分类与备注，保留累计时长。
- 统计分析：日统计、范围统计、按分类聚合、时间轴查看。
- 设置：主题模式、时间显示、重叠策略、自动同步间隔。
- 同步：WebDAV（首选），预留 S3/其他存储扩展。
- 备份/恢复：本地打包与恢复，支持手动导入导出。
- 桌面能力：托盘、最小化到托盘（可作为桌面端增强）。

## 3. 架构原则
- 业务规则只存在于 Domain 层，不依赖 Flutter 与具体存储。
- Presentation 仅依赖 UseCase；Data 依赖 Domain 的抽象接口。
- 明确边界：实体与用例可在 CLI/测试环境直接运行。
- 统一错误模型与结果模型，提升可观测性与测试性。
- 使用版本化数据格式与扩展字段，便于未来新增功能。

## 4. 目录结构建议
```text
lib/
  main.dart
  app.dart
  injection_container.dart
  src/
    core/
      config/
      error/
      platform/
      services/
      utils/
      logging/
    features/
      activity/
        data/
        domain/
        presentation/
      history/
        data/
        domain/
        presentation/
      stats/
        data/
        domain/
        presentation/
      categories/
        data/
        domain/
        presentation/
      settings/
        data/
        domain/
        presentation/
      sync/
        data/
        domain/
        presentation/
      backup/
        data/
        domain/
        presentation/
    shared/
      widgets/
      theme/
      routes/
```

## 5. Core 层设计
- `config/`：常量、文件名、FeatureFlags、schemaVersion。
- `error/`：Exception/Failure/Result 类型与统一错误码。
- `platform/`：平台识别、路径差异、托盘/窗口封装。
- `services/`：Clock、Uuid、Logger、SecureStorage、FileSystem。
- `utils/`：时间格式化、日期区间、序列化辅助。
- `logging/`：统一日志与埋点入口。

## 6. Domain 层设计

### 6.1 领域实体（建议）
- `ActivityRecord`：id、sessionId、categoryId、startAt、endAt、note、createdAt、updatedAt、deleted、source。
- `CurrentActivity`：sessionId、categoryId、startAt、note。
- `CurrentSession`：deviceId、lastModified、current?、recents[]。
- `RecentContext`：categoryId、note、lastUsedAt、accumulatedSec。
- `Category`：id、name、iconCode、colorHex、order、enabled、deleted（名称可使用点号分组展示，实体保持扁平）。
- `AppSettings`：themeMode、overlapPolicy、weekStart、timeFormat。
- `SyncConfig`：enabled、provider、endpoint、username、password、remotePath、autoIntervalMinutes。
- `SyncState`：syncing、lastSyncAt、lastResult、progress。

### 6.2 领域服务
- `OverlapResolver`：重叠检测与修复（截断/拆分/删除）。
- `RecordSplitter`：跨日拆分（拆分后各记录 `id` 不同但共享同一个 `sessionId`）。
- `NoteResolver`：空备注回退到分类名或最近上下文。
- `StatsAggregator`：区间统计、按分类聚合。
- `SyncPlanner`：计算同步计划与冲突合并策略。

### 6.3 用例清单（核心）
- 初始化：`InitApp`、`LoadSettings`、`LoadCategories`、`LoadSession`。
- 计时：`StartActivity`、`PauseActivity`、`StopActivity`、`SwitchActivity`。
- 编辑：`UpdateCurrentStartTime`、`UpdateCurrentNote`、`UpdateRecord`。
- 补录：`ManualAddRecord`。
- 删除：`DeleteRecord`。
- 最近：`RefreshRecents`、`RemoveRecent`。
- 分类：`CreateCategory`、`UpdateCategory`、`ReorderCategories`、`ToggleCategory`。
- 统计：`LoadDayRecords`、`LoadRangeRecords`、`AggregateByCategory`。
- 设置：`UpdateSettings`、`UpdateOverlapPolicy`。
- 同步：`SyncNow`、`VerifySync`、`UpdateSyncConfig`。
- 备份：`CreateBackup`、`RestoreBackup`。

## 7. Data 层设计

### 7.1 数据源（Local/Remote）
```dart
abstract class LocalStore {
  Future<String?> readText(String path);
  Future<void> writeText(String path, String content);
  Future<List<String>> list(String path);
  Future<void> delete(String path);
  Future<int?> lastModified(String path);
}

class RemoteFileMeta {
  const RemoteFileMeta({required this.name, this.etag, this.lastModified});
  final String name;
  final String? etag;
  final int? lastModified;
}

abstract class RemoteFileStore {
  Future<void> ensureDir(String path);
  Future<Map<String, RemoteFileMeta>> listFiles(String path);
  Future<String> download(String path);
  Future<String?> upload(String path, String content);
  Future<void> ping();
}
```

### 7.2 Repository 接口（示例）
```dart
abstract class ActivityRepository {
  Future<CurrentSession> loadSession();
  Future<void> saveSession(CurrentSession session);
  Future<List<ActivityRecord>> loadDay(DateTime day);
  Future<void> saveDay(DateTime day, List<ActivityRecord> records);
  Future<List<ActivityRecord>> loadRange(DateTime start, DateTime end);
}

abstract class CategoryRepository {
  Future<List<Category>> loadAll();
  Future<void> saveAll(List<Category> categories);
}

abstract class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
  Future<SyncConfig> loadSync();
  Future<void> saveSync(SyncConfig config);
}

abstract class SyncRepository {
  Future<SyncResult> syncAll(SyncConfig config, {SyncProgressCallback? onProgress});
  Future<void> verify(SyncConfig config);
}

abstract class BackupRepository {
  Future<String> createBackup({String? targetPath});
  Future<void> restoreBackup(String zipPath);
}
```

### 7.3 Mapper 与版本化
- Data Model 负责序列化；Domain 实体仅承载业务意义。
- 所有持久化对象包含 `schemaVersion` 与 `lastModified` 字段。
- 兼容性由 `schemaVersion` 控制，允许未来升级。

## 8. Presentation 层设计
- 采用 BLoC / Riverpod 之一，统一状态模型与错误提示。
- 页面按 Feature 划分：Activity、History、Stats、Categories、Settings、Sync。
- Presentation 仅调用 UseCase，不直接访问 DataSource。
- ViewModel/State 统一处理加载、错误、空态与进度。

## 9. 数据存储格式（AtimeLog2 V2）

### 9.1 目录结构
```text
<baseDir>/
  meta.json
  current/
    session.json
    categories.json
    settings.json
    sync.json
  data/
    2025-01/
      2025-01-01.json
  cache/
    current.json
    202501.json
```

### 9.2 字段约定
- 时间使用 ISO8601 字符串（含时区）与 epoch ms 并存：`startAt`、`endAt` 使用字符串，`createdAt/updatedAt/lastModified` 使用 ms。
- 所有持久化对象必须包含 `schemaVersion`。
- 删除采用软删除：记录保留 `deleted=true` 与 `updatedAt`，用于同步合并。
- `durationSec` 不落盘，按 `endAt - startAt` 计算。
- 跨日活动自动拆分为单日记录，各记录共享同一 `sessionId`。

### 9.3 缓存文件约定
- `cache/current.json`：记录 `current/` 目录下各文件的 `etag/lastModified`。
- `cache/yyyymm.json`：记录 `data/yyyy-mm/` 目录下各文件的 `etag/lastModified`。

### 9.4 示例
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
    }
  ]
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
      "source": "timer"
    }
  ]
}
```

## 10. 同步设计

### 10.1 流程
1. 读取本地缓存：`cache/current.json` 与对应 `cache/yyyymm.json`。
2. 通过 WebDAV 拉取远端目录列表（name + etag/lastModified）。
3. 对比缓存与远端 etag，etag 不同则下载文件。
4. 比较文件内 `lastModified`：远端更新则覆盖本地，本地更新则上传远端。
5. 先同步 `current/`，再同步 `data/`，最后更新缓存。

### 10.2 热同步 / 冷同步
- 热同步：检测最近 7 天覆盖到的月份目录 + `current/`。
- 冷同步：检测所有月份目录 + `current/`。

### 10.3 冲突处理
- 默认策略：文件级 `lastModified` 新者覆盖（本地/远端）。
- 可选策略：同一天记录合并后触发 `OverlapResolver`，产出最终记录。

### 10.4 扩展点
- 通过 `RemoteFileStore` 扩展 WebDAV/S3/其他存储。
- `SyncPlanner` 保持无存储依赖，可被测试与替换。

## 11. 备份与恢复
- 备份为 zip，包含 `meta.json` 与所有数据文件。
- 备份内包含 `backup_manifest.json`（版本、生成时间、文件清单）。
- 恢复时先校验版本，再写入本地目录。

## 12. 扩展性设计
- 版本化数据格式：`schemaVersion` 支持后续迁移。
- 领域模型预留扩展字段：如标签、项目、计费、提醒等。
- Feature 化目录结构：新增功能可独立扩展 Data/Domain/Presentation。
- 同步采用适配器模式，新增云存储只需实现 `RemoteFileStore`。

## 13. 测试策略
- Domain：重叠校正、跨日拆分、统计聚合、同步决策。
- Data：本地读写、JSON 解析、冲突合并、远端同步。
- Presentation：核心流程 UI 测试（开始/停止/补录/编辑）。

## 14. 基于“垂直切片”策略的边做边学详细里程建议。

### 🏁 里程碑 1：配置与主题 (Settings Feature)

**目标**：跑通 Clean Architecture 的全流程，实现“深色模式”切换。
**核心价值**：搭建基础的文件存储服务，熟悉 Riverpod 的状态流转。

* **步骤 1.1 (Data)**: 实现 `LocalFileService`。
* 不用复杂的数据库，写一个辅助类，利用 `path_provider` 获取路径，实现 `readJson(filename)` 和 `writeJson(filename, content)`。


* **步骤 1.2 (Domain)**: 定义 `AppSettings` 实体。
* 字段：`themeMode` (System/Light/Dark), `timeFormat` (24h/12h)。
* 使用 `freezed` 生成不可变对象。


* **步骤 1.3 (Repo)**: 实现 `SettingsRepository`。
* 负责调用 `LocalFileService` 读取/保存 `settings.json`。
* 处理“第一次启动文件不存在”的情况（返回默认配置）。


* **步骤 1.4 (Presentation)**:
* 创建 `SettingsNotifier` (Riverpod)，在启动时加载配置。
* **UI 开发**：在 `SettingsPage` 放一个 `SwitchListTile` 或 `SegmentedButton` 来切换主题。
* **全局联动**：修改 `MaterialApp` 的 `themeMode`，使其监听 `SettingsNotifier`。



✅ **验收标准**：重启 App 后，主题模式依然保持上次的选择。

---

### 🏁 里程碑 2：分类管理 (Categories Feature)

**目标**：实现增删改查 (CRUD)，为计时功能做铺垫。
**核心价值**：处理列表数据，学习如何生成唯一 ID (Uuid)。

* **步骤 2.1 (Domain)**: 定义 `Category` 实体。
* 字段：`id`, `name`, `color`, `icon`, `order`。


* **步骤 2.2 (Data)**: 实现 `CategoryRepository`。
* 读写 `current/categories.json`。


* **步骤 2.3 (Presentation - List)**:
* 在 `CategoriesPage` (或者放在设置页里的子页面) 展示列表。
* 使用 `ReorderableListView` 实现拖拽排序（高级挑战，可后做）。


* **步骤 2.4 (Presentation - Edit)**:
* 实现一个简单的 Dialog 或新页面，输入分类名称，选择颜色（预设几个颜色圆点即可）。
* 实现“软删除”逻辑（标记 `deleted: true` 而不是物理删除）。



✅ **验收标准**：可以新建“工作”、“休息”分类，并能持久化保存。

---

### 🏁 里程碑 3：核心计时器 (Timer Feature - MVP)

**目标**：实现“开始”和“停止”，生成最基础的记录。
**核心价值**：App 的灵魂，处理动态状态（计时器跳动）。

* **步骤 3.1 (Domain)**:
* 定义 `ActivityRecord` (历史记录) 和 `CurrentSession` (当前正在进行的任务)。
* 编写逻辑：`StartActivity(categoryId)`。注意：如果当前有任务在跑，需要先停止它（简单的自动停止策略）。


* **步骤 3.2 (Data)**:
* `ActivityRepository` 需要处理两个文件：
1. `current/session.json` (实时保存当前任务，防崩溃)。
2. `data/yyyy-mm/yyyy-mm-dd.json` (停止时写入历史记录)。




* **步骤 3.3 (Presentation - Home)**:
* **UI 上半部分**：显示当前计时任务（大字号时间 hh:mm:ss）。使用 `Stream.periodic` 或 `Ticker` 每秒刷新 UI，**但不要每秒写文件**。
* **UI 下半部分**：使用 `GridView` 展示你在里程碑 2 建立的分类，点击即开始。



✅ **验收标准**：点击“工作”开始计时 -> 杀掉 App -> 重启 App -> 计时器应该根据 `startAt` 算出正确时间继续跳动 -> 点击停止 -> 生成一条历史记录。

---

### 🏁 里程碑 4：历史记录与时间轴 (History Feature)

**目标**：把保存的 JSON 数据展示出来。
**核心价值**：复杂列表渲染，日期处理。

* **步骤 4.1 (Domain)**:
* 实现 `LoadDayRecords(date)`。
* 实现 `RecordSplitter` (跨日拆分逻辑)，虽然 MVP 阶段可能先不做，但预留接口。


* **步骤 4.2 (Presentation)**:
* 实现 `HistoryPage`。
* **组件**：可以使用 `ListView` 简单展示。
* **进阶组件**：尝试画一个左侧带有时间线的 UI (Timeline Tile)。
* 实现“按天切换”：顶部放一个日期选择器。



✅ **验收标准**：能看到今天产生的所有记录列表，时间段和时长计算正确。

---

### 🏁 里程碑 5：补录与编辑 (Refinement)

**目标**：修复错误的数据。
**核心价值**：表单处理，重叠时间校验。

* **步骤 5.1 (Domain)**:
* 实现 `OverlapResolver`。当你手动补录一个 `10:00 - 11:00` 的记录，如果通过重叠检测，需要提示用户或自动截断旧记录。


* **步骤 5.2 (Presentation)**:
* 在历史列表点击某条记录 -> 弹出编辑页。
* 首页添加“手动补录”按钮。
* 使用 `showTimePicker` 选择时间。



✅ **验收标准**：可以修改某条记录的备注，或者调整它的开始/结束时间。

---

### 🏁 里程碑 6：统计图表 (Stats Feature)

**目标**：数据可视化。
**核心价值**：数据聚合算法，图表库使用。

* **步骤 6.1 (Domain)**:
* 编写 `StatsService`：输入 `List<ActivityRecord>`，输出 `Map<Category, Duration>`。


* **步骤 6.2 (Presentation)**:
* 引入 `fl_chart`。
* 绘制饼图（PieChart）展示今日/本周的时间分布。



✅ **验收标准**：看到一个漂亮的饼图，显示“工作占了 60%”。

### 后续自主开发