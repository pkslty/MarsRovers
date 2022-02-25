//
//  ImageLoader.swift
//  VKApp
//
//  Created by Denis Kuzmin on 08.06.2021.
//

import UIKit
import Combine

final class ImageLoader {
    
    enum ImageLoaderError: Error {
        case invalidUrl
        case corruptedData
        case noData
    }

    static private var imageCache = NSCache<NSString, UIImage>()
    static private let cacheLifeTime: TimeInterval = 7 * 24 * 60 * 60
    static private let queue = DispatchQueue(label: "ImageLoaderQueue")
    
    private static let pathName: String = {
        let pathName = "Images"
        guard
            let cacheDir = FileManager
            .default
            .urls(
                for: .cachesDirectory,
                in: .userDomainMask)
            .first
        else { return pathName }
        let url = cacheDir
            .appendingPathComponent(
                pathName,
                isDirectory: true)
        if !FileManager
            .default
            .fileExists(atPath: url.path) {
            try? FileManager
                .default
                .createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil)
        }
        
        return pathName
    }()
    
    static func getImagePublisher(from urlString: String) -> AnyPublisher<UIImage?, Error> {
        
        if let image = imageCache.object(forKey: urlString as NSString) {
            return Just(image)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else if let image = getImageFromDisk(urlString: urlString){
            return Just(image)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else {
            return Future<UIImage?, Error> { promise in
                loadImage(from: urlString) { image, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(image))
                    }
                }
            }
            .eraseToAnyPublisher()
            
        }
    }
    
    static private func getFilePath(at urlString: String) -> String? {
        guard
            let cacheDir = FileManager
                .default
                .urls(
                    for: .cachesDirectory,
                    in: .userDomainMask)
                .first,
            let fileName = urlString
                .split(separator: "/")
                .last?
                .split(separator: "?")
                .first
        else { return nil }
        return cacheDir
            .appendingPathComponent("\(ImageLoader.pathName)/\(fileName)")
            .path
    }
    
    static private func removeImageFromDisk(urlString: String) {
        guard
            let fileName = getFilePath(at: urlString),
            let url = URL(string: fileName),
            FileManager.default.fileExists(atPath: fileName)
        else { return }
        do {
            try FileManager
                .default
                .removeItem(at: url)
        } catch {
            print("ImageLoader Error: \(error.localizedDescription)")
            print("ImageLoader url: \(url)")
        }
        
    }
    
    // MARK: Save cache image
    static private func saveImageToDisk(
        urlString: String,
        image: UIImage) {
        guard let fileName = getFilePath(at: urlString) else { return }
        let data = image.pngData()
        FileManager
            .default
            .createFile(
                atPath: fileName,
                contents: data,
                attributes: nil)
    }
    
    // MARK: Load image cache
    static private func getImageFromDisk(urlString: String) -> UIImage? {
        guard
            let fileName = getFilePath(at: urlString),
            let fileInfo = try? FileManager
                .default
                .attributesOfItem(atPath: fileName),
            let modificationDate = fileInfo[FileAttributeKey.modificationDate]
                as? Date
        else { return nil }
        let lifetime = Date()
            .timeIntervalSince(modificationDate)
        guard
            lifetime <= cacheLifeTime,
            let image = UIImage(contentsOfFile: fileName)
        else {
            removeImageFromDisk(urlString: urlString)
            return nil
        }
        

        ImageLoader.imageCache.setObject(image, forKey: urlString as NSString)
        
        return image
    }
    
    static func getImage(from urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
        
        if let image = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                completion(image, nil)
            }
        }
        else if let image = getImageFromDisk(urlString: urlString){
            DispatchQueue.main.async {
                completion(image, nil)
            }
        }
        else {
            loadImage(from: urlString, completion: completion)
        }
    }
    
    static private func loadImage(from urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
        
        getData(from: urlString) { data, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, ImageLoaderError.noData)
                }
                return
            }
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil, ImageLoaderError.corruptedData)
                }
                return
            }
            DispatchQueue.main.async {
                completion(image, nil)
            }
            self.imageCache.setObject(image, forKey: urlString as NSString)
            saveImageToDisk(urlString: urlString, image: image)
        }
    }
    
    static private func getData(from url: String, completionBlock: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: url)
        else {
            completionBlock(nil, ImageLoaderError.invalidUrl)
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: 15.0)
        //request.addValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

        request.httpMethod = "GET"
        
        queue.async {
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                /*guard error == nil else {
                    print("NetworkService error: \(String(describing: error))")
                    print("URL: \(url)")
                    return
                }
                guard let data = data
                else {
                    print("NetworkService error: No data")
                    return
                }
                DispatchQueue.main.async {
                    completionBlock(data)
                }*/
                completionBlock(data, error)
            }
            task.resume()
        }
    }
}


