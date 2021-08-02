//
//  MatchedPersonCell.swift
//  Finder
//
//  Created by Tai on 6/10/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit

class MatchedPersonCell: UICollectionViewCell {
    
    @IBOutlet weak var imgvProfile  : UIImageView!
    @IBOutlet weak var lblNameAge   : UILabel!
    @IBOutlet weak var lblTitle     : UILabel!
    @IBOutlet weak var lblDistance  : UILabel!
    @IBOutlet weak var imgvLocationIcon: UIImageView!
    @IBOutlet weak var btnChat      : UIButton!

    var delegate: MainViewControllerDelegate?
    
    private var userIndex = -1
    
    func initCell(user: NSDictionary?, userIndex: Int) {
        
        self.userIndex = userIndex
        
        guard let user = user else {
            self.imgvProfile.image = UIImage(named: "ic_female")
            self.lblNameAge.text = ""
            self.lblTitle.text = ""
            self.lblDistance.text = ""
            self.imgvLocationIcon.isHidden = true
            self.btnChat.isHidden = true
            return
        }
        
        if let pic = user.object(forKey: "dpLarge") as? String {
            self.imgvProfile.sd_setImage(with: URL(string: pic), completed: nil)
        } else {
            if let gender = user.object(forKey: "gender") as? Int {
                if gender == 1 {
                    self.imgvProfile.image = UIImage(named: "ic_male")
                } else {
                    self.imgvProfile.image = UIImage(named: "ic_female")
                }
            } else {
                self.imgvProfile.image = UIImage(named: "ic_female")
            }
        }
        
        let name = user.object(forKey: "name") as? String ?? ""
        let age = user.object(forKey: "age") as? Int ?? 30
        
        self.lblNameAge.text = String(format: "%@, %d", name, age)
        self.lblTitle.text = user.object(forKey: "about") as? String ?? ""
        
        self.imgvLocationIcon.isHidden = false
        
        self.lblDistance.text = "\(calcDistanceInKm(from: currentuser, to: user)) km"
//        if let mygeo = currentuser?.object(forKey: "location") as? PFGeoPoint, let getUsergeo = user.object(forKey: "location") as? PFGeoPoint {
//            
//            let distance = Int(mygeo.distanceInKilometers(to: getUsergeo))
//            self.lblDistance.text = "\(distance) km"
//            
//        } else {
//            self.lblDistance.text = "0 km"
//        }
        
        self.btnChat.isHidden = false
        
        self.setShadow()
    }

    private func setShadow() {
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width:0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.6
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5).cgPath
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onBtnChat(_ sender: Any) {
        self.delegate?.didChatRequest(userIndex: self.userIndex)
    }
}
