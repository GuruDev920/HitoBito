//
//  AsyncPhotoMediaItem.swift
//  Finder
//
//  Created by Wang on 5/31/21.
//  Copyright © 2021 DJay. All rights reserved.
//

import Foundation
import SDWebImage

class AsyncPhotoMediaItem: JSQPhotoMediaItem {
    var asyncImageView: UIImageView!

    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }

    init(url: String) {
        super.init()
        asyncImageView = UIImageView()
        asyncImageView.frame = CGRect(x: 0, y: 0, width: 170, height: 130)
        asyncImageView.contentMode = .scaleAspectFill
        asyncImageView.clipsToBounds = true
        asyncImageView.layer.cornerRadius = 20
        asyncImageView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        
        SDWebImageManager.shared.loadImage(with: URL(string: url), options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image, data, error, type, finished, imageURL) in
            if let image = image {
                self.image = image
                self.asyncImageView.image = image
            }
        })
    }

    override func mediaView() -> UIView! {
        return asyncImageView
    }

    override func mediaViewDisplaySize() -> CGSize {
        return asyncImageView.frame.size
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
