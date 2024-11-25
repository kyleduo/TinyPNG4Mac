////
//  Errors.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/24.
//


enum TaskError: Error {
    case apiError(statusCode: Int, message: String)
}

enum FileError: Error {
    case notExists
    case dstAlreadyExists
}
