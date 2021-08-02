//
//  SideMenuViewController.swift
//  Finder
//
//  Created by SuperDev on 27.05.2020.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var locationBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.shadowRadius = 2
        profileImageView.layer.shadowOpacity = 0.3
        profileImageView.layer.shadowColor = UIColor("#7b7b7b").cgColor
        profileImageView.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        profileImageView.generateOuterShadow()

        if let pic = currentuser?.object(forKey: u_dpSmall) as? String {
            self.profileImageView.sd_setImage(with: URL(string: pic), completed: nil)
        } else {
            if let gender = currentuser?.object(forKey: u_gender) as? Int {
                if gender == 1 {
                    self.profileImageView.image = UIImage(named: "ic_male")
                } else {
                    self.profileImageView.image = UIImage(named: "ic_female")
                }
            } else {
                self.profileImageView.image = UIImage(named: "ic_female")
            }
        }
        
        let image = locationBtn.image(for: .normal)
        locationBtn.setImage(image?.imageWithColor(color: UIColor(hex6: 0x999999)), for: .normal)
        
        if let user = currentuser {
            self.lblUserName.text = user.object(forKey: "name") as? String ?? ""
            self.locationBtn.setTitle(user.object(forKey: "locationText") as? String ?? "", for: .normal)
        } else {
            self.lblUserName.text = ""
            self.locationBtn.setTitle("", for: .normal)
        }
        
    }
    
    @IBAction func didTapLogout(sender: AnyObject) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        do {
            try Auth.auth().signOut()

            MBProgressHUD.hide(for: self.view, animated: true)
            USERDEFAULTS.set(0, forKey: "loginType")
           
           self.navigationController?.dismiss(animated: true, completion: {
               if let navVC = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
                   let vc = navVC.visibleViewController as? MainViewController {
                   vc.performSegue(withIdentifier: "logout", sender: vc)
               }
           })
        } catch {
            print("Sign out error")
        }
    }
    
    @IBAction func didTapTerms(sender: AnyObject) {
        
    }

}
