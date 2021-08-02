//
//  NewRequestViewController.swift
//  Finder
//
//  Created by Wang on 6/3/21.
//  Copyright © 2021 DJay. All rights reserved.
//

import UIKit

protocol NewRequestViewControllerDelegate {
    func didAcceptNewRequest(userId: String)
    func didDeclineNewRequest(userId: String)
}

class NewRequestViewController: UIViewController {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtJob: UILabel!
    @IBOutlet weak var txtAddress: UILabel!
    @IBOutlet weak var txtChat: UILocalizedLabel!
    
    var delegate: NewRequestViewControllerDelegate?
    var user    : NSDictionary?
    var byUser : NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    
    private func initUI() {
        guard let user = self.user else {
            self.txtUsername.text = ""
            self.txtAddress.text = ""
            self.txtJob.text = ""
            self.txtChat.text = ""
            self.imgUser.image = UIImage(named: "ic_female")
            return
        }

        if let byUser = user.object(forKey: "byUser") as? NSDictionary{
            self.byUser = byUser
            let userData = UserData(user: byUser)
            
            if let pic = userData.dpLarge {
                self.imgUser.sd_setImage(with: URL(string: pic), completed: nil)
            } else {
                if userData.gender == 1 {
                    self.imgUser.image = UIImage(named: "ic_male")
                } else {
                    self.imgUser.image = UIImage(named: "ic_female")
                }
            }
            
            self.txtChat.text = userData.fname + NSLocalizedString(" wants to chat with you.", comment: "")
            
            self.txtUsername.text = String(format: "%@, %d", userData.name, userData.age)
            self.txtJob.text = userData.job
            self.txtAddress.text = userData.locationText
        }
    }

    @IBAction func onBtnAccept(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        MatchManager.shared.updateMatch(liked: true, for: self.byUser!) { (likedback) in
            self.delegate?.didAcceptNewRequest(userId: (self.byUser?.object(forKey: "userId")) as! String)
        }
    }
    
    @IBAction func onBtnDecline(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        MatchManager.shared.updateMatch(liked: false, for: self.byUser!) { (likedback) in
            self.delegate?.didDeclineNewRequest(userId: (self.byUser?.object(forKey: "userId")) as! String)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
