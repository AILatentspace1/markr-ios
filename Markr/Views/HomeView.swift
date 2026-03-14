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

            // 方法1: 尝试加载 Data
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
                        print("⚠️ 第 \(index + 1) 张: 无法从数据创建 UIImage")
                        // 方法2: 尝试直接加载 UIImage
                        self.loadImageAsUIImage(from: item, index: index)
                    }
                case .failure(let error):
                    print("❌ 第 \(index + 1) 张: Data 加载失败 - \(error.localizedDescription)")
                    // 方法2: 尝试直接加载 UIImage
                    self.loadImageAsUIImage(from: item, index: index)
                }
            }
        }

        group.notify(queue: .main) {
            print("📸 加载完成，共 \(images.count) 张图片")
            if !images.isEmpty {
                showEditor = true
            } else {
                print("⚠️ 没有成功加载任何图片")
            }
        }
    }

    // 备用方法: 直接加载 UIImage
    private func loadImageAsUIImage(from item: PhotosPickerItem, index: Int) {
        item.loadTransferable(type: UIImage.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let uiimage):
                    if let img = uiimage {
                        self.images.append(img)
                        print("✅ 第 \(index + 1) 张图片 (备用方法) 加载成功")
                    } else {
                        print("❌ 第 \(index + 1) 张: UIImage 为 nil")
                    }
                case .failure(let error):
                    print("❌ 第 \(index + 1) 张: UIImage 加载失败 - \(error.localizedDescription)")
                }
            }
        }
    }
}
