//
//  ProfileImagesCell.swift
//  Finder
//
//  Created by Ying Yu on 5/22/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit

public protocol ProfileImagesCellDelegate: class {
    func photoButtonTapped(_ index: Int)
    func photoImageTapped(_ index: Int, images: [UIImage])
}

class ProfileImagesCell: UITableViewCell {
    
    weak var delegate: ProfileImagesCellDelegate?

    @IBOutlet weak var imageContainers: UIView!
    
    private var images: [UIImage] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }
    
    var photos:[String]?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        for view in  imageContainers.subviews{
            view.removeFromSuperview()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.imageContainers.layoutIfNeeded()
    }
  
    func initCell(photos:[String], isMyProfile: Bool = true) {
        
        self.imageContainers.subviews.forEach({ $0.removeFromSuperview() })
        
        self.photos = photos
        
        let spacing: CGFloat = 15
        let verticalPadding: CGFloat = 15
        let horizontalPadding: CGFloat = 7
        let bounds = UIScreen.main.bounds
        let width: CGFloat = bounds.size.width
        let cellWidth: CGFloat = (width - horizontalPadding * 2 - spacing * 2) / 3
        let cellHeight: CGFloat = cellWidth * 9 / 10
        
        guard let photos = self.photos else{
            return
        }
        
        let hasAddPhotoButton: Bool = (isMyProfile && photos.count < 6) ? true : false
        
        let imgPlaceHolder = UIImage(named: "img_placeholder")
        for i in 0..<photos.count + (hasAddPhotoButton ? 1 : 0) {
            var frameView: CGRect
            if i == 0 {
                if photos.count == 0 {
                    frameView = CGRect(x: horizontalPadding,
                                       y: verticalPadding,
                                       width: cellWidth,
                                       height: cellHeight)
                } else {
                    frameView = CGRect(x: horizontalPadding,
                                       y: verticalPadding,
                                       width: cellWidth * 2 + spacing,
                                       height: cellHeight * 2 + spacing)
                }
            } else if i == 1 {
                frameView = CGRect(x: cellWidth * 2 + spacing * 2 + horizontalPadding,
                                   y: verticalPadding,
                                   width: cellWidth,
                                   height: cellHeight)
            } else if i == 2 {
                frameView = CGRect(x: cellWidth * 2 + spacing * 2 + horizontalPadding,
                                   y: verticalPadding + cellHeight + spacing,
                                   width: cellWidth,
                                   height: cellHeight)
            } else {
                let j: Int = i - 3
                let yIndex:Int = j / 3
                let xIndex:Int = j % 3
                
                let xPos = (cellWidth + spacing) * CGFloat(xIndex)  + horizontalPadding
                let yPos = verticalPadding + (cellHeight * 2 + spacing) + (cellHeight * CGFloat(yIndex)) + (CGFloat(yIndex) + 1) * spacing
                
                frameView = CGRect(x: xPos, y: yPos, width: cellWidth , height: cellHeight)
            }
            
            if hasAddPhotoButton, i == photos.count {
                let addBtnView = UIButton(frame: frameView)
                addBtnView.setBackgroundImage(UIImage(named: "img_add_photo"), for: .normal)
                addBtnView.tag = i
                addBtnView.addTarget(self, action: #selector(photoBtnTapped(button:)), for: UIControl.Event.touchUpInside)
                self.imageContainers.addSubview(addBtnView)
            } else {
                let photoView = UIImageView(frame: frameView)
                photoView.contentMode = .scaleAspectFill
                photoView.backgroundColor = .lightGray
                photoView.layer.masksToBounds = true
                photoView.layer.cornerRadius = 15
                self.imageContainers.addSubview(photoView)
                let button = UIButton(frame:frameView)
                button.tag = i
                button.addTarget(self, action: #selector(photoBtnTapped(button:)), for: UIControl.Event.touchUpInside)
                self.imageContainers.addSubview(button)
                
                photoView.image = imgPlaceHolder
                photoView.tag = i
                let fileImage = photos[i]
                self.images.removeAll()
                photoView.sd_setImage(with: URL(string: fileImage), completed: nil)
                getImage(forUrl: fileImage) { (image) in
                    self.images.append(image)
                }
            }
        }
            
        self.imageContainers.layoutIfNeeded()
    }
    
    @objc func photoBtnTapped(button: UIButton) {
        delegate?.photoButtonTapped(button.tag)
        
        if button.tag < self.images.count {
            delegate?.photoImageTapped(button.tag, images: self.images)
        }
    }
}
