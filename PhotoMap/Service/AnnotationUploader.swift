//
//  AnnotationUploader .swift
//  PhotoMap
//
//  Created by Kirill Gorbachyonok on 11/2/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import Firebase
import FirebaseStorage

enum State {
    case new
    case updated
}

class AnnotationUploader {
    
    static private let storageRef = Storage.storage().reference().child("images")

    static func upload(
        annotation: PhotoMarkAnnotation,
        image: UIImage?,
        as newState: State
    ) {
        guard let user = Auth.auth().currentUser else { return }
        let annotationRef = Database.database().reference(withPath: "annotations/\(user.uid)").child(annotation.id)
        let annotationData = annotation.asDictionary
        switch newState {
        case .new:
            print("UPLOADING ANNOTATION...")
            upload(image: image, id: annotation.id) {
                [weak annotation] url in
                guard let url = url else {
                    print("BAD URL")
                    return
                }
                guard let annotation = annotation else {
                    print("ANNOTATION IS NIL WHEN UPLOADING")
                    return
                }
                annotation.imageURL = url.absoluteString
                let annotationRef = Database.database().reference(withPath: "annotations/\(user.uid)").child(annotation.id)
                annotationRef.setValue(annotation.asDictionary)
                print("ANNOTATION UPLOAD FINISHED")
            }
        case .updated:
            print("ANNOTATION UPDATE STARTED...")
            DispatchQueue.global().async { [annotationData] in
                annotationRef.updateChildValues(annotationData) { error, _ in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    print("ANNOTATION UPDATE FINISHED")
                }
            }
        }
    }
    
    private static func upload(
        image: UIImage?,
        id: String,
        completion: @escaping (URL?) -> Void
    ) {
        guard
            let image = image,
            let imageData = image.jpegData(compressionQuality: 1.0)
        else {
            print("UPLOAD IMAGE IS NIL")
            completion(nil)
            return
        }
        print("UPLOADING IMAGE...")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imageCache.setObject(image, forKey: id as NSString)
        let imageRef = storageRef.child(id)
        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("PUT DATA ERROR")
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("DOWNLOAD URL ERROR")
                    print(error.localizedDescription)
                    completion(nil)
                    return
                }
                DispatchQueue.global().async {
                    print("IMAGE UPLOAD FINISHED")
                    completion(url)
                }
            }
        }
    }
}
