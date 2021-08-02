//
//  ChatManager.swift
//  Finder
//
//  Created by Tai on 6/18/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import Foundation
//import FirebaseDatabase

class ChatManager {
    
    public static var shared = ChatManager()
    
    private let ref = Database.database().reference()
    
    func chatIdWith(senderId: String, receiverId: String) -> String {
        let chatId = senderId < receiverId ? "\(senderId)\(receiverId)" : "\(receiverId)\(senderId)"
        return chatId
    }
    
    func getChat(senderId: String, receiverId: String, callback: ((Chat) -> ())?) {
        let chatId = chatIdWith(senderId: senderId, receiverId: receiverId)
        
        let chat = Chat(id: chatId, friendId: receiverId)
        
        ref.child("chats").child(chatId).queryLimited(toLast: UInt(MAX_NUMBER_OF_MESSAGES)).observeSingleEvent(of: .value, with: { (snapshot) in
            if let messagesData = snapshot.value as? [String : Any] {
                for messageData in (Array(messagesData.values) as! [[String : Any]]) {
                    chat.messages.append(ChatMessage(data: messageData))
                }
            }
            callback?(chat)
        }) { (error) in
            callback?(chat)
        }
    }
    
    func getLastMessage(senderId: String, receiverId: String, callback: ((ChatMessage?) -> ())?) {
        let chatId = chatIdWith(senderId: senderId, receiverId: receiverId)
        
        ref.child("chats").child(chatId).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            if let messagesData = snapshot.value as? [String : Any] {
                for messageData in (Array(messagesData.values) as! [[String : Any]]) {
                    callback?(ChatMessage(data: messageData))
                    break
                }
            } else {
                callback?(nil)
            }
        }) { (error) in
            callback?(nil)
        }
    }
}
