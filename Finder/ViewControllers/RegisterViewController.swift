//
//  RegisterViewController.swift
//  Finder
//
//  Created by djay mac on 27/01/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit
import DLRadioButton
import BEMCheckBox

class RegisterViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullnameTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var maleBtn: DLRadioButton!
    @IBOutlet weak var chbTerms: BEMCheckBox!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var lblAgree: UILabel!
    
    var alertError: String = ""
    var profileImageChanged = false
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let text = loginBtn.titleLabel?.text
        let nsText = text! as NSString
        let range = nsText.range(of: NSLocalizedString("Login", comment: ""))
        let attributedText = NSMutableAttributedString(string: loginBtn.titleLabel?.text ?? "")
        attributedText.addAttributes([.foregroundColor : UIColor("#efb4d5")], range: range)
        loginBtn.titleLabel?.attributedText = attributedText
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        lblTerms.text = NSLocalizedString("TermsAgree1", comment: "")
        lblAgree.text = NSLocalizedString("TermsAgree2", comment: "")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        if self.checkSignup() == true {
            if self.chbTerms.on{
                self.createUser()
            }else{
                let alertController = UIAlertController(title: L_ERROR, message: NSLocalizedString("Do you agree to the Terms of Use and Privacy Policy?", comment: ""), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: L_ERROR, message: alertError, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func termsBtnClicked(_ sender: Any) {
        
    }
    
    @IBAction func photoAction(_ sender: Any) {
        self.imagePicker.present(from: view)
    }
    
    func checkSignup()-> Bool {
        if (usernameTF.text?.isEmpty ?? true) || (emailTF.text?.isEmpty ?? true) || (passwordTF.text?.isEmpty ??  true) {
            
            alertError = NSLocalizedString("Oops! Text is empty", comment: "")
            return false
        } else if (usernameTF.text?.count ?? 0) < 4 {

            alertError = NSLocalizedString("Username should be more than 3", comment: "")
            return false
        } else if (passwordTF.text?.count ?? 0) < 3 {
    
            alertError = NSLocalizedString("Password should be more than 5", comment: "")
            return false
        } else if !maleBtn.isSelected, !maleBtn.otherButtons[0].isSelected {
            
            alertError = NSLocalizedString("Gender should be selected", comment: "")
            return false
        }
        return true
    }
    
    
    func createUser() {
        
        let userpf = NSMutableDictionary()
        
        userpf.setValue(usernameTF.text, forKey: u_fname)
        userpf.setValue(usernameTF.text, forKey: u_username)  //.username = usernameTF.text
        userpf.setValue(passwordTF.text, forKey: u_password) // password = passwordTF.text
        userpf.setValue(emailTF.text, forKey: u_email)  // email = emailTF.text

        userpf.setValue(fullnameTF.text, forKey: u_fname) // [u_fname] = fullnameTF.text
        
        let firstname = fullnameTF.text?.components(separatedBy: " ") //fullnameTF.text.componentsSeparatedByString(" ")
        userpf.setValue((firstname?[0] ?? "") as String, forKey: u_name)  // [u_name] = (firstname?[0] ?? "") as String
        userpf.setValue(aboutme, forKey: u_about)  // [u_about] = aboutme
        userpf.setValue(DEFAULT_AGE, forKey: u_age)  // [u_age] = DEFAULT_AGE
        userpf.setValue(maleBtn.isSelected ? 1 : 2, forKey: u_gender)  // [u_gender] = maleBtn.isSelected ? 1 : 2
        userpf.setValue(maleBtn.isSelected ? 2 : 1, forKey: u_interested)  // [u_interested] = maleBtn.isSelected ? 2 : 1
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if profileImageChanged, let image = self.profileImage.image {
            let imageL = scaleImage(image: image, and: CGSize(width: 320, height: 320))
            let imageSmall = scaleImage(image: image, and: CGSize(width: 60, height: 60))
            let dataL = imageL.jpegData(compressionQuality: 0.7)
            let dataS = imageSmall.jpegData(compressionQuality: 0.7)
//            userpf[u_dpLarge] = PFFileObject(name: "image.jpg", data: dataL!)
//            userpf[u_dpSmall] = PFFileObject(name: "image.jpg", data: dataS!)
//            userpf[u_pic1] = PFFileObject(name: "image.jpg", data: dataL!)
            uploadImage(imageData: dataL!) { (urlStr) in
                userpf.setValue(urlStr, forKey: u_dpLarge)
                userpf.setValue(urlStr, forKey: u_pic1)
                uploadImage(imageData: dataS!) { (urlStr) in
                    userpf.setValue(urlStr, forKey: u_dpSmall)
                    self.registerUser(userpf: userpf)
//                    self.registerUser1(userpf: body)
                }
            }
        } else {
//            self.registerUser(userpf: userpf)
            let alertController = UIAlertController(title: L_ERROR, message: NSLocalizedString("Please upload your photos.", comment: ""), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func registerUser(userpf:NSMutableDictionary) {
        
        Auth.auth().createUser(withEmail: self.emailTF.text!, password: self.passwordTF.text!) { authResult, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error as NSError? {
                var alertMsg:String = ""
                switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        alertMsg = NSLocalizedString("The operations is not allowed.", comment: "")
                      break
                    case .emailAlreadyInUse:
                        alertMsg = NSLocalizedString("Your email address is already in use.", comment: "")
                      print("emailAlreadyInUse")
                      break
                    case .invalidEmail:
                        alertMsg = NSLocalizedString("Your email address is malformed.", comment: "")
                      print("invalidEmail")
                      break
                    case .weakPassword:
                        alertMsg = NSLocalizedString("Your password is weak. Please try with strong password.", comment: "")
                      print("weakPassword")
                      break
                    default:
                        alertMsg = "Error: \(error.localizedDescription)"
                      print("Error: \(error.localizedDescription)")
                }
                MBProgressHUD.hide(for: self.view, animated: true)
                let alertController = UIAlertController(title: L_ERROR, message: alertMsg, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                userpf.setValue(Auth.auth().currentUser?.uid, forKey: "userId")
                self.createUserOnFirebase(user: userpf)
            }
        }
    }
    

    
    func createUserOnFirebase(user: NSMutableDictionary) {
        
        let temp = Auth.auth().currentUser!.uid as String?
        // Update UserClass
        if temp == nil {
            return
        }
        var ref: DatabaseReference!
        
        currentuser = user
        
        ref = Database.database().reference()
        ref.child("users").child(temp!).setValue(user as NSDictionary) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
                
                Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                    
                    getCurrentUser { (result) in
                      if result {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                        self.navigationController?.dismiss(animated: true, completion: nil)
                      }
                    }
                })
            }
        }
    }
}

extension RegisterViewController: ImagePickerDelegate{
    func didSelect(image: UIImage?) {
        if let image = image{
            profileImage.image = image
            profileImageChanged = true
        }
    }
}
