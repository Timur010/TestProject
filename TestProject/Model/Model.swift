//
//  Model.swift
//  TestProject
//
//  Created by Timur Kadiev on 30.09.2024.
//

import Foundation

// MARK: - Welcome
struct HomeNews: Codable {
    let news: [News]
    let totalCount: Int
}

// MARK: - News
struct News: Codable {
    let id: Int
    let title, description, publishedDate, url: String
    let fullURL: String
    let titleImageURL: String?
    let categoryType: CategoryType

    enum CodingKeys: String, CodingKey {
        case id, title, description, publishedDate, url
        case fullURL = "fullUrl"
        case titleImageURL = "titleImageUrl"
        case categoryType
    }
}

enum CategoryType: String, Codable {
    case autoNews = "Автомобильные новости"
    case KompaniNews = "Новости компании"
}
