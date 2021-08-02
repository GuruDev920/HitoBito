//
//  ImageFunc.swift
//  Finder
//
//  Created by djay mac on 27/01/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit

func scaleImage(image: UIImage, and newSize: CGSize)->UIImage {
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImg = UIGraphicsGetImageFromCurrentImageContext()
    return newImg ?? UIImage()
}

func getImage(forKey: String, imgView: UIImageView) {
    // get user  pics
    if let pic = currentuser?.object(forKey: forKey) as? String {
        getImage(forUrl: pic, imgView: imgView)
//        pic.getDataInBackground { (data, error) in
//            if error == nil && data != nil{
//                imgView.image = UIImage(data: data!)
//            }
//        }
    }
}

func getImage(forUrl:String, callback: ((UIImage) -> ())?) {
    guard let imageURL = URL(string: forUrl) else { return }

        // just not to cause a deadlock in UI!
    DispatchQueue.global().async {
        guard let imageData = try? Data(contentsOf: imageURL) else { return }

        let image = UIImage(data: imageData)
        DispatchQueue.main.async {
            callback!(image!)
        }
    }
}

func getImage(forUrl:String,imgView:UIImageView) {
    // get user  pics
    guard let imageURL = URL(string: forUrl) else { return }

        // just not to cause a deadlock in UI!
    DispatchQueue.global().async {
        guard let imageData = try? Data(contentsOf: imageURL) else { return }

        let image = UIImage(data: imageData)
        DispatchQueue.main.async {
            imgView.image = image
        }
    }
}

func uploadImage(imageData: Data, callback: ((String?) -> ())?) {
    let storageRef = Storage.storage().reference().child("profileImages/\(String(Int64(Date().timeIntervalSince1970 * 1000))).png")
    
    // 3 Upload the file to the path "images/rivers.jpg"
    storageRef.putData(imageData, metadata: nil) { (metadata, error) in
        if error != nil {
            // 4 Uh-oh, an error occurred!
            DispatchQueue.main.async {
                callback?(nil)
            }
        }
        storageRef.downloadURL(completion: { (url, error) in
            if error != nil { callback?(nil) }
            DispatchQueue.main.async {
                callback!(url?.absoluteString)
            }
        })
    }
}
