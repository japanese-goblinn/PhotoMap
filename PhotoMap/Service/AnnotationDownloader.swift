//
//  AnnotationDownloader.swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 11/2/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import Firebase
import CoreLocation

class AnnoationDownloader {
    
    static func getAnnotation(
        from snapshot: DataSnapshot,
        completion: @escaping (PhotoMarkAnnotation?) -> Void
    ) {
        var annotation: PhotoMarkAnnotation? = nil
        defer {
            DispatchQueue.main.async {
                completion(annotation)
            }
        }
        guard
            let annotationData = snapshot.value as? [String: Any],
            let id = annotationData["id"] as? String,
            let title = annotationData["title"] as? String?,
            let dateString = annotationData["date"] as? String,
            let imageURL = annotationData["imageURL"] as? String?,
            let coordinateString = annotationData["coordinate"] as? String,
            let categoryString = annotationData["category"] as? String
        else {
            print("JSON PARSING ERROR")
            return
        }
        
        guard let date = dateString.toDate(with: .full) else {
            print("DATE PARSING ERROR")
            return
        }
        
        guard let coordinate = CLLocationCoordinate2D.getCoordinate(from: coordinateString) else {
            print("COORDINATE PARSING ERROR")
            return
        }
        
        guard let category = Category.toCategory(from: categoryString) else {
            print("CATEGORY PARSING ERROR")
            return
        }
        annotation = PhotoMarkAnnotation(
            id: id,
            title: title,
            date: date,
            imageURL: imageURL,
            coordinate: coordinate,
            category: category
        )
    }
        
    static func getImage(url: String?, or id: String, completion: @escaping (UIImage?) -> Void) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let image = appDelegate.imageCache.object(forKey: id as NSString) {
            print("CACHE USED")
            completion(image)
        } else {
            guard
                let downloadString = url,
                let downloadUrl = URL(string: downloadString)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            print("DOWNLOADING IMAGE...")
            URLSession.shared.dataTask(with: downloadUrl) {
                [id] data, response, error in
                guard
                    let imageData = data,
                    let image = UIImage(data: imageData),
                    let response = response as? HTTPURLResponse
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                switch response.statusCode {
                case 200..<300:
                    print("STATUS CODE \(response.statusCode)")
                default:
                    print("BAD STATUS CODE \(response.statusCode)")
                    completion(nil)
                    return
                }
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil)
                    return
                }
                DispatchQueue.main.async {
                    print("DOWNLOAD COMPLETE")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.imageCache.setObject(image, forKey: id as NSString)
                    completion(image)
                }
            }
            .resume()
        }
    }
    
}
