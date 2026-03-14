import SwiftUI
import PhotosUI

struct EditorView: View {
    let images: [UIImage]

    @State private var config = WatermarkConfig()
    @State private var previewImage: UIImage?
    @State private var isExporting = false
    @State private var exportDone = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: 预览区
                    Group {
                        if let displayImage = previewImage ?? (images.isEmpty ? nil : images[0]) {
                            PreviewCanvas(image: displayImage, config: config)
                        } else {
                            Text("暂无图片")
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                        }
                    }
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // MARK: 水印文字
                    GroupBox("水印文字") {
                        TextField("输入水印内容", text: $config.text)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    // MARK: 字号 & 透明度
                    GroupBox("样式") {
                        VStack(spacing: 12) {
                            LabeledSlider(label: "字号", value: $config.fontSize, range: 20...150, format: "%.0f pt")
                            LabeledSlider(label: "透明度", value: $config.opacity, range: 0.1...1.0, format: "%.0f%%", scale: 100)
                        }
                    }
                    .padding(.horizontal)

                    // MARK: 颜色
                    GroupBox("颜色") {
                        HStack(spacing: 12) {
                            ForEach([Color.white, .black, .yellow, .red, .blue, .green], id: \.self) { c in
                                Circle()
                                    .fill(c)
                                    .frame(width: 32, height: 32)
                                    .overlay(Circle().stroke(config.color == c ? Color.accentColor : .clear, lineWidth: 3))
                                    .onTapGesture { config.color = c }
                            }
                            Spacer()
                            ColorPicker("", selection: $config.color)
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal)

                    // MARK: 九宫格位置
                    GroupBox("位置") {
                        PositionGrid(selection: $config.position)
                            .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
                .padding(.bottom, 20)
            }

            // MARK: 导出按钮 - 固定在底部
            VStack(spacing: 0) {
                Divider()

                Button {
                    exportImages()
                } label: {
                    Label(isExporting ? "导出中..." : "导出 \(images.count) 张", systemImage: "square.and.arrow.down")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isExporting ? Color.gray : Color.indigo)
                        .foregroundStyle(.white)
                }
                .disabled(isExporting)
                .padding(.horizontal, 32)
                .padding(.top, 16)
                .padding(.bottom, 8)
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("水印编辑")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: config) { _ in updatePreview() }
        .onAppear { updatePreview() }
        .alert("导出完成 🎉", isPresented: $exportDone) {
            Button("好的") {}
        } message: {
            Text("\(images.count) 张图片已保存到相册")
        }
    }

    // MARK: - 生成预览

    private func updatePreview() {
        guard !images.isEmpty else { return }
        Task.detached(priority: .userInitiated) {
            let result = ImageProcessor.apply(watermark: config, to: images[0])
            await MainActor.run { previewImage = result }
        }
    }

    // MARK: - 批量导出

    private func exportImages() {
        isExporting = true
        Task.detached(priority: .userInitiated) {
            let config = self.config
            print("📤 开始导出，水印配置: '\(config.text)' 字号=\(config.fontSize)")

            for (index, img) in images.enumerated() {
                print("📷 第 \(index + 1) 张: 原图尺寸 \(img.size)")

                let result = ImageProcessor.apply(watermark: config, to: img)
                print("💾 第 \(index + 1) 张: 处理后尺寸 \(result.size), 内存地址 \(Unmanaged.passUnretained(result).toOpaque())")

                // 对比原图和处理后的图片
                let originalData = img.jpegData(compressionQuality: 1.0)
                let resultData = result.jpegData(compressionQuality: 1.0)
                print("📊 第 \(index + 1) 张: 原图大小 \(originalData?.count ?? 0) bytes, 处理后 \(resultData?.count ?? 0) bytes")

                UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
            }

            await MainActor.run {
                isExporting = false
                exportDone = true
                print("✅ 导出完成")
            }
        }
    }
}

// MARK: - 预览画布

struct PreviewCanvas: View {
    let image: UIImage
    let config: WatermarkConfig

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .overlay(alignment: config.position.alignment) {
                Text(config.text)
                    .font(.system(size: config.fontSize, weight: .semibold))
                    .foregroundStyle(config.color.opacity(config.opacity))
                    .padding(12)
                    .offset(config.dragOffset)
            }
    }
}

// MARK: - 滑块封装

struct LabeledSlider: View {
    let label: String
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let format: String
    var scale: CGFloat = 1

    var body: some View {
        HStack {
            Text(label).frame(width: 48, alignment: .leading)
            Slider(value: $value, in: range)
            Text(String(format: format, value * scale))
                .monospacedDigit()
                .frame(width: 56, alignment: .trailing)
        }
    }
}

// MARK: - 九宫格

struct PositionGrid: View {
    @Binding var selection: WatermarkPosition

    var body: some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            ForEach(0..<3, id: \.self) { row in
                GridRow {
                    ForEach(0..<3, id: \.self) { col in
                        let pos = WatermarkPosition.from(row: row, col: col)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(selection == pos ? Color.indigo : Color(.systemGray5))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .onTapGesture { selection = pos }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
