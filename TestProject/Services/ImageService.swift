//
//  ImageService.swift
//  TestProject
//
//  Created by Timur Kadiev on 01.10.2024.
//

import UIKit

actor ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let fileManager = FileManager.default
    private let diskCacheURL: URL
    
    private var ongoingRequests: [URL: [CheckedContinuation<UIImage?, Never>]] = [:]
    
    private init() {
        if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            diskCacheURL = cacheDirectory.appendingPathComponent("ImageCache", isDirectory: true)
            if !fileManager.fileExists(atPath: diskCacheURL.path) {
                try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
            }
        } else {
            fatalError("Не удалось найти директорию кэша.")
        }
        
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func loadImage(from url: URL) async -> UIImage? {
        if let image = memoryCache.object(forKey: url as NSURL) {
            return image
        }
        
        let diskPath = diskCacheURL.appendingPathComponent(url.lastPathComponent)
        if let image = UIImage(contentsOfFile: diskPath.path) {
            memoryCache.setObject(image, forKey: url as NSURL)
            return image
        }
        
        if ongoingRequests[url] != nil {
            return await withCheckedContinuation { continuation in
                ongoingRequests[url]?.append(continuation)
            }
        }
        
        ongoingRequests[url] = []
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                await notifyOngoingRequests(for: url, with: nil)
                return nil
            }
            
            memoryCache.setObject(image, forKey: url as NSURL)
            
            try? data.write(to: diskPath)
            
            await notifyOngoingRequests(for: url, with: image)
            
            return image
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            await notifyOngoingRequests(for: url, with: nil)
            return nil
        }
    }
    
    private func notifyOngoingRequests(for url: URL, with image: UIImage?) async {
        if let completions = ongoingRequests[url] {
            for continuation in completions {
                continuation.resume(returning: image)
            }
            ongoingRequests[url] = nil
        }
    }
    
    func clearCache() async {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheURL)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
    }
}
