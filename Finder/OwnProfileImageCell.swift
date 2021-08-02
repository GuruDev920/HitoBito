//
//  OwnProfileImageCell.swift
//  Finder
//
//  Created by Ying Yu on 5/22/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit

class OwnProfileImageCell: UITableViewCell {

    @IBOutlet weak var imgView          : UIImageView!
    @IBOutlet weak var lblUserAbout     : UILabel!
    @IBOutlet weak var lblUserName      : UILabel!
    @IBOutlet weak var lblJob           : UILabel!
    @IBOutlet weak var lblUserLocation  : UILabel!
    @IBOutlet weak var lblUserDistance  : UILabel!
    @IBOutlet weak var imgLocationIcon  : UIImageView!
    @IBOutlet weak var btnMoreInfo      : UIButton!
    
    var user    : NSDictionary?
    var parentVC: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgLocationIcon.image = UIImage(named: "ic_location")?.imageWithColor(color: .white)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(user: NSDictionary?, parentVC: UIViewController? = nil) {
        self.parentVC = parentVC
        
        guard let user = user else {
            self.lblUserName.text = ""
            self.lblUserDistance.text = ""
            self.lblUserLocation.text = ""
            self.imgLocationIcon.isHidden = true
            self.lblUserAbout.text = ""
            self.imgView.image = UIImage(named: "ic_female")
            return
        }
        
        self.user = user
        let userData = UserData(user: user)
        
        if let pic = userData.pics[u_pic1] {
            self.imgView.sd_setImage(with: URL(string: pic), completed: nil)
        } else {
            if userData.gender == 1 {
                self.imgView.image = UIImage(named: "ic_male")
            } else {
                self.imgView.image = UIImage(named: "ic_female")
            }
        }
        
        self.lblUserName.text = String(format: "%@, %d", userData.name, userData.age)
        self.lblJob.text = userData.job
        self.lblUserLocation.text = userData.locationText
        self.lblUserAbout.text = userData.about
        
        if user != currentuser {
            self.btnMoreInfo.isHidden = false
            self.imgLocationIcon.isHidden = false
            lblUserDistance.text = "\(calcDistanceInKm(from: currentuser, to: userData.location)) km"
//            lblUserDistance.text = calcDistanceInKm(from: currentuser?.object(forKey: u_location) as? PFGeoPoint, to: userData.location)
            self.imgLocationIcon.isHidden = true
            lblUserDistance.text = ""
        } else {
            self.btnMoreInfo.isHidden = true
            self.imgLocationIcon.isHidden = true
            lblUserDistance.text = ""
        }
    }
    
    @IBAction func onBtnMoreInfo(_ sender: UIButton) {
        guard let parentVC = self.parentVC, let user = self.user else {
            return
        }
        
        let vcMoreDetails = parentVC.storyboard?.instantiateViewController(withIdentifier: "ProfileMoreDetailsViewController") as! ProfileMoreDetailsViewController
        vcMoreDetails.modalPresentationStyle = .overFullScreen
        vcMoreDetails.modalTransitionStyle = .crossDissolve
        vcMoreDetails.user = user
        parentVC.present(vcMoreDetails, animated: true, completion: nil)
    }
}
