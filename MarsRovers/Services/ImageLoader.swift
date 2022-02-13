//
//  ImageLoader.swift
//  VKApp
//
//  Created by Denis Kuzmin on 08.06.2021.
//

import UIKit

final class ImageLoader: ObservableObject {

    static private var imageCache = NSCache<NSString, UIImage>()
    static private let cacheLifeTime: TimeInterval = 7 * 24 * 60 * 60
    //private let queue = DispatchQueue(label: "com.gb.isolationQ")
    
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
    
    static func getImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        if let image = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                completion(image)
            }
        }
        else if let image = getImageFromDisk(urlString: urlString){
            DispatchQueue.main.async {
                completion(image)
            }
        }
        else {
            loadImage(from: urlString, completion: completion)
        }
    }
    
    static private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        getData(from: urlString) { data in
            guard let image = UIImage(data: data) else { return completion(nil) }
            
            DispatchQueue.main.async {
                completion(image)
            }
            self.imageCache.setObject(image, forKey: urlString as NSString)
            saveImageToDisk(urlString: urlString, image: image)
        }
    }
    
    static private func getData(from url: String, completionBlock: @escaping (Data) -> Void) {
        guard let url = URL(string: url)
        else {
            print("Error: Invalid url")
            return
        }
        
        var request = URLRequest(url: url,timeoutInterval: 5.0)
        request.addValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

        request.httpMethod = "GET"
        
        DispatchQueue.global().async {
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                guard error == nil else {
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
                }
            }
            task.resume()
        }
    }
    
}


