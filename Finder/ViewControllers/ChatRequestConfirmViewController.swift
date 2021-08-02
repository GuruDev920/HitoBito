//
//  ChatRequestConfirmViewController.swift
//  Nexpil
//
//  Created by Tai on 6/7/20.
//  Copyright © 2019 DJay. All rights reserved.
//

import UIKit

class ChatRequestConfirmViewController: UIViewController {

    @IBOutlet weak var imgvProfile  : UIImageView!
    @IBOutlet weak var lblUser      : UILabel!
    @IBOutlet weak var lblDescription: UILocalizedLabel!
    
    var user: NSDictionary?
    var userIndex = -1
    var delegateOtherProfile: OtherProfileViewControllerDelegate?
    var delegateMainViewController: MainViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Global_ShowFrostGlass(self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Global_HideFrostGlass()
    }
    
    private func initUI() {
        lblUser.text = self.user?.object(forKey: u_username) as? String ?? ""
        
        if let pic = user?.object(forKey: u_dpLarge) as? String {
            self.imgvProfile.sd_setImage(with: URL(string: pic), completed: nil)
        } else {
            if let gender = user?.object(forKey: u_gender) as? Int {
                if gender == 1 {
                    self.imgvProfile.image = UIImage(named: "ic_male")
                } else {
                    self.imgvProfile.image = UIImage(named: "ic_female")
                }
            } else {
                self.imgvProfile.image = UIImage(named: "ic_female")
            }
        }
        
        if let gender = user?.object(forKey: u_gender) as? Int {
            if gender == 1 {
                lblDescription.text = NSLocalizedString("Are you sure you want to send him a request to chat?", comment: "")
            } else if gender == 2 {
                lblDescription.text = NSLocalizedString("Are you sure you want to send her a request to chat?", comment: "")
            }
        }
    }
    
    @IBAction func onBtnConfirm(_ sender: Any) {
        dismiss(animated: true) {
            self.delegateOtherProfile?.confirmChatRequest()
            self.delegateMainViewController?.didConfirmChatRequest(userIndex: self.userIndex)
        }
    }
    
    @IBAction func onBtnCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
