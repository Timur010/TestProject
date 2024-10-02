//
//  NetworkingManager.swift
//  TestProject
//
//  Created by Timur Kadiev on 30.09.2024.
//

import Foundation
import UIKit

enum NetworkingError: LocalizedError {
    case badURLResponse(url: URL)
    case decodingError(underlying: Error)
    case invalidImageData(url: URL)
    case unknown

    var errorDescription: String? {
        switch self {
        case .badURLResponse(url: let url):
            return "Плохой ответ от URL: \(url)"
        case .decodingError(let underlying):
            return "Ошибка декодирования: \(underlying.localizedDescription)"
        case .invalidImageData(url: let url):
            return "Неверные данные изображения от URL: \(url)"
        case .unknown:
            return "Произошла неизвестная ошибка."
        }
    }
}

final class NetworkingManager {
    
    static let shared = NetworkingManager()
    
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    
    private init(session: URLSession = .shared, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.jsonDecoder = jsonDecoder
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        self.jsonDecoder.dateDecodingStrategy = .iso8601
    }
    

    func download<T: Decodable>(url: URL, type: T.Type) async throws -> T {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkingError.badURLResponse(url: url)
        }
        
        do {
            let decodedData = try jsonDecoder.decode(T.self, from: data)
            return decodedData
        } catch {
            throw NetworkingError.decodingError(underlying: error)
        }
    }
}
