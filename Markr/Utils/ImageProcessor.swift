import UIKit
import SwiftUI

enum ImageProcessor {

    /// 将水印叠加到图片上，返回新图片
    static func apply(watermark config: WatermarkConfig, to image: UIImage) -> UIImage {
        print("🎨 === ImageProcessor.apply 开始 ===")
        print("   图片尺寸: \(image.size), scale: \(image.scale)")
        print("   水印文字: '\(config.text)'")
        print("   字号: \(config.fontSize)")
        print("   颜色: \(config.color)")
        print("   透明度: \(config.opacity)")
        print("   位置: \(config.position)")

        let scale = image.scale
        let size  = image.size

        let renderer = UIGraphicsImageRenderer(size: size, format: {
            let f = UIGraphicsImageRendererFormat()
            f.scale = scale
            return f
        }())

        let result = renderer.image { ctx in
            print("   🖼️ 开始渲染...")

            // 1. 画原图
            image.draw(at: .zero)
            print("   ✅ 原图已绘制")

            // 2. 准备文字属性
            let uiColor = UIColor(config.color).withAlphaComponent(config.opacity)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: config.fontSize, weight: .semibold),
                .foregroundColor: uiColor
            ]

            let textSize = (config.text as NSString).size(withAttributes: attrs)
            let padding: CGFloat = 16

            // 3. 根据九宫格位置计算原点
            let origin = textOrigin(
                textSize: textSize,
                canvasSize: size,
                position: config.position,
                padding: padding,
                dragOffset: config.dragOffset
            )

            print("   📐 文字位置: \(origin), 文字尺寸: \(textSize)")

            // 4. 画文字
            (config.text as NSString).draw(at: origin, withAttributes: attrs)
            print("   ✅ 水印已绘制")
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
