# Amber（流珀）

流珀是一款基于 Flutter 的时间记录与专注管理应用，支持计时、分类管理、统计分析、数据编辑以及 WebDAV 同步，适合用于日常专注与时间复盘。

## 主要功能

- 计时记录：一键开始/结束任务计时，记录内容与权重
- 分类管理：配置图标、主题色、权重与启用状态
- 统计分析：查看时间分布与趋势
- 数据编辑：按日期管理已记录的数据与便签
- 同步备份：通过 WebDAV 同步到云端或私有服务器
- 主题切换：内置多套主题风格

## 使用方式

### 环境要求

- Flutter 3.10+
- Dart 3.10+

### 本地运行

```bash
flutter pub get
flutter run
```

### 构建发布

```bash
flutter build apk
flutter build ios
flutter build macos
flutter build windows
flutter build linux
```

### WebDAV 同步设置

1. 进入「管理」页的「同步设置」
2. 填写 WebDAV URL、账号、密码、目标文件夹
3. 点击「测试连接」确认可用
4. 需要全量同步时点击「全量同步」，或开启自动同步

## 项目结构

项目采用 Feature-First + MVVM 架构，功能模块集中在 `lib/features` 下：

- `activity`：计时与记录
- `categories`：分类管理与编辑
- `stats`：统计与报表
- `data_manage`：数据编辑管理
- `sync`：WebDAV 同步
- `settings`：主题等配置
