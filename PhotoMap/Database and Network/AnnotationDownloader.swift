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
        complition: @escaping (PhotoMarkAnnotation) -> Void
    ) {
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
        DispatchQueue.main.async {
            complition(PhotoMarkAnnotation(
                id: id,
                title: title,
                date: date,
                imageURL: imageURL,
                coordinate: coordinate,
                category: category
            ))
        }
    }
        
    static func getImage(url: String?, or id: String, complition: @escaping (UIImage) -> Void) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let image = appDelegate.imageCache.object(forKey: id as NSString) {
            print("CACHE USED")
            complition(image)
        } else {
            guard
                let downloadString = url,
                let downloadUrl = URL(string: downloadString)
            else {
                return
            }
            print("DOWNLOADING IMAGE...")
            URLSession.shared.dataTask(with: downloadUrl) { [id] data, _, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    guard
                        let imageData = data,
                        let image = UIImage(data: imageData)
                    else {
                        return
                    }
                    DispatchQueue.main.async {
                        print("DOWNLOAD COMPLETE")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.imageCache.setObject(image, forKey: id as NSString)
                        complition(image)
                    }
                }
            }
            .resume()
        }
    }
    
}
