//
//  LoginViewController.swift
//  Finder
//
//  Created by djay mac on 27/01/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    let fbLoginManager : LoginManager = LoginManager()
    
    
    //MARK: - UI functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = signUpBtn.titleLabel?.text
        let nsText = text! as NSString
        let range = nsText.range(of: NSLocalizedString("Register Now!", comment: ""))
        let attributedText = NSMutableAttributedString(string: signUpBtn.titleLabel?.text ?? "")
        attributedText.addAttributes([.foregroundColor : UIColor("#efb4d5")], range: range)
        signUpBtn.titleLabel?.attributedText = attributedText
        
        let loginType = USERDEFAULTS.integer(forKey: "loginType")
        if loginType == 1 {
            let email = USERDEFAULTS.string(forKey: "email")
            let password = USERDEFAULTS.string(forKey: "password")
            
            loginWithEmail(email!, password!)
        } else if loginType == 2 {
            let token = USERDEFAULTS.string(forKey: "fbToken")
            loginWithFbToken(token!)
        }
    }
        
    //MARK: - Handler functions
    @IBAction func forPwdAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Reset Password", message: "Please enter the email your account was setup with", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = ""
        }

        let saveAction = UIAlertAction(title: "Request", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            

            Auth.auth().sendPasswordReset(withEmail: firstTextField.text!) { error in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    let alertController = UIAlertController(title: "Sorry!", message: error!.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Password reset email sent", message: "An email was sent to your email address, Please check your email to reset your password.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }

        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil )

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        guard let username = usernameTF.text, let password = passwordTF.text else {
            return
        }
        
        if username.isEmpty || password.isEmpty {
            let alertController = UIAlertController(title: L_ERROR, message: NSLocalizedString("username/email is required.", comment: ""), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        loginWithEmail(username, password)
    }
    
    @IBAction func loginFb(_ sender: Any) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let permissions = ["public_profile", "email"/*, "user_about_me", "user_friends"*/]
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
                
                USERDEFAULTS.set(2, forKey: "loginType")
                USERDEFAULTS.set(AccessToken.current!.tokenString, forKey: "fbToken")
                
                self.loginWithFbToken(AccessToken.current!.tokenString)
            }
        }
    }
    //MARK: - API functions
    func loginWithEmail(_ email: String, _ password: String) {
        if email.isEmpty || password.isEmpty {
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error as NSError? {
                
                var alertTitle:String = L_ERROR
                var alertMsg:String = ""

                switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        alertMsg = "operationNotAllowed"
                        print("operationNotAllowed")
                        break
                    // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
                    case .userDisabled:
                        alertMsg = "userDisabled"
                        print("userDisabled")
                        break
                    // Error: The user account has been disabled by an administrator.
                    case .wrongPassword:
                        alertTitle = "Sign in error"
                        alertMsg = "Your Email or password is incorrect. Please try again."
                        print("wrongPassword")
                        break
                    // Error: The password is invalid or the user does not have a password.
                    case .invalidEmail:
                        alertMsg = "invalidEmail"
                        print("invalidEmail")
                        break
                    // Error: Indicates the email address is malformed.
                    default:
                        alertMsg = "Error: \(error.localizedDescription)"
                        print("Error: \(error.localizedDescription)")
                }
                
                let alertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)

            } else {
                print("User signs in successfully")
                let user = result!.user
                print("User has Signed In")
                if user.isEmailVerified {
                    
                    // save user login credentials
                    USERDEFAULTS.set(1, forKey: "loginType")
                    USERDEFAULTS.set(email, forKey: "email")
                    USERDEFAULTS.set(password, forKey: "password")
                    
                    getCurrentUser { (result) in
                      if result {
                          self.navigationController?.dismiss(animated: true, completion: nil)
                      }
                    }
                } else {
                  // do whatever you want to do when user isn't verified
                    let alertController = UIAlertController(title: L_ERROR, message: "You didn't verify your email yet. Please check your email.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func sendNotiifcationTest() {
        let token = UserDefaults.standard.string(forKey: "token")
        if token != nil {
            PushNotificationManager.shared.sendPushNotification(to: token!, title: "Hi", body: "Welcome to HitoBito!!!")
        }
    }
    
    func loginWithFbToken(_ token: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        self.signInToFirebaseWithCredentials(credentials: credential)
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
    
    func createFBUserOnDB(fbuser: User) {
        
    }
    
    func createFbUser() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        if((AccessToken.current) != nil) {
            
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, birthday, gender"]).start(completionHandler: {
                connection, result, error in
                print(result)
            })
        }
    }
}


//MARK: -UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
