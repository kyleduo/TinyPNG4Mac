////
//  ImageType.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2025/3/26.
//

enum ImageType {
    /// Indicator for auto converting, not a real type.
    case auto

    case avif
    case jpeg
    case png
    case webp
}

extension ImageType {
    func toContentType() -> String {
        switch self {
        case .avif:
            return "image/avif"
        case .jpeg:
            return "image/jpeg"
        case .png:
            return "image/png"
        case .webp:
            return "image/webp"
        default:
            return ""
        }
    }

    func fileSuffix() -> String {
        switch self {
        case .avif:
            return "avif"
        case .jpeg:
            return "jpeg"
        case .png:
            return "png"
        case .webp:
            return "webp"
        default:
            return ""
        }
    }
}

extension ImageType {
    func toDisplayName() -> String {
        switch self {
        case .avif:
            return "AVIF"
        case .jpeg:
            return "JPEG"
        case .png:
            return "PNG"
        case .webp:
            return "WEBP"
        default:
            return ""
        }
    }
}

extension ImageType {
    static let allTypes = [
        ImageType.png,
        ImageType.jpeg,
        ImageType.webp,
        ImageType.avif,
    ]
}

extension ImageType {
    static func fromContentType(contentType: String) -> ImageType? {
        switch contentType {
        case "image/avif":
            return .avif
        case "image/jpeg":
            return .jpeg
        case "image/png":
            return .png
        case "image/webp":
            return .webp
        default:
            return nil
        }
    }
}

/// Used for config storage
extension ImageType {
    static func fromConfigName(name: String) -> ImageType? {
        switch name {
        case "avif":
            return .avif
        case "jpeg":
            return .jpeg
        case "png":
            return .png
        case "webp":
            return .webp
        case "auto":
            return .auto
        default:
            return nil
        }
    }

    func toConfigName() -> String {
        switch self {
        case .avif:
            return "avif"
        case .jpeg:
            return "jpeg"
        case .png:
            return "png"
        case .webp:
            return "webp"
        case .auto:
            return "auto"
        }
    }
}
