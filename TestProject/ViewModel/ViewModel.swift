//
//  ViewModel.swift
//  TestProject
//
//  Created by Timur Kadiev on 30.09.2024.
//

import Foundation
import Combine

@MainActor
class HomeViewModel {
    private var newsService: NewsServices
    private var cancellables = Set<AnyCancellable>()
    
    @Published var news: [News] = []
    
    init(service: NewsServices) {
        self.newsService = service
        addNews()
    }
    
    func addNews() {
        newsService.$news
            .sink { [weak self] (info) in
                self?.news = info
            }
            .store(in: &cancellables)
    }
}
