//
//  News.swift
//  News
//
//  Created by Nikolai Ivanov on 09.02.2021.
//

import Foundation

public struct News: Decodable {
    var source: Source
    var author: String?
    var title: String
    var description: String?
    var urlToSource: String
    var urlToImage: String?
    var publishedAt : String
    var content: String?
    
    enum CodingKeys: String, CodingKey {
        case source
        case author
        case title
        case description
        case urlToSource = "url"
        case urlToImage
        case publishedAt
        case content
    }
}

public struct Source: Decodable {
    var name: String
}

public struct Response: Decodable {
    var articles: [News]
}
