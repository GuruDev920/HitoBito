//
//  LoginViewController.swift
//  Finder
//
//  Created by djay mac on 27/01/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//  UPdated by James W on 10/06/21
//

import UIKit
import AuthenticationServices
import SwiftKeychainWrapper
import CryptoKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    //@IBOutlet weak var vwAppleButton: UIView!
    
    let fbLoginManager : LoginManager = LoginManager()
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = signUpBtn.titleLabel?.text
        let nsText = text! as NSString
        let range = nsText.range(of: NSLocalizedString("Register Now!", comment: ""))
        let attributedText = NSMutableAttributedString(string: signUpBtn.titleLabel?.text ?? "")
        attributedText.addAttributes([.foregroundColor : UIColor("#efb4d5")], range: range)
        signUpBtn.titleLabel?.attributedText = attributedText
        
        /*let appleButton = ASAuthorizationAppleIDButton()
        appleButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        appleButton.cornerRadius = 14
        let buttonSize = self.vwAppleButton.bounds.size
        appleButton.frame = CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height)
        self.vwAppleButton.addSubview(appleButton)*/
        
        let loginType = USERDEFAULTS.integer(forKey: "loginType")
        if loginType == 1 {
            let email = USERDEFAULTS.string(forKey: "email")
            let password = USERDEFAULTS.string(forKey: "password")
            
            loginWithEmail(email!, password!)
        } else if loginType == 2 {
            let token = USERDEFAULTS.string(forKey: "fbToken")
            loginWithFbToken(token!)
        } else if loginType == 3 {
            autoLoginWithAppleUserId()
        }
    }

    @IBAction func forPwdAction(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("Reset Password", comment: ""), message: NSLocalizedString("Please enter the email your account was setup with", comment: ""), preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = ""
        }

        let saveAction = UIAlertAction(title: NSLocalizedString("Request", comment: ""), style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            

            Auth.auth().sendPasswordReset(withEmail: firstTextField.text!) { error in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    let alertController = UIAlertController(title: L_ERROR, message: error!.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: L_OK, style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("Password reset email sent", comment: ""), message: NSLocalizedString("An email was sent to your email address, Please check your email to reset your password.", comment: ""), preferredStyle: .alert)
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
                        alertMsg = NSLocalizedString("The operations is not allowed.", comment: "")
                        break
                    // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
                    case .userDisabled:
                        alertMsg = NSLocalizedString("You have been disabled by Administrator.", comment: "")
                        break
                    // Error: The user account has been disabled by an administrator.
                    case .wrongPassword:
                        alertTitle = NSLocalizedString("Sign in error", comment: "")
                        alertMsg = NSLocalizedString("Your password is incorrect. Please try with correct password.", comment: "")
                        break
                    // Error: The password is invalid or the user does not have a password.
                    case .invalidEmail:
                        alertMsg = NSLocalizedString("Your email address is malformed.", comment: "")
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
                let user = result!.user
                if user.isEmailVerified {
                    
                    // save user login credentials
                    USERDEFAULTS.set(1, forKey: "loginType")
                    USERDEFAULTS.set(email, forKey: "email")
                    USERDEFAULTS.set(password, forKey: "password")
                    
                    getCurrentUser { (result) in
                      if result {
                        if let verified = currentuser?.object(forKey: u_emailVerified) as? Bool {
                            if !verified {
                                currentuser?.setValue(true, forKey: u_emailVerified)
                                saveUserInBackground(user: currentuser!) { (result) in }
                            }
                        }
                        self.navigationController?.dismiss(animated: true, completion: nil)
                      }
                    }
                } else {
                  // do whatever you want to do when user isn't verified
                    let alertController = UIAlertController(title: L_ERROR, message: NSLocalizedString("You didn't verify your email yet. Please check your email.", comment: ""), preferredStyle: .alert)
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
    
    func loginWithFbToken(_ token: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        self.signInToFirebaseWithCredentials(credentials: credential)
    }
    
    func signInToFirebaseWithCredentials(credentials: AuthCredential) {
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            
            if (error != nil) {
                print(error!.localizedDescription)
            } else {
                var photo = authResult!.user.photoURL != nil ? authResult!.user.photoURL!.absoluteString : ""
                let pictureData = authResult!.additionalUserInfo!.profile!["picture"]?.value(forKey: "data") as! NSDictionary
                if pictureData.value(forKey: "url") != nil {
                    photo = pictureData.value(forKey: "url") as! String
                }
                
                let body: [String: Any] = [
                    "userId": authResult!.user.uid,
                    u_fname: authResult!.user.displayName ?? "",
                    u_username: authResult!.user.displayName ?? "",
                    u_email: authResult!.user.email ?? "",
                    u_dpLarge: photo,
                    u_dpSmall: photo,
                    u_pic1: photo,
                    "about": "",
                    "gender": 1,
                    "emailVerified": true,
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
                    
                    getCurrentUser { (result) in
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
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
    
    /*@objc func handleAppleIdRequest() {
        startSignInWithAppleFlow()
    }*/
    
    
    @IBAction func startSignInWithAppleFlow(_ sender: Any){
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    func loginWithAppleIDToken(_ token: String) {
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: token, rawNonce: nonce)
        signInToFirebaseWithAppleCredentials(credentials: credential)
    }
    
    func autoLoginWithAppleUserId() {
        let userId:String? = KeychainWrapper.standard.string(forKey: "userId")
        if userId != nil {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userId!) { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    getCurrentUser { (result) in
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                    break
                case .revoked, .notFound:
                    break
                default:
                    break
                }
            }
        }
    }
    
    func signInToFirebaseWithAppleCredentials(credentials: AuthCredential) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        Auth.auth().signIn(with: credentials) { (authResult, error) in
            
            if (error != nil) {
                print(error!.localizedDescription)
            } else {
                let body: [String: Any] = [
                    "userId": authResult!.user.uid,
                    u_fname: authResult!.user.displayName ?? "",
                    u_username: authResult!.user.displayName ?? "",
                    u_email: authResult!.user.email ?? "",
                    "about": "",
                    "gender": 1,
                    "emailVerified": true,
                    u_token: UserDefaults.standard.string(forKey: "token") ?? ""
                ]

                Database.database().reference(withPath: "users").child(authResult!.user.uid).observeSingleEvent(of: .value, with: {
                    snapshat in
                    if snapshat.exists() {
                    } else {
                        Database.database().reference(withPath: "users").child(authResult!.user.uid).setValue(body)
                    }

                    getCurrentUser { (result) in
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                })
            }
            
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map{ _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let userIdentifier = appleIDCredential.user

            USERDEFAULTS.set(3, forKey: "loginType")
            KeychainWrapper.standard.set(userIdentifier, forKey: "userId")
            
            loginWithAppleIDToken(idTokenString)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
