import UIKit
import SwiftUI

enum ImageProcessor {

    /// 将水印叠加到图片上，返回新图片
    static func apply(watermark config: WatermarkConfig, to image: UIImage) -> UIImage {
        print("🎨 === ImageProcessor.apply 开始 ===")
        print("   图片尺寸: \(image.size)")

        let scale = image.scale
        let size  = image.size

        let renderer = UIGraphicsImageRenderer(size: size, format: {
            let f = UIGraphicsImageRendererFormat()
            f.scale = scale
            return f
        }())

        let result = renderer.image { ctx in
            // 1. 画原图
            image.draw(at: .zero)
            print("   ✅ 原图已绘制")

            // 2. === 在图片正中央画一个巨大的红色圆形 ===
            let centerX = size.width / 2
            let centerY = size.height / 2
            let radius = min(size.width, size.height) * 0.3  // 图片尺寸的 30%

            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(
                x: centerX - radius,
                y: centerY - radius,
                width: radius * 2,
                height: radius * 2
            ))
            print("   ✅ 中央红色圆形已绘制，半径: \(radius)")

            // 3. === 在红色圆形中央画白色文字 ===
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: radius * 0.5, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let text = "测试"
            let textSize = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(
                x: centerX - textSize.width / 2,
                y: centerY - textSize.height / 2
            ), withAttributes: attrs)
            print("   ✅ 白色文字已绘制")
        }

        print("   🎯 渲染完成，返回图片尺寸: \(result.size)")
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
