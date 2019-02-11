//
//  StorageManager.swift
//  Yapper
//
//  Created by Jonas Theslöf on 2019-02-11.
//  Copyright © 2019 Jonas Theslöf. All rights reserved.
//

import Foundation
import Firebase

class StorageManager {
    private static let TAG: String = "StorageManager"
    static let shared = StorageManager()
    private let db: Storage = Storage.storage()

    private init() {}
    
    func uploadImage(_ image: UIImage, completion: @escaping ((URL?, Error?) -> Void)) {
        guard
            let resizedImage = image.resizeWithSize(1024),
            let imageData = resizedImage.jpegData(compressionQuality: 0.9) else { return }
        let ref = db.reference(withPath: "images/\(UUID().uuidString)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        Log.d(StorageManager.TAG, "Attempting to upload image")
        ref.putData(imageData, metadata: metadata) { (meta, error) in
            if meta != nil {
                Log.d(StorageManager.TAG, "Successfully uploaded image")
                ref.downloadURL(completion: completion)
            } else if let error = error {
                Log.e(StorageManager.TAG, "Error while uploading image")
                completion(nil, error)
            }
        }
    }
}

extension UIImage {
    func resizeWithSize(_ size: CGFloat) -> UIImage? {
        let aspect = self.size.width / self.size.height
        let newSize = aspect > 1 ? CGSize(width: size, height: size / aspect) : CGSize(width: size * aspect, height: size)
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: newSize))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
