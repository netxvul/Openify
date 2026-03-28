# Openify

Openify 是一个 macOS 桌面工具，用于批量设置文件扩展名的默认打开应用。

## 界面预览

![Openify Screenshot](<screenshot/CleanShot 2026-03-28 at 17.22.10@2x.png>)

## 功能

- 扫描本机应用（`/Applications`、`/System/Applications`、`~/Applications`）
- 选择目标应用并批量选择扩展名
- 支持扩展名分类、多选、清空、自定义添加
- 支持导入文件（选择/拖拽）自动识别扩展名
- 使用 Launch Services 设置默认打开程序
- 显示扩展名当前默认关联应用

## 环境要求

- macOS 13+
- Xcode 15+（建议使用当前系统匹配版本）

## 构建与运行

```bash
xcodebuild -project Openify.xcodeproj -scheme Openify -destination 'platform=macOS' -configuration Debug build
```

或直接在 Xcode 中打开 `Openify.xcodeproj`，选择 `Openify` scheme 运行。

## 项目结构

- `Openify/`：应用源码
- `Openify.xcodeproj/`：Xcode 工程文件

## 说明

- 修改默认打开程序时，macOS 某些场景可能弹出系统确认对话框，这是系统行为。
- 当前工程默认关闭 App Sandbox，以便执行默认程序关联设置。
