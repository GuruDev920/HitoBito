//
//  OtherProfileViewController.swift
//  Finder
//
//  Created by SuperDev on 02.06.2020.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit

protocol OtherProfileViewControllerDelegate {
    func confirmChatRequest()
}

class OtherProfileViewController: UIViewController {
    
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var viewProfileContainer: UIView!
    @IBOutlet weak var btnChatRequest: UIButton!
    
    var user: NSDictionary?
    var userIndex = -1
    var userpics: [String] = []
    var delegateMainViewController: MainViewControllerDelegate?
    var isChatRequested = true
    
    private var isFirst = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if user == nil {
            return
        }
        
        registerCell()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirst {
            self.getPhotos(forKey: user_picKeys)
            self.isFirst = false
        }
        
        self.profileTableView.setContentOffset(CGPoint(x: 0, y: 1), animated: true)
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moreBtnTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: NSLocalizedString("Choose", comment: ""), message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Report", comment: ""), style: .default, handler: { (alertAction) in
            let report = NSMutableDictionary() // PFObject(className: "Report")
            let temp: String = String(Int64(Date().timeIntervalSince1970))
            report.setValue(temp, forKey: "objectId")
            report.setValue(currentuser, forKey: "byUser")
            report.setValue(self.user, forKey: "ReportedUser")
            saveReportInBackground(report: report) { (result) in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
//            report["byUser"] = currentuser
//            report["ReportedUser"] = self.user
//            report.saveInBackground { (success, error) -> Void in
//                if error == nil {
//                    self.navigationController?.popViewController(animated: true)
//                }
//            }
        }))
        alertController.addAction(UIAlertAction(title: L_CANCEL, style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onBtnChatRequest(_ sender: Any) {
        guard let user = self.user else {
            return
        }
        
        let vcConfirm = storyboard?.instantiateViewController(withIdentifier: "ChatRequestConfirmViewController") as! ChatRequestConfirmViewController
        vcConfirm.modalPresentationStyle = .overFullScreen
        vcConfirm.modalTransitionStyle = .crossDissolve
        vcConfirm.user = user
        vcConfirm.userIndex = self.userIndex
        vcConfirm.delegateOtherProfile = self
        vcConfirm.delegateMainViewController = self.delegateMainViewController
        self.present(vcConfirm, animated: true, completion: nil)
    }
    
    private func registerCell() {
        
        let ownProfileImageCell = UINib(nibName: "OwnProfileImageCell",
                            bundle: nil)
        self.profileTableView.register(ownProfileImageCell,
                                forCellReuseIdentifier: "OwnProfileImageCell")
        let ownProfilePhotosButtonCell = UINib(nibName: "ProfilePhotosButtonCell",
                            bundle: nil)
        self.profileTableView.register(ownProfilePhotosButtonCell,
                                forCellReuseIdentifier: "ProfilePhotosButtonCell")
        let ownProfileImagesCell = UINib(nibName: "ProfileImagesCell",
                            bundle: nil)
        self.profileTableView.register(ownProfileImagesCell,
                                forCellReuseIdentifier: "ProfileImagesCell")
    }
    
    private func getPhotos(forKey: [String]) {
        // get user  pics
        self.userpics.removeAll(keepingCapacity: false)
        for f in forKey {
            if let pic = user?.object(forKey: f) as? String {
                self.userpics.append(pic)
            }
        }

        self.profileTableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let cell = self.profileTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ProfilePhotosButtonCell else {
            self.btnChatRequest.isEnabled = false
            return
        }
        self.adjustChatRequestBtnFrame(btnChat: cell.btnChat)
    }
    
    private func adjustChatRequestBtnFrame(btnChat: UIButton) {
        let frame = btnChat.convert(btnChat.bounds, to: self.viewProfileContainer)
        self.btnChatRequest.isEnabled = !self.isChatRequested
        self.btnChatRequest.frame = frame
    }
    
    private func setChatRequested() {
        self.isChatRequested = true
        self.btnChatRequest.isEnabled = false
    }
}

extension OtherProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OwnProfileImageCell", for: indexPath) as! OwnProfileImageCell
            cell.initCell(user: user, parentVC: self)
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePhotosButtonCell", for: indexPath) as! ProfilePhotosButtonCell
            
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImagesCell", for: indexPath) as! ProfileImagesCell
            cell.delegate = self
            cell.initCell(photos: self.userpics, isMyProfile: false)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return caculateHeightProfileCell(indexPath: indexPath)
    }
    
    func caculateHeightProfileCell(indexPath:IndexPath) -> CGFloat{
        let screenSize: CGRect = UIScreen.main.bounds
        if indexPath.row == 0 {
            return (UIScreen.main.bounds.size.width - 14) * 133 / 150 + 20
        } else if indexPath.row == 1 {
            return 66
        } else if indexPath.row == 2 {
            if userpics.count == 0 {
                let cellHeight = (screenSize.width - 3) * 1 / 3
                return cellHeight
            } else if userpics.count == 1 || userpics.count == 2 {
                let cellHeight = (screenSize.width - 3) * 2 / 3
                return cellHeight
            } else if userpics.count > 2 {
                return screenSize.width - 3
            }
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension OtherProfileViewController: OtherProfileViewControllerDelegate {
    
    func confirmChatRequest() {
        self.setChatRequested()
    }
}

extension OtherProfileViewController: ProfileImagesCellDelegate {

    func photoButtonTapped(_ index: Int) {
    }
    
    func photoImageTapped(_ index: Int, images: [UIImage]) {
        let imagesVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileImagesViewController") as! ProfileImagesViewController
        imagesVC.images = images
        imagesVC.curIndex = index
        imagesVC.modalPresentationStyle = .overFullScreen
        imagesVC.modalTransitionStyle = .crossDissolve
        self.present(imagesVC, animated: true, completion: nil)
    }
}
