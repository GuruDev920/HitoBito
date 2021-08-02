//
//  ChatMessage.swift
//  Finder
//
//  Created by Tai on 6/18/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import Foundation
//import FirebaseDatabase

class ChatMessage {
    
    var id          = ""
    var senderId    = ""
    var receiverId  = ""
    var message     = ""
    var imgURL      = ""
    var isRead      = true
    var createdAt   = dateToString(date: Date())

    private let ref = Database.database().reference()
    
    init(id: String, senderId: String, receiverId: String, message: String, imgURL: String = "") {
        self.id         = id
        self.senderId   = senderId
        self.receiverId = receiverId
        self.message    = message
        self.imgURL     = imgURL
        self.isRead     = false
    }
    
    init(data: [String : Any]) {
        update(data: data)
    }
    
    private func update(data: [String : Any]) {
        self.id         = (data[ct_id] as? String) ?? ""
        self.senderId   = (data[ct_senderId] as? String) ?? ""
        self.receiverId = (data[ct_receiverId] as? String) ?? ""
        self.message    = (data[ct_message]  as? String) ?? ""
        self.imgURL     = (data[ct_imgURL] as? String) ?? ""
        self.isRead     = (data[ct_isRead] as? Bool) ?? true
        self.createdAt  = (data[ct_createdAt] as? String) ?? dateToString(date: Date())
    }

    func asDictionary() -> [String : Any] {
        return [ct_id           : self.id,
                ct_senderId     : self.senderId,
                ct_receiverId   : self.receiverId,
                ct_message      : self.message,
                ct_imgURL       : self.imgURL,
                ct_isRead       : self.isRead,
                ct_createdAt    : self.createdAt]
    }
    
    func updateOnServer(chatId: String) {
        ref.child("chats/\(chatId)/\(id)").setValue(self.asDictionary())
    }
}
