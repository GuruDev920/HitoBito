//
//  Chat.swift
//  Finder
//
//  Created by Tai on 6/18/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import Foundation
//import FirebaseDatabase

class Chat {
    
    private let ref = Database.database().reference()
    
    var id          : String = ""
    
    var friendId    : String = ""
    var messages    : [ChatMessage] = []

    init(id: String, friendId: String) {
        self.id = id
        self.friendId = friendId
    }

    func sendMessage(message: ChatMessage, callback: (() -> ())?) {
        message.createdAt = localToUTC(dateStr: dateToString(date: Date()))
        messages.append(message)
        ref.child("chats/\(id)/\(message.id)").setValue(message.asDictionary()) { (error, reference) in
            callback?()
        }
    }
}
