//
//  MatchManager.swift
//  Finder
//
//  Created by Tai on 6/7/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import Foundation

class MatchManager {
    
    public static var shared = MatchManager()
    
    func saveMatchInBackground(match: NSMutableDictionary, callback: ((Bool) -> ())?) {
        let temp = match.object(forKey: "objectId") as! String
        var ref: DatabaseReference!
        
        match.setValue(Int64(Date().timeIntervalSince1970), forKey: "updatedAt")
          
        ref = Database.database().reference()
        ref.child("Matches").child(temp).setValue(match as NSDictionary) {
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
    
    func getMatchesByuserTouser(user1: NSDictionary, user2: NSDictionary, callback: ( ([NSDictionary]?) -> ())?) {
        
        // NSPredicate(format: "byUser = %@ AND toUser = %@ OR byUser = %@ AND toUser = %@", currentUser, sender, sender, currentUser)
        let user1Id = user1.object(forKey: "userId") as! String
        let user2Id = user2.object(forKey: "userId") as! String
        
        let ref = Database.database().reference()
        ref.child("Matches")
        
            .observeSingleEvent(of: .value, with: { (snapshot) in
            
            var results = [NSDictionary]()
            let teamDict = snapshot.value as? [String: Any]
             if let teamDict = teamDict {
                for team in teamDict {
                   
                    let teamValue = team.value as? NSDictionary ?? nil
                    
                    var byUserId = ""
                    var toUserId = ""
                    if let byUser = teamValue?.object(forKey: "byUser") as? NSDictionary {
                        byUserId = byUser.object(forKey: "userId") as! String
                    }
                    if let toUser = teamValue?.object(forKey: "toUser") as? NSDictionary {
                        toUserId = toUser.object(forKey: "userId") as! String
                    }
                    if let pending = teamValue?.object(forKey: "pending") as? Bool {
                        if !pending{
                            if byUserId.elementsEqual(user1Id), toUserId.elementsEqual(user2Id) {
                                results.append(teamValue!)
                            } else if toUserId.elementsEqual(user1Id), byUserId.elementsEqual(user2Id) {
                                results.append(teamValue!)
                            }
                        }
                    }
                }
                callback!(results)
             } else {
                callback!([])
            }
        })
    }
    
    func getMatchesRelatedMe(callback: ( ([NSDictionary]?) -> ())?) {
        
        // NSPredicate(format: "byUser = %@ OR toUser = %@", currentUser,currentUser)
        let userId = currentuser!.object(forKey: "userId") as! String
        
        let ref = Database.database().reference()
        ref.child("Matches")
        .observe(.value, with: { (snapshot) in
            var results = [NSDictionary]()
            let teamDict = snapshot.value as? [String: Any]
             if let teamDict = teamDict {
                for team in teamDict {
                   
                    let teamValue = team.value as? NSDictionary ?? nil
                    
                    
                    var byUserId = ""
                    var toUserId = ""
                    if let byUser = teamValue?.object(forKey: "byUser") as? NSDictionary {
                        byUserId = byUser.object(forKey: "userId") as! String
                    }
                    if let toUser = teamValue?.object(forKey: "toUser") as? NSDictionary {
                        toUserId = toUser.object(forKey: "userId") as! String
                    }
                    if let likedback = teamValue?.object(forKey: "likedback") as? Bool{
                        if likedback{
                            if byUserId.elementsEqual(userId) {
                                results.append(teamValue!)
                            } else if toUserId.elementsEqual(userId) {
                                results.append(teamValue!)
                            }
                        }
                    }else{
                        if byUserId.elementsEqual(userId) {
                            results.append(teamValue!)
                        } else if toUserId.elementsEqual(userId) {
                            results.append(teamValue!)
                        }
                    }
                }
                callback!(results)
             } else {
                callback!([])
            }
        })
    }
    
    func getPendingRequestsToMe(callback: (([NSDictionary]?) -> ())?) {
        guard currentuser != nil else {
            return
        }
        
//        let pred = NSPredicate(format: "toUser = %@ AND pending = true", currentUser)
       
        let ref = Database.database().reference()
        ref.child("Matches")
        .queryOrdered(byChild: "toUser/userId").queryEqual(toValue: currentuser?.object(forKey: "userId"))
            .observe(.value, with: { (snapshot) in
            
            var results = [NSDictionary]()
            let teamDict = snapshot.value as? [String: Any]
            if let teamDict = teamDict {
                for team in teamDict {
                   
                    let teamValue = team.value as? NSDictionary ?? nil
                    // NSPredicate(format: "toUser = %@ AND pending = true", currentUser)
                    if teamValue?.object(forKey: "pending") as? Bool ?? false {
                        results.append(teamValue!)
                    }
                }
                callback!(results)
            } else {
                callback!([])
            }
        })
    }
    
    func updateMatch(liked: Bool, for user: NSDictionary, callback: ((Bool)->())? = nil) {
        
        // update Matches database in server
//        let pred = NSPredicate(format: "byUser = %@ AND toUser = %@ OR byUser = %@ AND toUser = %@", currentuser!, user, user, currentuser!)
        
        let userId = user.object(forKey: "userId") as! String
        let currentUserId = currentuser?.object(forKey: "userId") as! String
        
        let ref = Database.database().reference().child("Matches")
        var handle: UInt = 0
        handle = ref.observe(.value, with: { (snapshot) in
            var results = [NSDictionary]()
            let teamDict = snapshot.value as? [String: Any]
            if let teamDict = teamDict {
                for team in teamDict {
                   
                    let teamValue = team.value as? NSDictionary ?? nil
                    // NSPredicate(format: "byUser = %@ AND toUser = %@ OR byUser = %@ AND toUser = %@", currentuser!, user, user, currentuser!)
                    var byUserId = ""
                    var toUserId = ""
                    if let byUser = teamValue?.object(forKey: "byUser") as? NSDictionary {
                        byUserId = byUser.object(forKey: "userId") as! String
                    }
                    if let toUser = teamValue?.object(forKey: "toUser") as? NSDictionary {
                        toUserId = toUser.object(forKey: "userId") as! String
                    }
                    if byUserId.elementsEqual(userId), toUserId.elementsEqual(currentUserId) {
                        results.append(teamValue!)
                    }
                    if toUserId.elementsEqual(userId), byUserId.elementsEqual(currentUserId) {
                        results.append(teamValue!)
                    }
                }
                
                if let updateObj = results.first {
                    if let byUser = updateObj.object(forKey: "byUser") as? NSDictionary {
                        let byUserId = byUser.object(forKey: "userId") as! String
                        if byUserId == userId{
                            updateObj.setValue(liked, forKey: "likedback")  //["likedback"] = liked
                            updateObj.setValue(false, forKey: "pending") // ["pending"] = false
                            self.saveMatchInBackground(match: updateObj as! NSMutableDictionary) { (result) in
                                if result {
                                    if liked {
                                        PushNotificationManager().sendChatRequest(user: user, type: .accepted)
                                    } else {
                                        PushNotificationManager().sendChatRequest(user: user, type: .declined)
                                    }
                                }
                                callback?(false)
                                ref.removeObserver(withHandle: handle)
                            }
                            
//                            var viewedUsers: [String] = currentuser?.object(forKey: u_viewedUsers) as? [String] ?? []
//                            viewedUsers.append(user.object(forKey: "userId") as! String)
//                            currentuser?.setValue(viewedUsers, forKey: u_viewedUsers)
                            
                            saveUserInBackground(user: currentuser!) { (result) in}
                        }else{
                            let pending = updateObj.object(forKey: "pending") as! Bool
                            if pending == false{
                                if let likedback = updateObj.object(forKey: "likedback") as? Bool{
                                    if likedback{
                                        callback?(true)
                                        ref.removeObserver(withHandle: handle)
                                    }
                                }
                                
                            }
                        }
                    }
                    
                } else {

                    if liked {
                        PushNotificationManager.shared.sendChatRequest(user: user, type: .sent)
                    }

                    let match = NSMutableDictionary()
                    let temp: String = String(Int64(Date().timeIntervalSince1970))
                    match.setValue(temp, forKey: "objectId")
                    match.setValue(currentuser, forKey: "byUser")  // ["byUser"] = currentuser
                    match.setValue(user, forKey: "toUser")  // ["toUser"] = user
                    match.setValue(liked, forKey: "liked")  // ["liked"] = liked
                    match.setValue(true, forKey: "pending")   // ["pending"] = true
                    
                    self.saveMatchInBackground(match: match) { (result) in}
                    saveUserInBackground(user: currentuser!) { (result) in}
                }
                callback!(false)
            } else {
                if liked {
                    PushNotificationManager.shared.sendChatRequest(user: user, type: .sent)
                }
                let match = NSMutableDictionary()
                let temp: String = String(Int64(Date().timeIntervalSince1970))
                match.setValue(temp, forKey: "objectId")
                match.setValue(currentuser, forKey: "byUser")  // ["byUser"] = currentuser
                match.setValue(user, forKey: "toUser")  // ["toUser"] = user
                match.setValue(liked, forKey: "liked")  // ["liked"] = liked
                match.setValue(true, forKey: "pending")   // ["pending"] = true
                
                self.saveMatchInBackground(match: match) { (result) in}
                saveUserInBackground(user: currentuser!) { (result) in}
            }
        })
    }
}
