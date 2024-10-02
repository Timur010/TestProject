//
//  Services.swift
//  TestProject
//
//  Created by Timur Kadiev on 30.09.2024.
//
import Foundation
import UIKit

@MainActor
class NewsServices: ObservableObject {
    @Published var news: [News] = []
    @Published var errorMessage: String? = nil
    
    init() {
        Task {
            await getInfo()
        }
    }
    
    func getInfo() async {
        guard let url = URL(string: "https://webapi.autodoc.ru/api/news/1/15") else {
            self.errorMessage = "Некорректный URL."
            return
        }
        do {
            let homeNews: HomeNews = try await NetworkingManager.shared.download(url: url, type: HomeNews.self)
            self.news = homeNews.news
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error: \(error.localizedDescription)")
        }
    }
}

