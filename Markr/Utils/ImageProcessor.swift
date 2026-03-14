import UIKit
import SwiftUI

enum ImageProcessor {

    /// 将水印叠加到图片上，返回新图片
    static func apply(watermark config: WatermarkConfig, to image: UIImage) -> UIImage {
        let scale = image.scale
        let size = image.size

        let renderer = UIGraphicsImageRenderer(size: size, format: {
            let f = UIGraphicsImageRendererFormat()
            f.scale = scale
            return f
        }())

        return renderer.image { ctx in
            // 1. 画原图
            image.draw(at: .zero)

            // 2. 准备文字属性
            let uiColor = UIColor(config.color).withAlphaComponent(config.opacity)

            // 添加阴影使水印更明显
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.6)
            shadow.shadowOffset = CGSize(width: 2, height: 2)
            shadow.shadowBlurRadius = 4

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: config.fontSize, weight: .bold),
                .foregroundColor: uiColor,
                .shadow: shadow
            ]

            let textSize = (config.text as NSString).size(withAttributes: attrs)
            let padding: CGFloat = 20

            // 3. 根据九宫格位置计算原点
            let origin = textOrigin(
                textSize: textSize,
                canvasSize: size,
                position: config.position,
                padding: padding,
                dragOffset: config.dragOffset
            )

            // 4. 画文字
            (config.text as NSString).draw(at: origin, withAttributes: attrs)
        }
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
