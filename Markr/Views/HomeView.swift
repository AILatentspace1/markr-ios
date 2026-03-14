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

        for item in items {
            group.enter()
            item.loadTransferable(type: Data.self) { result in
                defer { group.leave() }
                if case .success(let data) = result,
                   let data, let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        images.append(img)
                    }
                }
            }
        }

        group.notify(queue: .main) {
            if !images.isEmpty {
                showEditor = true
            }
        }
    }
}
