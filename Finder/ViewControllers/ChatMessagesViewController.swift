//
//  ChatMessagesViewController.swift
//  2OneApp
//
//  Created by djay mac on 06/01/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit
import MediaPlayer
import SDWebImage
import JSQSystemSoundPlayer
import DKImagePickerController
import CropViewController

class ChatMessagesViewController: JSQMessagesViewController, UIActionSheetDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    var room:NSDictionary!
    var incomingUser:NSDictionary!
    var chat: Chat!

    private var userIds = [String]()
    private var messages = [JSQMessage]()
    private var messageObjects = [String]()
    
    private var outgoingBubbleImage:JSQMessagesBubbleImage!
    private var incomingBubbleImage:JSQMessagesBubbleImage!
    
    private var selfAvatar:JSQMessagesAvatarImage!
    private var incomingAvatar:JSQMessagesAvatarImage!
    
    private var selfUsername:NSString!
    
    private var observerHandleChat  : UInt! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationBar = self.navigationBar {
            var topPadding: CGFloat = 20
            if #available(iOS 11.0, *) {
                if let window = UIApplication.shared.keyWindow {
                    topPadding = window.safeAreaInsets.top
                }
            }
            self.view.addSubview(navigationBar)
            navigationBar.translatesAutoresizingMaskIntoConstraints = false
            let leadingConstraint = NSLayoutConstraint(item: navigationBar, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0)
            let trailingConstraint = NSLayoutConstraint(item: navigationBar, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            let topConstraint = NSLayoutConstraint(item: navigationBar, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
            let heightConstraint = NSLayoutConstraint(item: navigationBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: topPadding + 65)
            self.view.addConstraints([leadingConstraint, trailingConstraint, topConstraint])
            navigationBar.addConstraint(heightConstraint)
            
            self.topContentAdditionalInset = 65
            
        }
        
//        try! incomingUser.fetchIfNeeded()
        
        selfUsername = currentuser?.object(forKey: u_name) as? NSString
        let incomingUsername = incomingUser.object(forKey: u_name) as!NSString
        
        self.senderId = (currentuser?.object(forKey: "userId") as! String)
        self.senderDisplayName = (currentuser?.object(forKey: u_name) as! String)
        
        self.titleLabel.text = incomingUsername as String
        
        if let userimage = currentuser?.object(forKey: "dpSmall") as? String {
            getImage(forUrl: userimage) { (imageData) in
                self.selfAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: imageData, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                self.collectionView.reloadData()
            }
            
        } else {
            selfAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: selfUsername.substring(with: NSMakeRange(0, 2)), backgroundColor: UIColor.black, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
        
        
        if let inuserimage = incomingUser.object(forKey: "dpSmall") as? String {
            
            getImage(forUrl: inuserimage) { (imageData) in
                self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: imageData, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                self.collectionView.reloadData()
            }
            
        } else {
            incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: incomingUsername.substring(with: NSMakeRange(0, 2)), backgroundColor: UIColor.black, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        }
     
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImage = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(hex6: 0x94c2e4))
        incomingBubbleImage = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(hex6: 0xf5f5f5))
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setObserverChat()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeObserverChat()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
                self.navigationController?.popViewController(animated: true)
            case .down:
                print("Swiped down")
            case .left:
                print("Swiped left")
            case .up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    private func setObserverChat() {
        self.messages.removeAll()
        self.collectionView.reloadData()
        
        if observerHandleChat == nil {
            let ref = Database.database().reference()
            observerHandleChat = ref.child("chats/\(self.chat.id)").queryLimited(toLast: UInt(MAX_NUMBER_OF_MESSAGES)).observe(.childAdded, with: { snapshot in
                if let msgData = snapshot.value as? [String : Any] {
                    self.showTypingIndicator = !self.showTypingIndicator
                    self.scrollToBottom(animated: true)
                    
                    let msg = ChatMessage(data: msgData)
                    if msg.receiverId == (currentuser!.object(forKey: "userId") as! String) {
                        msg.isRead = true
                        msg.updateOnServer(chatId: self.chat.id)
                    }
                    
                    self.addMessage(message: msg)
                    
                    self.finishReceivingMessage(animated: true)
                }
            })
        }
    }
    
    private func removeObserverChat() {
        if let observerHandleChat = observerHandleChat {
            let ref = Database.database().reference()
            ref.child("chats/\(self.chat.id)").removeObserver(withHandle: observerHandleChat)
            self.observerHandleChat = nil
        }
    }

    override func didPressAccessoryButton(_ sender: UIButton!) {
        let picker = DKImagePickerController()
        picker.singleSelect = true
        picker.sourceType = .both
        picker.assetType = .allPhotos
        
        picker.didSelectAssets = {[unowned self] (assets: [DKAsset]) in
          self.selectAsset(assets: assets)
        }
        
        self.present(picker, animated: true, completion: nil)
    }
    
    func selectAsset(assets: [DKAsset]) {
        if assets.count > 0 {
            let asset = assets[0]
            
            asset.fetchOriginalImage { (image: UIImage?, _: [AnyHashable: Any]?) in
                let cropper = CropViewController(croppingStyle: .default, image: image!)
                cropper.delegate = self
                self.present(cropper, animated: true, completion: nil)
            }
      }
    }
    
    // CropViewControllerDelegate
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.sendMessage(text: "[sent a photo]", pic: image)
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func barButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: NSLocalizedString("Choose one", comment: ""), message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Unmatch and Block", comment: ""), style: .default, handler: { (alertAction) in
            self.blockUser()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("View Profile", comment: ""), style: .default, handler: { (alertAction) in
            self.showUserProfile()
        }))
        alertController.addAction(UIAlertAction(title: L_CANCEL, style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func blockUser() {
        let byUser = room.object(forKey:"byUser") as? NSDictionary
        let toUser = room.object(forKey:"toUser") as? NSDictionary
//        if byUser?.objectId == currentuser?.objectId {
//            room["liked"] = false
//
//            room.saveInBackground { (done, error) in
//                if error == nil{
//                    self.navigationController?.popToRootViewController(animated: true)
//                }
//            }
//
//
//        } else if toUser?.objectId == currentuser?.objectId {
//            room["likedback"] = false
//            room.saveInBackground { (done, error) in
//                if error == nil{
//                    self.navigationController?.popToRootViewController(animated: true)
//                }
//            }
//
//        }
    }
    
    private func showUserProfile() {
        let otherprofilevc = storyb.instantiateViewController(withIdentifier: "otherprofilevc") as! OtherProfileViewController
        otherprofilevc.user = self.incomingUser
        otherprofilevc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(otherprofilevc, animated: true)
    }

    // MARK: - LOAD MESSAGES
    private func loadMessages() {
        
        for message in self.chat.messages {
            self.addMessage(message: message)
        }
        
        if self.chat.messages.count > 0 {
            self.finishReceivingMessage()
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    func addMessage(message: ChatMessage) {
        self.messageObjects.append(message.imgURL)
        
        self.userIds.append(message.senderId)
        
        if message.imgURL.count > 0 {
            let mediaItem:AsyncPhotoMediaItem = AsyncPhotoMediaItem(url: message.imgURL)
            mediaItem.appliesMediaViewMaskAsOutgoing = (message.senderId == self.senderId)

            let chatMessage = JSQMessage(senderId: message.senderId, senderDisplayName: self.incomingUser.object(forKey: u_username) as? String, date: stringToDate(dateStr: UTCToLocal(dateStr: message.createdAt)), media: mediaItem)
            self.messages.append(chatMessage!)
        } else {
            let chatMessage = JSQMessage(senderId: message.senderId, senderDisplayName: self.incomingUser.object(forKey: u_username) as? String, date: stringToDate(dateStr: UTCToLocal(dateStr: message.createdAt)), text: message.message)
            self.messages.append(chatMessage!)
        }
    }
    
    // MARK: - SEND MESSAGES
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text.isEmpty {
            return
        }
        
        self.sendMessage(text: text, pic: nil)
        self.finishSendingMessage()
    }
 
    func sendMessage(text:String, pic:UIImage?) {
        guard let messageId = Database.database().reference().child("chats/\(self.chat.id)").childByAutoId().key else {
            return
        }

        let chatMessage = ChatMessage(id: messageId, senderId: (currentuser?.object(forKey: "userId") as! String), receiverId: self.incomingUser.object(forKey: "userId") as! String, message: text)
        
        if let pic = pic {
            
            let storageRef = Storage.storage().reference()
            let data = pic.pngData()!
            let profileImgRef = storageRef.child("\(self.chat.id)_\(messageId).png")
            profileImgRef.putData(data, metadata: nil, completion: { (metadata, error) in
                if let _ = metadata {
                    profileImgRef.downloadURL(completion: { (url, error) in
                        let imgURL = url?.absoluteString ?? ""
                        
                        let pushText = "\(self.selfUsername ?? ""): \(text)"
                        chatMessage.imgURL = imgURL
                        self.chat.sendMessage(message: chatMessage) {
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            
                            PushNotificationManager.shared.sendMessage(user: self.incomingUser!, message: pushText)
                            self.room.setValue(Int64(Date().timeIntervalSince1970), forKey: "lastUpdate") // ["lastUpdate"] = NSDate()
                        }
                    })
                }
            })
            
        } else {
            
            let pushText = "\(selfUsername ?? ""): \(text)"
            self.chat.sendMessage(message: chatMessage) {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                
                PushNotificationManager.shared.sendMessage(user: self.incomingUser!, message: pushText)
                self.room.setValue(Int64(Date().timeIntervalSince1970), forKey: "lastUpdate") // ["lastUpdate"] = NSDate()
            }
        }
        
        // update room with time
        let temp = room.object(forKey: "objectId") as! String
        var ref: DatabaseReference!
        
        room.setValue(Int64(Date().timeIntervalSince1970), forKey: "updatedAt")
          
        ref = Database.database().reference()
        ref.child("Matches").child(temp).setValue(room as NSDictionary) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
              print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully.")
            }
        }
    }
    
    // MARK: - DELEGATE METHODS
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
               
        if message.senderId == self.senderId {
            return outgoingBubbleImage
        }

        return incomingBubbleImage
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        
        if message.senderId == self.senderId {
          
            return selfAvatar
        } else {
           
            return incomingAvatar
        }
    }
 
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 1 == 0 {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell
            
        cell?.avatarImageView.layer.borderWidth = 0.1
        cell?.avatarImageView.layer.masksToBounds = true
        let message = messages[indexPath.row]
        
        if !message.isMediaMessage {
            if message.senderId == self.senderId {
                cell?.textView.textColor = .white
            } else {
                cell?.textView.textColor = .black
            }
            
            cell?.avatarImageView.layer.cornerRadius = 15
            cell?.textView.layer.masksToBounds = true
            cell?.textView.backgroundColor = UIColor.clear
        }
        
        return cell!
    }

    // MARK: - DATASOURCE
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return messages.count
    }
   
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let imgURL = self.messageObjects[indexPath.row]
        if imgURL.count > 0 {
            let message = self.messages[indexPath.row]
            let media = message.media as! AsyncPhotoMediaItem
            
            self.inputToolbar.contentView.textView.resignFirstResponder()
            
            let imageInfo = JTSImageInfo()
            imageInfo.image = media.image
            imageInfo.referenceRect = CGRect(x: phonewidth / 2, y: phoneheight / 2, width: 0, height: 0)
            imageInfo.referenceView = self.view
            imageInfo.referenceContentMode = .scaleAspectFit
            imageInfo.referenceCornerRadius = 10
            let imgvc = JTSImageViewController(imageInfo: imageInfo, mode: .image, backgroundStyle: .blurred)
            imgvc?.modalPresentationStyle = .custom
            imgvc?.show(from: self, transition: .fromOriginalPosition)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
    }
}

extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        
        guard let window = window else {
            return
        }
        
        if #available(iOS 11.0, *) {
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true
        }
    }
}
