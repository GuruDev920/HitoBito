//
//  UserManager.swift
//  Finder
//
//  Created by King Python on 7/1/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import Foundation

func saveReportInBackground(report: NSDictionary, callback: ((Bool) -> ())?) {

    let temp: String? = report.object(forKey: "objectId") as? String
    if temp == nil {
        callback!(false)
    }
    var ref: DatabaseReference!
      
    ref = Database.database().reference()
    ref.child("Reports").child(temp!).setValue(report) {
        (error:Error?, ref:DatabaseReference) in
        if let error = error {
          print("Data could not be saved: \(error).")
            callback!(false)
        } else {
            print("Data saved successfully.")
            callback!(true)
        }
    }
}

func saveUserInBackground(user: NSMutableDictionary, callback: ((Bool) -> ())?) {
    let temp: String? = user.object(forKey: "userId") as? String
    if temp == nil {
        callback!(false)
    }
    var ref: DatabaseReference!
    
    let currentUserId = Auth.auth().currentUser?.uid
    if (temp!.elementsEqual(currentUserId!)) {
        let token = UserDefaults.standard.string(forKey: u_token)
        user.setValue(token, forKey: u_token)
    }
    
    ref = Database.database().reference()
    ref.child("users").child(temp!).setValue(user as NSDictionary) {
        (error:Error?, ref:DatabaseReference) in
        if let error = error {
          print("Data could not be saved: \(error).")
            callback!(false)
        } else {
            print("Data saved successfully.")
            callback!(true)
        }
    }
}

func getUserInfo(userId: String, callback: ((NSMutableDictionary?) -> ())?) {
    
    let ref = Database.database().reference()
    ref.child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
    // Get user value
      let value = snapshot.value as? NSMutableDictionary
        callback!(value!)
    // ...
    }) { (error) in
      print(error.localizedDescription)
      
      callback!(nil)
    }
}

func getCurrentUser(callback: ((Bool) -> ())?) {
    
    if Auth.auth().currentUser?.uid == nil {
        callback!(false)
        return
    }
    
    var ref: DatabaseReference!
    
    ref = Database.database().reference()
    
    let userID = Auth.auth().currentUser?.uid
    
    ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
      // Get user value
        
        let value = snapshot.value as? NSMutableDictionary
//            currentuser!.userId = value?["userId"] as? String ?? ""
        if value == nil {
            callback!(false)
        } else {
            currentuser = NSMutableDictionary()
            
            currentuser = value
            currentuser?.setValue(Auth.auth().currentUser?.uid, forKey: "userId")
            
            callback!(true)
        }
        
      // ...
      }) { (error) in
        print(error.localizedDescription)
        
        callback!(false)
    }
}
