//
//  PushNotificationManager.swift
//  Finder
//
//  Created by Tai on 6/16/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import Foundation
import Alamofire
import Firebase

enum ChatRequestNotificationType {
    case sent
    case accepted
    case declined
}

struct PushNotificationType {
    static let chatRequestSent      = "ChatRequestSent"
    static let chatRequestAccepted  = "ChatRequestAccepted"
    static let chatRequestDeclined  = "ChatRequestDeclined"
    
    static let message              = "Message"
}

struct NotificationName {
    static let displayMessage   = "NotificationDisplayMessage"
    static let chatRequest      = "NotificationChatRequest"
}

class PushNotificationManager {
    
    public static var shared = PushNotificationManager()
    
    func sendChatRequest(user: NSDictionary, type: ChatRequestNotificationType) {
        
        let userToken = user.object(forKey: u_token) as? String
        if userToken == nil {
            return
        }
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "key=\(lc_serverKey)"]
        
        let fromUser = currentuser?.object(forKey: u_username) as? String ?? "A user"
        var pushMessageText = ""
        var pushType = ""
        switch type {
            case .sent:
                pushMessageText = "\(fromUser) \(NSLocalizedString("sent you chat request.", comment: ""))"
                pushType = PushNotificationType.chatRequestSent
            case .accepted:
                pushMessageText = "\(fromUser) \(NSLocalizedString("accepted your chat request.", comment: ""))"
                pushType = PushNotificationType.chatRequestAccepted
            case .declined:
                pushMessageText = "\(fromUser) \(NSLocalizedString("declined your chat request.", comment: ""))"
                pushType = PushNotificationType.chatRequestDeclined
        }
                
        let  body: [String: Any] = [
            "to": userToken!,
            "Type": pushType,
            "notification": [
                "body": pushMessageText,
                "Type": pushType,
                "badge":"increment",
                "sound":"notification.caf",
            ]
        ]
        
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : userToken!,
                                           "Type": pushType,
                                           "notification": [
                                            "title": "",
                                               "body": pushMessageText
                                           ],
                                           "badge":"increment",
                                           "sound":"notification.caf",
                                           "data" : ["user" : "testId"]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(lc_serverKey)", forHTTPHeaderField: "Authorization")
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func sendMessage(user: NSDictionary, message: String) {
        
        let userToken = user.object(forKey: u_token) as? String
        if userToken == nil {
            return
        }
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let _: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "key=\(lc_serverKey)"]
        
        let  body: [String: Any] = [
            "to": userToken!,
            "Type": PushNotificationType.message,
            "badge":"increment",
            "sound":"notification.caf",
            "notification": [
                "title": "",
                "body": message,
            ]
        ]
        
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : userToken!,
                                           "Type": PushNotificationType.message,
                                           "badge":"increment",
                                           "sound":"notification.caf",
                                           "notification" :
                                            [
                                                "title" : "",
                                                "body" : message
                                            ],
                                           "data" : ["user" : "testId"]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(lc_serverKey)", forHTTPHeaderField: "Authorization")
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
        
    }
    
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "testId"]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(lc_serverKey)", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
