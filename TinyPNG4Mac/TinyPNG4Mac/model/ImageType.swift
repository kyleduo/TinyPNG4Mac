////
//  ImageType.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2025/3/26.
//

enum ImageType {
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
        }
    }
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
