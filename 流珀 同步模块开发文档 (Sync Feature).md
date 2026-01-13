这份文档整合了我们之前讨论的“冷热同步”策略、基于 `lastModified` 的冲突解决机制，以及你最新补充的 UI/UX 交互需求。

---

# 流珀 同步模块开发文档 (Sync Feature)

## 1. 核心概述

* **目标**：实现多设备间的数据一致性（假设单人串行使用）。
* **策略**：**WebDAV + ETag 校验 + 冷热分离**。
* **原则**：
* **Last Write Wins (LWW)**：基于业务字段 `lastModified` 解决冲突。
* **流量最小化**：利用 ETag 过滤未变动文件。
* **冷热分离**：高频只同步当前上下文，低频同步全量历史。



## 2. 数据架构

### 2.1 云端目录结构 (WebDAV)

```text
/Amber/           # 用户配置的根目录
  current/            # 存放 settings.json, categories.json
  data/
    2025-01/          # 按月归档
      2025-01-12.json
    2025-02/
      ...

```

### 2.2 本地 Meta 存储

在本地 `meta/` 目录下维护同步状态，不上传云端。

```text
<app_dir>/meta/
  sync_current.json      # 记录 current/ 下文件的 ETag
  sync_2025-01.json      # 记录 data/2025-01/ 下文件的 ETag
  ...

```

**Meta JSON 结构示例** (`sync_2025-01.json`):

```json
{
  "2025-01-12.json": "\"098f6bcd...\"",  // 对应云端文件的 ETag
  "2025-01-13.json": null                 // null 表示本地已修改(Dirty)，下次必须检查
}

```

### 2.3 配置模型 (`SyncConfig`)

需持久化存储（统一使用 `shared_preferences` 保存配置与密码）。

```dart
class SyncConfig {
  final String webDavUrl;       // e.g., https://dav.jianguoyun.com/dav/
  final String username;
  final String password;
  final String targetFolder;    // 默认 "Amber"
  
  final bool autoHotSync;       // 是否开启自动热同步
  final bool hotSyncOnStartup;  // 是否启动时热同步
  final int autoSyncInterval;   // 间隔分钟数 (默认10)
  
  final DateTime? lastHotSyncAt; // 上次热同步时间 (用于 UI 显示)
}

```

---

## 3. 核心业务逻辑 (Logic)

### 3.1 脏标记逻辑 (Dirty Flag)

**规则**：任何时候 `FileService` 写入本地文件（如 `writeJson`），必须同时更新对应的 `meta` 记录。

* **操作**：将该文件的 ETag 设为 `null`。
* **目的**：确保下次同步时，即使云端 ETag 没变，也会触发“本地 vs 云端”的时间戳比对。

### 3.2 核心同步算法 (`processFolder`)

输入一个目标文件夹（如 `data/2025-01`），执行以下步骤：

1. **UI 状态**：更新状态为 `正在检查 ${folderName}...`。
2. **获取云端列表**：发送 `PROPFIND (Depth: 1)`，获取该文件夹下所有文件的 ETag 和 lastModified。
3. **获取本地列表**：读取 `meta/sync_${folderName}.json` 和本地文件系统的 lastModified。
4. **遍历对比**：
* **Case A (仅云端有)**：下载文件 -> 更新 Meta。
* **Case B (仅本地有)**：上传文件 -> 更新 Meta。
* **Case C (ETag 一致)**：跳过。
* **Case D (冲突/本地Dirty)**：
* `UI 状态`：`正在对比 ${fileName}...`
* 下载云端文件到 Temp。
* **决断**：
* 若 `Cloud.lastModified > Local.lastModified`：**覆盖本地** (UI: `下载更新...`)。
* 若 `Cloud.lastModified <= Local.lastModified`：**上传本地** (UI: `上传修改...`)。


* 更新 Meta。





### 3.3 冷热分离策略

* **热同步 (Hot Sync)**：
* **范围**：`current/` + `当前月份` + `上一个月`。
* **触发**：手动按钮、定时器自动触发、App 恢复前台(Resumed)。


* **冷同步 (Cold Sync)**：
* **范围**：`current/` + `data/` 下所有存在的月份文件夹。
* **触发**：设置页手动点击。



---

## 4. UI/UX 设计

### 4.1 计时页面 / 首页 (Home Page)

在顶部 App Bar 或 显眼位置放置同步入口。

**组件设计**：

* **UI 元素**：
* 一个 **刷新图标 (Refresh Icon)**。
* 左侧/下方小字标签 (`Text`)。


* **状态表现**：
* **空闲 (Idle)**：图标静止。小字显示：“上次同步: 14:30” (或 "未同步")。
* **同步中 (Syncing)**：
* 图标：**持续旋转动画**。
* 小字：实时显示 `SyncManager` 抛出的状态流（e.g., "获取 ETag...", "上传 01-12...", "同步完成"）。




* **交互**：
* **点击**：立即触发 **热同步**。
* **反馈**：无论成功失败，结束后更新“上次同步时间”为当前时间。若失败，Toast 提示错误原因，但图标停止旋转。



**自动同步逻辑**：

* 若开启 `autoHotSync`，启动一个 `Timer.periodic`，并在恢复前台时触发一次热同步。
* 若开启 `hotSyncOnStartup`，App 启动后自动执行一次热同步。

### 4.2 设置页面 - 同步设置栏 (Settings Section)

**布局**：`Column` -> `Card` -> `Form`。

1. **WebDAV 配置**：
* [输入框] 服务器地址 (URL)
* [输入框] 账号 (Username)
* [输入框] 密码 (Password) - *掩码显示*
* [输入框] 目标文件夹 (默认为 Amber)


2. **连通性测试**：
* [按钮] **"测试连接"**
* *逻辑*：尝试 list 根目录。成功弹 Toast "连接成功"，失败弹具体 Error。


3. **自动化设置**：
* [Switch] **自动热同步**
* [输入框] **同步间隔 (分钟)** (仅当 Switch 开启时可用，校验最小值为 5)。


1. **高级操作**：
* [按钮] **"执行冷同步 (全量)"**
* *点击后*：弹出模态 Loading 框（因为冷同步时间长，不建议放在后台悄悄做），显示详细进度日志。





---

## 5. 开发实现步骤

### Phase 1: 基础设施 (Infrastructure)

1. 引入依赖：`webdav_client`, `shared_preferences`, `connectivity_plus` (可选，检查网络)。
2. 创建 `SyncConfig` 模型与持久化存取。
3. 创建 `SyncMetaService`：负责读写 `meta/` 下的 JSON。

### Phase 2: 同步服务 (Service Layer)

1. 创建 `SyncManager` (Singleton 或 Riverpod Provider)。
2. 实现 `WebDAV` 连接与基础操作 (list, download, upload)。
3. 实现 **Initial Setup 逻辑**：检测到是新安装（无 Meta），将本地默认配置的 `lastModified` 设为 2020-01-01，确保被云端覆盖。
4. 实现 `processFolder` 核心算法。

### Phase 3: 状态管理 (ViewModel)

1. `SyncViewModel`：
* 暴露 `syncStatus` (String, e.g., "Idle", "Downloading...")。
* 暴露 `isSyncing` (bool)。
* 暴露 `lastSyncedAt` (DateTime)。
* 提供 `triggerHotSync()` 和 `triggerColdSync()` 方法。


2. 实现定时器逻辑：在 ViewModel 初始化时读取配置，若开启自动，则启动 Timer。

### Phase 4: UI 绑定 (Integration)

1. **Settings Page**：绑定表单数据，实现“测试连接”和“冷同步”调用。
2. **Home Page**：
* 使用 `ConsumerWidget` 监听 `SyncViewModel`。
* 根据 `isSyncing` 控制动画控制器 (AnimationController) 进行旋转。
* 根据 `syncStatus` 更新小字。



### Phase 5: 边界测试

* **断网测试**：同步中途断网，应捕获异常，停止旋转，提示“网络错误”，不损坏本地数据。
* **并发测试**：正在自动同步时，用户手动点击了同步按钮（应忽略或 Debounce）。
* **空文件夹**：确保新建的月份文件夹能被正确创建 (MKCOL)。

---

## 6. 特别注意：状态反馈的具体文案设计

为了让用户感到安心（App 在干活），状态文案应具备**颗粒度**：

* `正在连接云端...` (Handshake)
* `检查目录: current...` (Fetching ETag)
* `发现更新: categories.json` (Diff found)
* `正在下载: categories.json` (Downloading)
* `正在上传: 2025-01-12.json` (Uploading)
* `检查目录: 2025-01...`
* `同步完成` (Success)
* `同步失败: 401 Unauthorized` (Error)
