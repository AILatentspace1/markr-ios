# Markr · 水印 💧

> 一键给图片加水印，批量处理，简洁好用。

## 功能

- 📷 从相册选图（最多20张）
- ✍️ 文字水印：内容 / 字号 / 颜色 / 透明度
- 🎯 九宫格快速定位 + 拖拽微调
- 📦 批量导出到相册

## 技术栈

- Swift + SwiftUI
- iOS 16.0+
- PhotosUI 框架

## 项目结构

```
Markr/
├── App/
│   └── MarkrApp.swift
├── Views/
│   ├── HomeView.swift
│   └── EditorView.swift
├── Models/
│   └── WatermarkConfig.swift
└── Utils/
    └── ImageProcessor.swift
```

## 开始开发

1. 用 Xcode 新建项目（SwiftUI / iOS 16+ / Bundle ID: `com.gary.markr`）
2. 把 `Markr/` 目录下的源文件拖入项目
3. 编译运行

## 路线图

- [ ] v1.0 MVP 上架
- [ ] v1.1 图片水印（Logo）
- [ ] v1.2 水印模板保存
- [ ] v2.0 Pro 版订阅
