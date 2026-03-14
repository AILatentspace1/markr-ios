import SwiftUI

// MARK: - Watermark Position

enum WatermarkPosition: String, CaseIterable, Identifiable, Equatable {
    case topLeft      = "左上"
    case topCenter    = "上中"
    case topRight     = "右上"
    case middleLeft   = "左中"
    case center       = "居中"
    case middleRight  = "右中"
    case bottomLeft   = "左下"
    case bottomCenter = "下中"
    case bottomRight  = "右下"

    var id: String { rawValue }

    var alignment: Alignment {
        switch self {
        case .topLeft:      return .topLeading
        case .topCenter:    return .top
        case .topRight:     return .topTrailing
        case .middleLeft:   return .leading
        case .center:       return .center
        case .middleRight:  return .trailing
        case .bottomLeft:   return .bottomLeading
        case .bottomCenter: return .bottom
        case .bottomRight:  return .bottomTrailing
        }
    }

    /// 用于九宫格 UI 的行列索引
    var row: Int {
        switch self {
        case .topLeft, .topCenter, .topRight:       return 0
        case .middleLeft, .center, .middleRight:    return 1
        case .bottomLeft, .bottomCenter, .bottomRight: return 2
        }
    }

    var col: Int {
        switch self {
        case .topLeft, .middleLeft, .bottomLeft:       return 0
        case .topCenter, .center, .bottomCenter:       return 1
        case .topRight, .middleRight, .bottomRight:    return 2
        }
    }

    static func from(row: Int, col: Int) -> WatermarkPosition {
        WatermarkPosition.allCases.first { $0.row == row && $0.col == col } ?? .bottomRight
    }
}

// MARK: - Watermark Config

struct WatermarkConfig: Equatable {
    var text: String       = "© Markr"
    var fontSize: CGFloat  = 28
    var color: Color       = .white
    var opacity: CGFloat   = 0.8
    var position: WatermarkPosition = .bottomRight
    /// 拖拽微调偏移
    var dragOffset: CGSize = .zero
}
