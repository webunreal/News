//
//  Network.swift
//  News
//
//  Created by Nikolai Ivanov on 09.02.2021.
//

import UIKit

public struct Network {
    
    private let imageCache = NSCache<AnyObject, AnyObject>()
    
    private let newsApiUrl = "https://newsapi.org/v2/top-headlines?"
    private let country = "country=us&"
    private let apiKey = "apiKey=84c2f940d46e414cb934bb89de1693b0"
    
    public func loadData(completion: @escaping (Result<[News], Error>) -> Void) {
        var news: [News] = []
        guard let url = URL(string: newsApiUrl + country + apiKey) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
                    news = decodedResponse.articles
                    
                    DispatchQueue.main.async {
                        completion(.success(news))
                    }
                } catch DecodingError.dataCorrupted(let context) {
                    print(context)
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                }  catch DecodingError.valueNotFound(let value, let context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                }  catch DecodingError.typeMismatch(let type, let context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    public func downloadImage(imageURL: String, competion: @escaping((UIImage) -> Void)) {
        var urlToImage = imageURL
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

