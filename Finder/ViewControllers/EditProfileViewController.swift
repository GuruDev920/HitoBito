//
//  EditProfileViewController.swift
//  Finder
//
//  Created by SuperDev on 27.05.2020.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit
import DLRadioButton
import DropDown
import DKImagePickerController
import CropViewController


class EditProfileViewController: UIViewController {

    @IBOutlet weak var scrlvFields      : UIScrollView!
    @IBOutlet weak var contentvFields   : UIView!
    
    @IBOutlet var imgvPhotos        : [UIImageView]!
    @IBOutlet var btnPhotos         : [UIButton]!
    @IBOutlet weak var maleButton   : DLRadioButton!
    @IBOutlet weak var nameTF       : UITextField!
    @IBOutlet weak var aboutText    : UITextView!
    @IBOutlet weak var ageTF        : UITextField!
    @IBOutlet weak var locationBtn  : UIButton!
    
    @IBOutlet weak var btnHeight            : UIButton!
    @IBOutlet weak var btnCurRelation       : UIButton!
    @IBOutlet weak var btnHasKids           : DLRadioButton!
    @IBOutlet weak var btnDesiredRelation   : UIButton!
    @IBOutlet weak var txtfJob              : UITextField!
    @IBOutlet weak var btnReligion          : UIButton!
    
    var location: Location!
    
    private var dropDownHeight          : DropDown!
    private var dropDownCurRelation     : DropDown!
    private var dropDownDesiredRelation : DropDown!
    private var dropDownReligion        : DropDown!
    
    private var userData: UserData!
    
    private var curPhotoIndex: Int = 0
    
    private var gradientLayerForScroll      : CAGradientLayer!
    private var timerForShowScrollIndicator : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.userData = UserData(user: currentuser)
        self.createDropDownLists()
        
        self.initUI()
        self.createGradientLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.scrlvFields.setContentOffset(CGPoint(x: 0, y: 1), animated: true)
        self.timerForShowScrollIndicator = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.showScrollIndicatorsInContacts), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.timerForShowScrollIndicator?.invalidate()
        self.timerForShowScrollIndicator = nil
    }
    
    @objc func showScrollIndicatorsInContacts() {
        UIView.animate(withDuration: 1.0) {
            self.scrlvFields.flashScrollIndicators()
        }
    }
    
    private func initUI() {
        
        aboutText.layer.borderColor = UIColor(hex6: 0xc5c5c5).cgColor
        aboutText.layer.borderWidth = 0.5
        nameTF.text = self.userData.fname
        aboutText.text = self.userData.about
        ageTF.text = "\(self.userData.age)"
        if self.userData.gender == 1 {
            maleButton.isSelected = true
        } else {
            for genderBtn in maleButton.otherButtons {
                if genderBtn.tag == self.userData.gender {
                    genderBtn.isSelected = true
                    break
                }
            }
        }
        if let locationStr = self.userData.locationText, !locationStr.isEmpty {
            locationBtn.setTitle(locationStr, for: .normal)
        }
        
        self.setHeight(height: self.userData.height)
        dropDownHeight.selectRow(self.userData.height - MIN_HEIGHT, scrollPosition: .bottom)
        
        self.setCurRelation(curRelation: self.userData.curRelation)
        dropDownCurRelation.selectRow(self.userData.curRelation, scrollPosition: .bottom)
        
        btnHasKids.isSelected = self.userData.hasKids
        btnHasKids.otherButtons[0].isSelected = !self.userData.hasKids
        
        self.setDesiredRelation(desiredRelation: self.userData.desiredRelation)
        dropDownDesiredRelation.selectRow(self.userData.desiredRelation, scrollPosition: .bottom)
        
        self.txtfJob.text = self.userData.job
        
        self.setReligion(religion: self.userData.religion)
        dropDownReligion.selectRow(self.userData.religion, scrollPosition: .bottom)
        
        for i in 0 ..< user_picKeys.count {
            let picKey = user_picKeys[i]
            if let pic = self.userData.pics[picKey] {
                self.btnPhotos[i].isHidden = true
                self.imgvPhotos[i].sd_setImage(with: URL(string: pic), completed: nil)
            } else {
                self.btnPhotos[i].isHidden = false
            }
        }

        for imgvPhoto in self.imgvPhotos {
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.tapOnPhoto))
            imgvPhoto.addGestureRecognizer(gesture)
        }
    }
    
    private func createGradientLayer() {
        gradientLayerForScroll = CAGradientLayer()
        gradientLayerForScroll.colors = [UIColor(hexString: "d0f3fe").cgColor, UIColor(hexString: "efb4d5").cgColor]
    }

    @objc func tapOnPhoto(sender : UITapGestureRecognizer) {
        self.clickPhoto(index: sender.view?.tag ?? 0)
    }
    
    private func setHeight(height: Int) {
        self.userData.height = height
        btnHeight.setTitle("\(self.userData.height) cm", for: .normal)
    }
    
    private func setCurRelation(curRelation: Int) {
        self.userData.curRelation = curRelation
        btnCurRelation.setTitle(CUR_RELATIONSHIPS[self.userData.curRelation], for: .normal)
    }
    
    private func setDesiredRelation(desiredRelation: Int) {
        self.userData.desiredRelation = desiredRelation
        btnDesiredRelation.setTitle(DESIRED_RELATIONSHIPS[self.userData.desiredRelation], for: .normal)
    }

    private func setReligion(religion: Int) {
        self.userData.religion = religion
        btnReligion.setTitle(RELIGIONS[self.userData.religion], for: .normal)
    }

    private func createDropDownLists() {
        dropDownHeight = DropDown()
        dropDownHeight.anchorView = self.btnHeight
        dropDownHeight.dataSource = HEIGHTS
        dropDownHeight.selectionAction = { [unowned self] (index: Int, item: String) in
            self.setHeight(height: index + MIN_HEIGHT)
        }
        dropDownHeight.backgroundColor = .white

        dropDownCurRelation = DropDown()
        dropDownCurRelation.anchorView = self.btnCurRelation
        dropDownCurRelation.dataSource = CUR_RELATIONSHIPS
        dropDownCurRelation.selectionAction = { (index: Int, item: String) in
            self.setCurRelation(curRelation: index)
        }
        dropDownCurRelation.backgroundColor = .white

        dropDownDesiredRelation = DropDown()
        dropDownDesiredRelation.anchorView = self.btnDesiredRelation
        dropDownDesiredRelation.dataSource = DESIRED_RELATIONSHIPS
        dropDownDesiredRelation.selectionAction = { (index: Int, item: String) in
            self.setDesiredRelation(desiredRelation: index)
        }
        dropDownDesiredRelation.backgroundColor = .white

        dropDownReligion = DropDown()
        dropDownReligion.anchorView = self.btnReligion
        dropDownReligion.dataSource = RELIGIONS
        dropDownReligion.selectionAction = { (index: Int, item: String) in
            self.setReligion(religion: index)
        }
        dropDownReligion.backgroundColor = .white
    }
    
    @IBAction func onBtnHeight(_ sender: Any) {
        dropDownHeight.show()
    }
    
    @IBAction func onBtnCurRelation(_ sender: Any) {
        dropDownCurRelation.show()
    }
    
    @IBAction func onBtnDesiredRelation(_ sender: Any) {
        dropDownDesiredRelation.show()
    }
    
    @IBAction func onBtnReligion(_ sender: Any) {
        dropDownReligion.show()
    }
    
    @IBAction func locationTapped(_ sender: Any) {
        let alert = UIAlertController(style: .actionSheet, source: nil, title: NSLocalizedString("Pick Location", comment: ""), message: nil, tintColor: nil)
        
        alert.addLocationPicker { (location) in
            if let loc = location {
                self.location = loc
                self.locationBtn.setTitle(loc.address, for: .normal)
            }
        }
        
        alert.addAction(image: nil, title: L_CANCEL, color: nil, style: .cancel, isEnabled: true) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.show()
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBtnPicture(_ sender: UIButton) {
        self.clickPhoto(index: sender.tag)
    }
    
    private func clickPhoto(index: Int) {
        self.curPhotoIndex = index
        
        let picker = DKImagePickerController()
        picker.singleSelect = true
        picker.sourceType = .both
        picker.assetType = .allPhotos
        
        picker.didSelectAssets = {[unowned self] (assets: [DKAsset]) in
            
            for asset in assets {
                asset.fetchOriginalImage { (image: UIImage?, _: [AnyHashable: Any]?) in
                    let cropper = CropViewController(croppingStyle: .default, image: image!)
                    cropper.delegate = self
                    self.present(cropper, animated: true, completion: nil)
                }
            }
        }
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let name = nameTF.text, !name.isEmpty else {
            showAlert(title: NSLocalizedString("Invalid Name", comment: ""), message: NSLocalizedString("Please enter your name.", comment: ""), vc: self)
            return
        }
        
        guard let age = ageTF.text, !age.isEmpty else {
            showAlert(title: NSLocalizedString("Invalid Age", comment: ""), message: NSLocalizedString("Please enter your age.", comment: ""), vc: self)
            return
        }
        
        currentuser?.setValue(name, forKey: u_fname)
        
        let firstname = name.components(separatedBy: " ")
        currentuser?.setValue(firstname[0], forKey: u_name) // [u_name] = firstname[0]
        currentuser?.setValue(aboutText.text, forKey: u_about) //[u_about] = aboutText.text
        if maleButton.isSelected {
            currentuser?.setValue(1, forKey: u_gender) // [u_gender] = 1
        } else {
            for btnGender in maleButton.otherButtons {
                if btnGender.isSelected {
                    currentuser?.setValue(btnGender.tag, forKey: u_gender) // [u_gender] = btnGender.tag
                    break
                }
            }
        }
        currentuser?.setValue(Int(age), forKey: u_age) // [u_age] = Int(age)
        if let location = self.location {
            var positions = [Double]()
            positions.append(location.coordinate.latitude)
            positions.append(location.coordinate.longitude)
            currentuser?.setValue(positions, forKey: u_location)
            //[u_location] = PFGeoPoint(location: location.location)
            currentuser?.setValue(location.address, forKey: u_locationText)
            // [u_locationText] = location.address
        }
        currentuser?.setValue(self.userData.height, forKey: u_height)
        // [u_height]          = self.userData.height
        currentuser?.setValue(self.userData.curRelation, forKey: u_curRelation)
        // [u_curRelation]     = self.userData.curRelation
        currentuser?.setValue(self.btnHasKids.isSelected, forKey: u_hasKids)
        // [u_hasKids]         = self.btnHasKids.isSelected
        currentuser?.setValue(self.userData.desiredRelation, forKey: u_desiredRelation)
        // [u_desiredRelation] = self.userData.desiredRelation
        currentuser?.setValue(self.txtfJob.text ?? "", forKey: u_job)
        // [u_job]             = self.txtfJob.text ?? ""
        currentuser?.setValue(self.userData.religion, forKey: u_religion)
        // [u_religion]        = self.userData.religion
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
//        self.uploadMultiImage(forIndex: 0)
        var indexNum:Int = 0
        var maxNum:Int = 0
        for picKey in user_picKeys {
            if let isChanged = self.userData.picsChanged[picKey], isChanged == true {
                if let image = self.userData.picImages[picKey] {
                    let scaledImage = scaleImage(image: image, and: CGSize(width: 320, height: 320)).jpegData(compressionQuality: 0.7)
//                    currentuser?[picKey] = PFFileObject(name: "image.jpg", data: scaledImage!)
                    maxNum = maxNum + 1
                    uploadImage(imageData: scaledImage!) { (urlStr) in
                        currentuser?.setValue(urlStr, forKey: picKey)
                        indexNum = indexNum + 1
                        if indexNum == maxNum {
                            saveUserInBackground(user: currentuser!) { (result) in
                                if result {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }

                    if picKey == u_pic1 {
                        let scaledSmallImage = scaleImage(image: image, and: CGSize(width: 60, height: 60)).jpegData(compressionQuality: 0.7)
                        uploadImage(imageData: scaledSmallImage!) { (urlStr) in
                            currentuser?.setValue(urlStr, forKey: u_dpLarge)
                            currentuser?.setValue(urlStr, forKey: u_dpSmall)
                        }
                    }
                }
            }
        }
        
        if 0 == maxNum {
            saveUserInBackground(user: currentuser!) { (result) in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
}

extension EditProfileViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let textlength = (textView.text as NSString).length + (text as NSString).length - range.length
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return (textlength > 150) ? false : true
    }
}

extension EditProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let verticalIndicator = scrollView.subviews.last {
            verticalIndicator.clipsToBounds = true
            gradientLayerForScroll.frame = verticalIndicator.bounds
            var height = scrollView.bounds.size.height / contentvFields.frame.size.height * scrollView.bounds.size.height
            if height < 40 {
                height = 40
            }
            gradientLayerForScroll.frame.size.height = height
            verticalIndicator.layer.addSublayer(gradientLayerForScroll)
        }
    }
}

extension EditProfileViewController: CropViewControllerDelegate {
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.userData.picsChanged[user_picKeys[self.curPhotoIndex]] = true
        self.userData.picImages[user_picKeys[self.curPhotoIndex]] = image
        self.imgvPhotos[self.curPhotoIndex].image = image
        self.btnPhotos[self.curPhotoIndex].isHidden = true
    }
}
