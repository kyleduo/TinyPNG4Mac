////
//  Errors.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/24.
//


enum TaskError: Error {
    case apiError(message: String)
}

enum FileError: Error {
    case notExists
}