//
//  RegisterViewController.swift
//  Finder
//
//  Created by djay mac on 27/01/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit
import DLRadioButton

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullnameTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var maleBtn: DLRadioButton!
    
    var alertError: String = ""
    var profileImageChanged = false
    
    let fbLoginManager : LoginManager = LoginManager()
    
    
    //MARK: - UI functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = loginBtn.titleLabel?.text
        let nsText = text! as NSString
        let range = nsText.range(of: NSLocalizedString("Login", comment: ""))
        let attributedText = NSMutableAttributedString(string: loginBtn.titleLabel?.text ?? "")
        attributedText.addAttributes([.foregroundColor : UIColor("#efb4d5")], range: range)
        loginBtn.titleLabel?.attributedText = attributedText
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - Handler functions
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        if self.checkSignup() == true {
            self.createUser()
        } else {
            let alertController = UIAlertController(title: L_ERROR, message: alertError, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func photoAction(_ sender: Any) {
        let mediapicker = UIImagePickerController()
        mediapicker.allowsEditing = true
        mediapicker.delegate = self
        mediapicker.sourceType = .photoLibrary
        self.present(mediapicker, animated: true, completion: nil)
    }
    
    @IBAction func loginFb(_ sender: Any) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let permissions = ["public_profile", "email"/*, , "user_about_me", "user_friends"*/]
        fbLoginManager.logIn(permissions: permissions, from: self) {
            result, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            let fbloginResult : LoginManagerLoginResult = result!
            
            if fbloginResult.isCancelled {
                print("cancelled.")
            } else if !fbloginResult.isCancelled {
                
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                self.signInToFirebaseWithCredentials(credentials: credential)
            }
        }
    }
    
    func signInToFirebaseWithCredentials(credentials: AuthCredential) {
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            
            if (error != nil) {
                print(error!.localizedDescription)
            } else {
                print("Login Success!!!!")
                
                let body: [String: Any] = [
                    "userId": authResult!.user.uid,
                    u_fname: authResult!.user.displayName ?? "",
                    u_username: authResult!.user.displayName ?? "",
                    u_email: authResult!.user.email ?? "",
                    u_dpLarge: authResult!.user.photoURL != nil ? authResult!.user.photoURL!.absoluteString : "",
                    u_dpSmall: authResult!.user.photoURL != nil ? authResult!.user.photoURL!.absoluteString : "",
                    u_pic1: authResult!.user.photoURL != nil ? authResult!.user.photoURL!.absoluteString : "",
                    "about": "",
                    "gender": 1,
                    u_name: authResult!.additionalUserInfo!.profile!["first_name"] as! String,
                    u_fbId: authResult!.additionalUserInfo!.profile!["id"] as! String,
                    u_token: UserDefaults.standard.string(forKey: "token") ?? ""
                ]
                
                Database.database().reference(withPath: "users").child(authResult!.user.uid).observeSingleEvent(of: .value, with: {
                    snapshat in
                    if snapshat.exists() {
                        //update
                        // Database.database().reference(withPath: "users").child(authResult!.user.uid).updateChildValues(body)
                    } else {
                        Database.database().reference(withPath: "users").child(authResult!.user.uid).setValue(body)
                    }
                    
                    self.navigationController?.dismiss(animated: true, completion: nil)
                })
                
            }
        }
    }
    
    func createFbUser() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        FBRequestConnection.start(withGraphPath: "/me?fields=picture,first_name,name,birthday,gender") { (connection, result, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let fbuser = result as? NSDictionary
            if error == nil{
                if let useremail = fbuser?.object(forKey: "email") as? String {
                    currentuser?.setValue(useremail, forKey: u_email)  //.email = useremail
                }
                
                if let username = fbuser?.object(forKey: "name") as? String {
                    currentuser?.setValue(username, forKey: u_fname)  // ["fname"] = username // full name
                }
                
                if let gender = fbuser?.object(forKey: "gender") as? String {
                    if gender == "male" {
                        currentuser?.setValue(1, forKey: u_gender)  // [u_gender] = 1
                        currentuser?.setValue(2, forKey: u_interested)  // [u_interested] = 2
                    } else if gender == "female" {
                        currentuser?.setValue(2, forKey: u_gender)  // [u_gender] = 2
                        currentuser?.setValue(1, forKey: u_interested)  // [u_interested] = 1
                    }
                }
                
                if let id = fbuser?.object(forKey: "id") as? String {
                    
                    let url = NSURL(string: "https://graph.facebook.com/\(id)/picture?width=640&height=640")!
                    let data = NSData(contentsOf: url as URL)
                    let image = UIImage(data: data! as Data)
                    let imageL = scaleImage(image: image!, and: CGSize(width: 320, height: 320)) // save 640x640 image
                    let imageS = scaleImage(image: image!, and: CGSize(width: 60, height: 60))
                    let dataL = imageL.jpegData(compressionQuality: 0.9)
                    let dataS = imageS.jpegData(compressionQuality: 0.9)
                    //                     currentuser?[u_dpLarge] = PFFileObject(name: "dpLarge.jpg", data: dataL!)
                    //                     currentuser?[u_dpSmall] = PFFileObject(name: "dpSmall.jpg", data: dataS!)
                    //                    currentuser?[u_pic1] = PFFileObject(name: "image.jpg", data: dataL!)
                    if let firstname = fbuser?.value(forKey: "first_name") as? String
                    {
                        currentuser?.setValue(firstname, forKey: u_name)  // ["name"] = firstname
                    }
                    
                    currentuser?.setValue(id, forKey: u_fbId)  // [u_fbId] = id
                    
                    currentuser?.setValue(aboutme, forKey: u_about)  // [u_about] = aboutme
                    currentuser?.setValue(DEFAULT_AGE, forKey: u_age)  // [u_age] = DEFAULT_AGE
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    
                    uploadImage(imageData: dataL!) { (urlStr) in
                        currentuser!.setValue(urlStr, forKey: u_dpLarge)
                        currentuser!.setValue(urlStr, forKey: u_pic1)
                        uploadImage(imageData: dataS!) { (urlStr) in
                            currentuser!.setValue(urlStr, forKey: u_dpSmall)
                            saveUserInBackground(user: currentuser!) { (result) in
                                MBProgressHUD.hide(for: self.view, animated: true)
                                if result {
                                    self.navigationController?.dismiss(animated: true, completion: nil)
                                } else {
                                    let alertController = UIAlertController(title: "Sorry!", message: "You are failed to create user on Database.", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
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
            self.registerUser(userpf: userpf)
        }
    }
    
    func registerUser(userpf:NSMutableDictionary) {
        Auth.auth().createUser(withEmail: self.emailTF.text!, password: self.passwordTF.text!) { authResult, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error as NSError? {
                var alertMsg:String = ""
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    alertMsg = "operationNotAllowed"
                    print("operationNotAllowed")
                    break
                case .emailAlreadyInUse:
                    alertMsg = "emailAlreadyInUse"
                    print("emailAlreadyInUse")
                    break
                case .invalidEmail:
                    alertMsg = "invalidEmail"
                    print("invalidEmail")
                    break
                case .weakPassword:
                    alertMsg = "weakPassword"
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
                    AlertBuilder("Success", "Successfully created.\n Please verify your account by checking your email, \nIf you can’t find the email in your inbox please check your junk or spam email inbox", AlertAction({
                        self.navigationController?.popViewController(animated: true)
                    }, "OK")).show(self)
                })
            
            }
        }
    }
    
   
}

//MARK: -UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImg = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        profileImage.image = pickedImg
        profileImageChanged = true
        
        self.dismiss(animated: true, completion: nil)
    }
}
