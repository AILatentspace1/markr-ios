import SwiftUI
import PhotosUI

struct HomeView: View {
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []
    @State private var showEditor = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Logo / 标题区
                    VStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 56))
                            .foregroundStyle(.indigo)
                        Text("Markr")
                            .font(.largeTitle.bold())
                        Text("一键给图片加水印")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // 图片选择按钮
                    PhotosPicker(
                        selection: $pickerItems,
                        maxSelectionCount: 20,
                        matching: .images
                    ) {
                        Label("选择图片", systemImage: "photo.on.rectangle.angled")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.indigo)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 32)
                    .onChange(of: pickerItems) { newItems in
                        loadImages(from: newItems)
                    }

                    Text("最多同时选 20 张")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showEditor) {
                EditorView(images: images)
            }
        }
    }

    // MARK: - 加载图片

    private func loadImages(from items: [PhotosPickerItem]) {
        images = []
        let group = DispatchGroup()

        print("📝 开始加载 \(items.count) 张图片")

        for (index, item) in items.enumerated() {
            group.enter()
            print("🔄 正在加载第 \(index + 1) 张图片...")

            item.loadTransferable(type: Data.self) { result in
                defer { group.leave() }
                switch result {
                case .success(let data):
                    if let data, let img = UIImage(data: data) {
                        DispatchQueue.main.async {
                            images.append(img)
                            print("✅ 第 \(index + 1) 张图片加载成功")
                        }
                    } else {
                        print("⚠️ 第 \(index + 1) 张: 数据为空或无法创建 UIImage")
                    }
                case .failure(let error):
                    print("❌ 第 \(index + 1) 张加载失败: \(error.localizedDescription)")
                }
            }
        }

        group.notify(queue: .main) {
            print("📸 加载完成，共 \(images.count) 张图片")
            if !images.isEmpty {
                showEditor = true
            } else {
                print("⚠️ 没有成功加载任何图片，请确保模拟器中有照片")
            }
        }
    }
}
