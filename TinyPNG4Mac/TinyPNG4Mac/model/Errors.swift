////
//  Errors.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/24.
//

protocol TPError: Error {
    var code: Int { get }
    var message: String { get }
}

enum TaskError: Error, Equatable {
    case apiError(statusCode: Int, message: String)
    case general(message: String)
}

enum FileError: Error {
    case notExists
    case dstAlreadyExists
}

extension TaskError {
    static func from(error: Error?) -> TaskError {
        switch error {
        case is TaskError:
            error as! TaskError
        case is FileError:
            TaskError.general(message: "File error. \(error?.localizedDescription ?? "unknown")")
        default:
            TaskError.general(message: error?.localizedDescription ?? "unknown")
        }
    }

    static func from(message: String) -> TaskError {
        TaskError.general(message: message)
    }
}

extension TaskError {
    func displayText() -> String {
        switch self {
        case let .apiError(statusCode, message):
            return "[\(statusCode)]: \(message)"
        case let .general(message):
            return message
        }
    }
}
