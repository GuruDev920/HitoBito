//
//  ChatRequestAcceptViewController.swift
//  Finder
//
//  Created by Tai on 6/16/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit

protocol ChatRequestAcceptViewControllerDelegate {
    func didAcceptChatRequest(userId: String)
}

class ChatRequestAcceptViewController: UIViewController {
    
    @IBOutlet weak var imgView          : UIImageView!
    @IBOutlet weak var lblUserName      : UILabel!
    @IBOutlet weak var lblJob           : UILabel!
    @IBOutlet weak var lblUserLocation  : UILabel!
    @IBOutlet weak var lblUserDistance  : UILabel!
    @IBOutlet weak var imgLocationIcon  : UIImageView!
    @IBOutlet weak var lblChatWithYou: UILocalizedLabel!
    
    var delegate: ChatRequestAcceptViewControllerDelegate?
    var user    : NSDictionary?
    var byUser : NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    private func initUI() {
        
        guard let user = self.user else {
            self.lblUserName.text = ""
            self.lblUserDistance.text = ""
            self.lblUserLocation.text = ""
            self.lblChatWithYou.text = ""
            self.imgLocationIcon.isHidden = true
            self.imgView.image = UIImage(named: "ic_female")
            return
        }
        if let byUser = user.object(forKey: "byUser") as? NSDictionary{
            self.byUser = byUser
            let userData = UserData(user: byUser)
            
            if let pic = userData.dpLarge {
                self.imgView.sd_setImage(with: URL(string: pic), completed: nil)
            } else {
                if userData.gender == 1 {
                    self.imgView.image = UIImage(named: "ic_male")
                } else {
                    self.imgView.image = UIImage(named: "ic_female")
                }
            }
            
            self.lblChatWithYou.text = userData.fname + NSLocalizedString(" wants to chat with you.", comment: "")
            
            self.lblUserName.text = String(format: "%@, %d", userData.name, userData.age)
            self.lblJob.text = userData.job
            self.lblUserLocation.text = userData.locationText
            
            lblUserDistance.text = "\(calcDistanceInKm(from: currentuser, to: userData.location)) km"
        }
//            calcDistanceInKm(from: currentuser?.object(forKey: u_location) as? PFGeoPoint, to: userData.location)
    }
    
    @IBAction func onBtnMoreInfo(_ sender: UIButton) {
        guard let user = self.user else {
            return
        }
        
        let vcMoreDetails = self.storyboard?.instantiateViewController(withIdentifier: "ProfileMoreDetailsViewController") as! ProfileMoreDetailsViewController
        vcMoreDetails.modalPresentationStyle = .overFullScreen
        vcMoreDetails.modalTransitionStyle = .crossDissolve
        vcMoreDetails.user = user
        self.present(vcMoreDetails, animated: true, completion: nil)
    }
    
    @IBAction func onBtnClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBtnAccept(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        MatchManager.shared.updateMatch(liked: true, for: self.byUser!) { (likedback) in
            self.delegate?.didAcceptChatRequest(userId: (self.byUser?.object(forKey: "userId")) as! String)
        }
    }
    
    @IBAction func onBtnDecline(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        MatchManager.shared.updateMatch(liked: false, for: self.byUser!) { (likedback) in
        }
    }
}
