# PalettePro (臻图坊) 🎨

PalettePro (臻图坊) 是一款生产就绪、高度美观的 Flutter 照片排版与展示编辑应用。本应用专注于通过极简奢华的排版样式，将普通的照片转化为画报级的艺术展示。

系统架构设计严格遵循**开闭原则 (OCP)**，支持在不修改核心代码的前提下，动态且无缝地扩展新的高级排版样式。

---

## ✨ 功能特性

- **极简奢华 Slate 暗黑主题**：专为摄影作品量身定制的 Slate 灰黑背景 (`0xFF121212`)，将所有视觉焦点汇聚于照片本身。
- **遵循开闭原则 (OCP) 的插件化排版系统**：通过标准接口，提供灵活、解耦的画幅样式注册与配置机制。
- **超高清画幅导出引擎**：采用 `RepaintBoundary` 并配置高缩放倍率 (`pixelRatio: 4.0`)，确保完美还原细腻的软阴影、朦胧背景及高精度字体，可完美保存至本地图库。
- **内置高级画幅样式**：
  1. **溪谷卡片 (Charming Creek)**：背景图高斯模糊，中心呈现无模糊的原图卡片并配以奢华阴影与圆角，下方搭配精致优雅的衬线字体标题与半透明版权标志。
  2. **电影画幅 (Cinematic Frame)**：将原图置于深邃的电影级黑底中，边角处点缀着相机技术参数（如 *Device, ISO, f/1.8, 1/125s*），呈现独特的独立电影美学。

---

## 🛠️ 架构与项目结构

```
lib/
├── main.dart                      # 应用入口，Slate 风格主题配置
├── models/
│   └── effect_processor.dart      # 抽象画幅样式接口 (OCP 基类)
├── processors/
│   ├── card_effect_processor.dart  # 溪谷卡片排版样式实现
│   └── cinema_effect_processor.dart# 电影画幅排版样式实现
├── screens/
│   └── editor_screen.dart         # 主工作台界面与画布逻辑
└── state/
    └── editor_notifier.dart       # 应用状态控制器 (原生 ChangeNotifier)
```

---

## 🚀 快速开始

### 前提条件

运行本项目前，请确保您的开发环境中已安装并配置好 Flutter SDK：
```bash
flutter --version
```

### 安装步骤

1. 克隆本项目并进入项目根目录：
   ```bash
   cd palette_pro
   ```
2. 拉取项目所需的依赖包：
   ```bash
   flutter pub get
   ```

### 运行项目

使用以下命令以调试模式启动应用程序：
```bash
flutter run
```

### 编译发布版本

针对目标平台编译 native 生产发布包：
```bash
# Windows 桌面端
flutter build windows

# Android 移动端
flutter build apk --release

# iOS 移动端
flutter build ipa
```

### 运行自动化测试

执行用于验证组件加载和布局的单元测试：
```bash
flutter test
```
