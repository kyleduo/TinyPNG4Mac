//
//  models.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/24.
//

struct TPShrinkResponse: Decodable {
    struct Input: Decodable {
        let size: UInt64
        let type: String
    }

    struct Output: Decodable {
        let height: Int
        let width: Int
        let size: UInt64
        let ratio: Float
        let type: String
        let url: String
    }

    let input: Input?
    let output: Output?
    let error: String?
    let message: String?
}
