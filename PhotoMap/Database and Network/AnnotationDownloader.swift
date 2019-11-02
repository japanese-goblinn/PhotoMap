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
        let annotationDict = snapshot.value as! [String: Any]
        print(annotationDict as AnyObject)
        downloadImage(url: annotationDict["imageURL"] as? String) { image in
            guard
                let id = annotationDict["id"] as? String,
                let title = annotationDict["title"] as? String?,
                let dateString = annotationDict["date"] as? String,
                let coordinateString = annotationDict["coordinate"] as? String,
                let categoryString = annotationDict["category"] as? String
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
            
            complition(PhotoMarkAnnotation(
                id: id,
                title: title,
                date: date,
                image: image,
                coordinate: coordinate,
                category: category
            ))
        }
    }
        
    private static func downloadImage(url: String?, complition: @escaping (UIImage) -> Void) {
        guard
            let downloadString = url,
            let downloadUrl = URL(string: downloadString)
        else {
            return
        }
        URLSession.shared.dataTask(with: downloadUrl) { data, _, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard
                    let imageData = data,
                    let image = UIImage(data: imageData)
                else {
                    return
                }
                complition(image)
            }
        }
        .resume()
    }
    
}
