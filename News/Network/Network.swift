//
//  Network.swift
//  News
//
//  Created by Nikolai Ivanov on 09.02.2021.
//

import UIKit

public struct Network {
    private let imageCache = NSCache<AnyObject, AnyObject>()
    private let baseURL = "https://newsapi.org/v2/top-headlines"
    private let apiKey = "84c2f940d46e414cb934bb89de1693b0"
    
    public func loadNewsData(searchingText: String?, country: String, category: String, completion: @escaping (Result<[News], Error>) -> Void) {
        
        guard let queryURL = URL(string: baseURL) else { return }
        let  components = URLComponents(url: queryURL, resolvingAgainstBaseURL: true)
        guard var urlComponents = components else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "q", value: searchingText ?? ""),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "categoty", value: category.lowercased())
        ]
        guard let finalURL = urlComponents.url else { return }
   
        let request = URLRequest(url: finalURL)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
                    let news = decodedResponse.articles
                    completion(.success(news))
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                    completion(.failure(DecodingError.dataCorrupted(context)))
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(DecodingError.keyNotFound(key, context)))
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(DecodingError.valueNotFound(value, context)))
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    completion(.failure(DecodingError.typeMismatch(type, context)))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    public func loadImage(imageUrl: String, competion: @escaping((UIImage) -> Void)) {
        var urlToImage = imageUrl
        if let afterJpg = urlToImage.range(of: ".jpg") {
            urlToImage.removeSubrange(afterJpg.upperBound..<urlToImage.endIndex)
        }
        
        if let imageFromCache = readFromCache(url: urlToImage) {
            competion(imageFromCache)
        } else {
            guard let url = URL(string: urlToImage) else {
                competion(UIImage(named: "noImage") ?? UIImage())
                return
            }
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        guard let image = UIImage(data: data) else {
                            competion(UIImage(named: "noImage") ?? UIImage())
                            return }
                        writeToCache(image: image, url: urlToImage)
                        competion(image)
                    }
                } catch {
                    DispatchQueue.main.async {
                        competion(UIImage(named: "noImage") ?? UIImage())
                    }
                    print("error: ", error.localizedDescription)
                }
            }
        }
    }
    
    private func readFromCache(url: String) -> UIImage? {
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
            return imageFromCache
        }
        return nil
    }
    
    private func writeToCache(image: UIImage, url: String) {
        imageCache.setObject(image, forKey: url as AnyObject)
    }
}
