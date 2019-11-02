//
//  AnnotationUploader .swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 11/2/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import Firebase
import FirebaseStorage

class AnnotationUploader {
    
    static private let dbRef = Database.database().reference(withPath: "annotations")
    static private let storageRef = Storage.storage().reference().child("images")

    static func upload(annotation: PhotoMarkAnnotation) {
        upload(image: annotation.image, id: annotation.id) { url in
            guard let url = url else {
                print("BAD URL")
                return
            }
            let annotationData = toDictionary(for: annotation, and: url.absoluteString)
            let annotationRef = dbRef.child(annotation.id)
            annotationRef.setValue(annotationData)
        }
    }
    
    private static func upload(image: UIImage, id: String, compelition: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        let imageRef = storageRef.child(id)
        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("PUT DATA ERROR")
                print(error.localizedDescription)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("DOWNLOAD URL ERROR")
                    print(error.localizedDescription)
                    return
                }
                compelition(url)
            }
        }
    }
    
    private static func toDictionary(for annotation: PhotoMarkAnnotation, and imageURL: String) -> [String: Any] {
        [
            "id": annotation.id,
            "title": annotation.title as Any,
            "imageURL": imageURL,
            "date": annotation.date.toString(with: .full),
            "coordinate": "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)",
            "category": annotation.category.asString
        ]
    }
}
