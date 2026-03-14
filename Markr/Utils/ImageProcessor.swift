import UIKit
import SwiftUI

enum ImageProcessor {

    /// 将水印叠加到图片上，返回新图片
    static func apply(watermark config: WatermarkConfig, to image: UIImage) -> UIImage {
        print("🎨 === ImageProcessor.apply 开始 ===")

        // === 测试模式：在图片上画一个大红条 ===
        let scale = image.scale
        let size  = image.size

        print("   图片尺寸: \(image.size)")

        let renderer = UIGraphicsImageRenderer(size: size, format: {
            let f = UIGraphicsImageRendererFormat()
            f.scale = scale
            return f
        }())

        let result = renderer.image { ctx in
            // 1. 画原图
            image.draw(at: .zero)

            // 2. === 测试：画一个巨大的红色矩形覆盖图片 ===
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            let testRect = CGRect(x: size.width - 300, y: size.height - 200, width: 280, height: 180)
            ctx.cgContext.fill(testRect)

            // 3. === 测试：画白色文字 ===
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 80, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let text = "测试水印"
            text.draw(at: CGPoint(x: size.width - 280, y: size.height - 150), withAttributes: attrs)

            print("   ✅ 测试水印已绘制（红色矩形 + 白色文字）")
        }

        print("   🎯 渲染完成")
        print("🎨 === ImageProcessor.apply 结束 ===")

        return result
    }

    // MARK: - 私有：计算文字坐标

    private static func textOrigin(
        textSize: CGSize,
        canvasSize: CGSize,
        position: WatermarkPosition,
        padding: CGFloat,
        dragOffset: CGSize
    ) -> CGPoint {
        var x: CGFloat
        var y: CGFloat

        switch position.col {
        case 0: x = padding
        case 1: x = (canvasSize.width - textSize.width) / 2
        default: x = canvasSize.width - textSize.width - padding
        }

        switch position.row {
        case 0: y = padding
        case 1: y = (canvasSize.height - textSize.height) / 2
        default: y = canvasSize.height - textSize.height - padding
        }

        return CGPoint(x: x + dragOffset.width, y: y + dragOffset.height)
    }
}
