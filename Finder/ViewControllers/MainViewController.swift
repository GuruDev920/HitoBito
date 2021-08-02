//
//  MainViewController.swift
//  Finder
//
//  Created by djay mac on 27/01/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit
import CoreLocation
import Social
import SideMenu

import CollectionViewWaterfallLayout
import DKImagePickerController

protocol MainViewControllerDelegate {
    func didChatRequest(userIndex: Int)
    func didConfirmChatRequest(userIndex: Int)
}

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum TabItemType: Int {
        case profile
        case matchlist
        case findmatches
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var matchesTableView: UITableView!
    @IBOutlet weak var bottomCenterView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var btnAlert: UIButton!
    @IBOutlet weak var viewBadgeNewAlert: UIView!
    
    // for find matches
    @IBOutlet weak var findMatchesView: UIView!
    @IBOutlet weak var noUsersView: UIView!
    @IBOutlet weak var usersfoundlabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!

    @IBOutlet weak var viewSearching: UIView!
    @IBOutlet weak var lblSearching: UILabel!
    
    @IBOutlet weak var viewMatchedResult    : UIView!
    @IBOutlet weak var imgvUserProfile      : UIImageView!
    @IBOutlet weak var lblMatchTitle        : UILabel!
    @IBOutlet weak var lblMatchDescription  : UILabel!
    @IBOutlet weak var colvMatchedPeople    : UICollectionView!
    
    @IBOutlet weak var viewBadgeNewMsg      : UIView!
    
    var searchRipples: LNBRippleEffect?
    var usersFound:NSMutableArray = []
    var findMatchesQuery: DatabaseReference?
//    PFQuery<PFObject>?
    
    var userpics:[String] = []
    var photobuttonclicked:Int! // which button clickd
    var rooms = [NSDictionary]()
    var users = [NSDictionary]()
    var tabItemType: TabItemType = .profile
    
    let locationManager = CLLocationManager()
    
    private var isColvCellAdjusted = false
    private var isGettingChatRequests = false
    
    private var observerHandleChat  : [String: UInt] = [:]
    private var showChatBadges      : [String: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil || Auth.auth().currentUser?.uid == nil || Auth.auth().currentUser?.email == nil || ((Auth.auth().currentUser?.isEmailVerified) != nil) {
            self.performSegue(withIdentifier: "login", sender: self)
        } else {
            let token = UserDefaults.standard.string(forKey: "token")
            
            getCurrentUser { (result) in
                if result {
                    
                    currentuser!.setValue(token, forKey: "token")
                    saveUserInBackground(user: currentuser!) { (result) in
                        
                    }
                    self.getPhotos(forKey: user_picKeys)
                }
            }
        }
        
        
        bottomView.layer.cornerRadius = 20
        bottomView.layer.shadowRadius = 4.0
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowColor = UIColor.lightGray.cgColor
        bottomView.layer.shadowOffset = CGSize.zero
        bottomView.generateOuterShadow()

        bottomCenterView.layer.cornerRadius = 45
        bottomCenterView.layer.shadowRadius = 2
        bottomCenterView.layer.shadowOpacity = 0.5
        bottomCenterView.layer.shadowColor = UIColor.lightGray.cgColor
        bottomCenterView.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        bottomCenterView.generateOuterShadow()
       
//        registerCell()

        self.initMatchedResultUI()
        self.viewMatchedResult.isHidden = true

        self.initSearchingView()

        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(title ?? "Main")",
            AnalyticsParameterItemName: title ?? "Main",
            AnalyticsParameterContentType: "Main Screen"])
        setupSideMenu()
    }
    
    private func setupSideMenu() {
        // Define the menus
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "sideMenuNav") as? SideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.viewBadgeNewMsg.isHidden = true

//        if Auth.auth().currentUser != nil {
//            setObserverChat()
//            self.checkMessage()
//        } else {
//            Auth.auth().signInAnonymously { (result, error) in
//                if error == nil {
//                    self.setObserverChat()
//                    self.checkMessage()
//                }
//            }
//        }
        if !isGettingChatRequests {
            isGettingChatRequests = true
            self.processChatRequests()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeObserverChat()
    }
    
    var isFirstLoad = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstLoad {
            registerCell()
            isFirstLoad = false
        }
        
                
        getPhotos(forKey: user_picKeys)
        
        if currentuser != nil,
//            currentUser.isAuthenticated,
            currentuser?["location"] == nil {
            startLocation()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationName.displayMessage), object: nil, queue: nil, using: displayPushMessage)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationName.chatRequest), object: nil, queue: nil, using: handleChatRequestNotification)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func checkMessage() {
        guard let currentUser = currentuser, let senderId = USERDEFAULTS.string(forKey: lc_senderId) else {
            return
        }
        
        USERDEFAULTS.removeObject(forKey: lc_senderId)
        USERDEFAULTS.synchronize()

        MBProgressHUD.showAdded(to: self.navigationController?.view, animated: true)
        
        getUserInfo(userId: senderId) { (sender) in
            if sender != nil {

                
                MatchManager().getMatchesByuserTouser(user1: sender!, user2: currentuser!) { (objects) in
                    if let room = objects?.last {
                        ChatManager.shared.getChat(senderId: senderId, receiverId: currentUser.object(forKey: "userId") as! String) { (chat) in
                            MBProgressHUD.hide(for: self.navigationController?.view, animated: true)
                            let messagesVC = storyb.instantiateViewController(withIdentifier: "messagesvc") as! ChatMessagesViewController
                            messagesVC.chat = chat
                            messagesVC.room = room
                            messagesVC.incomingUser = sender
                            self.navigationController?.pushViewController(messagesVC, animated: true)
                        }
                    } else {
                        MBProgressHUD.hide(for: self.navigationController?.view, animated: true)
                    }
                }
                
            } else {
                MBProgressHUD.hide(for: self.navigationController?.view, animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setObserverChat() {
        if currentuser == nil {
            return
        }
        
        self.fetchMatches { (results) in
            guard let results = results else {
                return
            }
            
            for room in results {
                var matchedUserId = ""
                if let userId1 : String = (room.object(forKey: "byUser") as? NSDictionary)?.object(forKey: "userId") as? String, let userId2 : String = (room.object(forKey: "toUser") as? NSDictionary)?["userId"] as? String {
                    if userId1.elementsEqual(currentuser?.object(forKey: "userId") as! String) {
                        matchedUserId = userId1
                    } else if userId2.elementsEqual(currentuser?.object(forKey: "userId") as! String) {
                        matchedUserId = userId2
                    }

                    self.addObserverChat(matchedUserId: matchedUserId)
                }
            }
        }
    }
    
    private func addObserverChat(matchedUserId: String) {
        guard let receiverId = currentuser?.object(forKey: "userId") else {
            return
        }
//
        let ref = Database.database().reference()
        
        let chatId = ChatManager.shared.chatIdWith(senderId: matchedUserId, receiverId: receiverId as! String)
        if self.observerHandleChat[chatId] == nil {
            self.observerHandleChat[matchedUserId] = ref.child("chats/\(chatId)").queryLimited(toLast: 1).observe(.value, with: { snapshot in
                if let data = snapshot.value as? [String : Any], let msgData = data.values.first as? [String : Any] {
                    let msg = ChatMessage(data: msgData)
                    if msg.receiverId.elementsEqual(receiverId as! String), msg.isRead == false {
                        self.viewBadgeNewMsg.isHidden = false
                        self.showChatBadges[matchedUserId] = true
                    } else {
                        self.showChatBadges[matchedUserId] = false
                    }
                    if self.tabItemType == .matchlist {
                        self.loadMatchData()
                    }
                }
            })
        }
    }
    
    private func removeObserverChat() {
        let ref = Database.database().reference()
        for (chatId, handler) in self.observerHandleChat {
            ref.child("chats/\(chatId)").removeObserver(withHandle: handler)
            self.observerHandleChat.removeValue(forKey: chatId)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logout" {
            showTabBarContent(.profile)
        } else {
            guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
            sideMenuNavigationController.settings.presentationStyle.onTopShadowOpacity = 1.0
        }
    }
    
    func registerCell(){
        
        let ownProfileImageCell = UINib(nibName: "OwnProfileImageCell",
                            bundle: nil)
        self.profileTableView.register(ownProfileImageCell,
                                forCellReuseIdentifier: "OwnProfileImageCell")
        let ownProfilePhotosButtonCell = UINib(nibName: "ProfilePhotosButtonCell",
                            bundle: nil)
        self.profileTableView.register(ownProfilePhotosButtonCell,
                                forCellReuseIdentifier: "ProfilePhotosButtonCell")
        let ownProfileImagesCell = UINib(nibName: "ProfileImagesCell",
                            bundle: nil)
        self.profileTableView.register(ownProfileImagesCell,
                                forCellReuseIdentifier: "ProfileImagesCell")
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self

        let matchedPersonCell = UINib(nibName: "MatchedPersonCell", bundle: nil)
        self.colvMatchedPeople.register(matchedPersonCell, forCellWithReuseIdentifier: "MatchedPersonCell")
    }
    
    private func initMatchedResultUI() {
        self.imgvUserProfile.image = UIImage(named: "ic_female")
        self.lblMatchTitle.text = "\(NSLocalizedString("Hey", comment: ""))!"
        
        guard let user = currentuser else {
            return
        }
        
        if let pic = user.object(forKey: u_dpSmall) as? String {
            self.imgvUserProfile.sd_setImage(with: URL(string: pic), completed: nil)
        }
        
        let name = user.object(forKey: "name") as? String ?? ""
        self.lblMatchTitle.text = "\(NSLocalizedString("Hey", comment: "")) \(name)!"
    }
    
    private func initSearchingView() {
        self.lblSearching.layer.cornerRadius = 15
        self.lblSearching.layer.borderWidth = 1.0
        self.lblSearching.layer.borderColor = UIColor.clear.cgColor
        self.lblSearching.layer.masksToBounds = true

        self.viewSearching.layer.shadowColor = UIColor(hex6: 0xfb95c9).cgColor
        self.viewSearching.layer.shadowOffset = CGSize(width:0, height: 2.0)
        self.viewSearching.layer.shadowRadius = 5.0
        self.viewSearching.layer.shadowOpacity = 0.7
        self.viewSearching.layer.masksToBounds = false
        self.viewSearching.layer.shadowPath = UIBezierPath(roundedRect: self.viewSearching.bounds, cornerRadius: 15).cgPath
    }
    
    private func adjustCollectionViewCellFrame() {
        if !self.isColvCellAdjusted {
            self.isColvCellAdjusted = true
            
            let layout = CollectionViewWaterfallLayout()
            layout.columnCount = 2
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.headerInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            layout.headerHeight = 0
            layout.footerHeight = 0
            layout.minimumColumnSpacing = 10
            layout.minimumInteritemSpacing = 10
            
            self.colvMatchedPeople.collectionViewLayout = layout
        }
    }
    
    @objc func displayPushMessage (notification: Notification) -> Void {
        if self.tabItemType == .matchlist {
            loadMatchData()
        }
//
        if let aps = notification.userInfo?["aps"] as? NSDictionary, let messageText = aps.object(forKey: "alert") as? String {
            showAlert(title: NSLocalizedString("New Message", comment: ""), message: messageText, vc: self)
        }
    }

    @objc func handleChatRequestNotification(notification: Notification) -> Void {
        
        guard let pushType = notification.userInfo?["Type"] as? String else {
            return
        }
        
        if pushType == PushNotificationType.chatRequestSent {
            self.processChatRequests()
        } else if pushType == PushNotificationType.chatRequestAccepted {
//            if let userId = notification.userInfo?["userId"] as? String, let query = PFUser.query() {
//                query.whereKey("objectId", equalTo: userId)
//                query.findObjectsInBackground { (users, error) in
//                    if let accepter = users?.first as? PFUser {
//                        self.showMatchFound(forUser: accepter)
//                    }
//                }
//            }
        } else {
            if let aps = notification.userInfo?["aps"] as? NSDictionary, let messageText = aps.object(forKey: "alert") as? String {
                showAlert(title: NSLocalizedString("New Message", comment: ""), message: messageText, vc: self)
            }
        }
    }
    
    @objc func applicationDidBecomeActive() {
        if topViewController() is ChatRequestAcceptViewController {
            return
        }
        
        if !isGettingChatRequests {
            isGettingChatRequests = true
            self.processChatRequests()
            
            self.checkMessage()
        }
    }
    
    private func processChatRequests() {
        self.isGettingChatRequests = false
//        MatchManager.shared.getPendingRequestsToMe { (senders) in
//            
//            var user : NSDictionary?
//            guard let senders = senders else {
//                return
//            }
//            
//            for sender in senders {
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatRequestAcceptViewController") as! ChatRequestAcceptViewController
//                if let tmp = user{
//                    if tmp != sender{
//                        vc.user = sender
//                        vc.delegate = self
//                        vc.modalPresentationStyle = .overFullScreen
//                        vc.modalTransitionStyle = .crossDissolve
//                        topViewController().present(vc, animated: true, completion: nil)
//                    }
//                }else{
//                    vc.user = sender
//                    vc.delegate = self
//                    vc.modalPresentationStyle = .overFullScreen
//                    vc.modalTransitionStyle = .crossDissolve
//                    topViewController().present(vc, animated: true, completion: nil)
//                }
//                user = sender
//            }
//        }
    }
    
    func startLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        guard let location = locationManager.location else {
            return
        }
        
        getLocation(location: location)
    }
    
    func getLocation(location: CLLocation) {
        
        if currentuser == nil {
            return
        }
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            var locationStr = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
            if error == nil,
                let placemark = placemarks?.first,
                let administrativeArea = placemark.administrativeArea {

                if let locality = placemark.locality {
                    locationStr = String(format: "%@, %@", locality, administrativeArea)
                } else {
                    locationStr = administrativeArea
                }
            }
            
            var points = [Double]()
            points.append(location.coordinate.latitude)
            points.append(location.coordinate.longitude)
            
            currentuser?.setValue(points, forKey: u_location)
//            ["location"] = PFGeoPoint(location: location)
            currentuser?.setValue(locationStr, forKey: u_locationText)  // ["locationText"] = locationStr
            
            saveUserInBackground(user: currentuser!) { (result) in
                if result {
                    self.profileTableView.reloadData()
                }
            }
        })
    }
 
    private var isLoadingMatchData = false
    private func loadMatchData() {
        if isLoadingMatchData {
            return
        }
        
        isLoadingMatchData = true
        
        rooms = [NSDictionary]()
        users = [NSDictionary]()
        
        if self.viewIfLoaded?.window != nil {
            MBProgressHUD.showAdded(to: self.navigationController?.view, animated: true)
        }
        self.fetchMatches { (results) in
            MBProgressHUD.hide(for: self.navigationController?.view, animated: true)
            self.isLoadingMatchData = false
            
            if let results = results {
                self.rooms = results
                self.users.removeAll()
                var tempRooms = [NSDictionary]()

                for room in self.rooms {
                    let pendingStatus = room.object(forKey: "pending") as! Int
                    if pendingStatus == 0 {
                        var user1Id: String = ""
                        var user2Id: String = ""
                        let user1 = room.object(forKey: "byUser") as? NSDictionary
                        if (user1 != nil) {
                            user1Id = user1!.object(forKey: "userId") as! String
                        } else {
                            continue
                        }
                        let user2 = room.object(forKey: "toUser") as? NSDictionary
                        if (user2 != nil) {
                            user2Id = user2!.object(forKey: "userId") as! String
                        } else {
                           continue
                        }
                        
                        let roomCount = tempRooms.count
                        if !(user1Id.elementsEqual(Auth.auth().currentUser!.uid)) {
                            if roomCount != 0 {
                                let tempRoom = tempRooms[roomCount - 1]
                                let curTime = room.object(forKey: "updatedAt") as? Int64
                                let prevTime = tempRoom.object(forKey: "updatedAt") as? Int64
                                
                                if curTime! > prevTime! {
                                    self.users.insert(user1!, at: roomCount - 1)
                                    tempRooms.insert(room, at: roomCount - 1)
                                } else {
                                    self.users.append(user1!)
                                    tempRooms.append(room)
                                }
                            } else {
                                self.users.append(user1!)
                                tempRooms.append(room)
                            }
                        } else if !(user2Id.elementsEqual(Auth.auth().currentUser!.uid)) {
                            if roomCount != 0 {
                                let tempRoom = tempRooms[roomCount - 1]
                                let curTime = room.object(forKey: "updatedAt") as? Int64
                                let prevTime = tempRoom.object(forKey: "updatedAt") as? Int64
                                
                                if curTime! > prevTime! {
                                    self.users.insert(user2!, at: roomCount - 1)
                                    tempRooms.insert(room, at: roomCount - 1)
                                } else {
                                    self.users.append(user2!)
                                    tempRooms.append(room)
                                }
                            } else {
                                self.users.append(user2!)
                                tempRooms.append(room)
                            }
                        }
                    }
                }
                
                self.rooms = tempRooms
            }
            self.matchesTableView.reloadData()
        }
    }
    
    private func fetchMatches(callback: (([NSDictionary]?) -> ())?) {
        MatchManager().getMatchesRelatedMe { (result) in
            var objects = [NSDictionary]()
            for object in result! {
                objects.append(object)
            }
            callback!(objects)
        }
        
    }
    
    func stopFindMatches() {
        self.findMatchesQuery?.cancelDisconnectOperations()
        
        self.noUsersView.isHidden = false
        self.usersFound.removeAllObjects()
    }
    
    func startFindMatches() {
        
        if searchRipples == nil {
            print(searchButton.frame)
            searchRipples = LNBRippleEffect(image: UIImage(named: "find"), frame: searchButton.frame, color: UIColor(hexString: "#8F0049"), target: nil, id: self)
            searchRipples?.setRippleColor(UIColor(hex6: 0x8F0049))
            searchRipples?.setRippleTrailColor(UIColor(hex8: 0xfb95c990))
            noUsersView.addSubview(searchRipples!)
        }
        
        self.searchButton.isHidden = true
        self.viewMatchedResult.isHidden = true
        
        self.usersfoundlabel.isHidden = true
        self.viewSearching.isHidden = false
        
        if let mapVC = self.children.last as? MapForMatchViewController {
            mapVC.currentLocationPressed()
        }
        
        findUsers { (array) in
            if self.usersFound.count == 0{
                self.usersFound.addObjects(from: array as [AnyObject])
            }
            self.filterUsersFound()
            
            self.searchRipples?.removeFromSuperview()
            self.searchRipples = nil
            
            self.viewSearching.isHidden = true
            
            if self.usersFound.count > 0 {
                
                self.noUsersView.isHidden = true

                self.initMatchedResultUI()
                self.viewMatchedResult.isHidden = false
                
            } else {
                self.usersfoundlabel.isHidden = false
                self.noUsersView.isHidden = false
                self.searchButton.isHidden = false

                self.viewMatchedResult.isHidden = true
            }
            
//            self.colvMatchedPeople.reloadData()
        }
    }

    private func filterUsersFound() {
        let currentUserId = currentuser?.object(forKey: "userId") as! String
        
        let ref = Database.database().reference()
        ref.child("Matches").observeSingleEvent(of: .value, with: { (snapshot) in

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

                    for temp in self.usersFound {
                        let user = temp as! NSDictionary
                        if byUserId == currentUserId && toUserId == user.object(forKey: "userId") as! String {
                            self.usersFound.remove(temp)
                            break
                        } else if toUserId == currentUserId && byUserId == user.object(forKey: "userId") as! String {
                            self.usersFound.remove(temp)
                            break
                        }
                    }
                }
            }
            
            self.colvMatchedPeople.reloadData()
        })
    }

    private func updateMatch(liked: Bool, for user: NSDictionary) {
        MatchManager.shared.updateMatch(liked: liked, for: user) { (likedback) in
            if likedback {
                self.showMatchFound(forUser: user)
                self.addObserverChat(matchedUserId: (user.object(forKey: "userId")) as! String)
            }
        }
    }

    func showUserProfile(userIndex: Int) {
        guard let user = self.usersFound[userIndex] as? NSDictionary else {
            return
        }
        
        let otherprofilevc = storyb.instantiateViewController(withIdentifier: "otherprofilevc") as! OtherProfileViewController
        otherprofilevc.user = user
        otherprofilevc.userIndex = userIndex
        otherprofilevc.delegateMainViewController = self
        otherprofilevc.isChatRequested = false
        self.navigationController?.pushViewController(otherprofilevc, animated: true)
    }

    func findUsers(fn: @escaping(NSMutableArray) -> ()) { // find all the users
        guard let currentuser = currentuser else {
            return
        }
        
        let userFilterData = UserFilterData(user: currentuser)
        
        self.findMatchesQuery = Database.database().reference() // PFUser.query()
        
        var ages: [Int] = []
        for age in userFilterData.filterAgeMin ... userFilterData.filterAgeMax {
            ages.append(age)
        }
        
        var heights: [Int] = []
        for height in userFilterData.filterHeightMin ... userFilterData.filterHeightMax {
            heights.append(height)
        }
        self.addListFilterToQuery(value: userFilterData.filterCurRelation, key: u_curRelation)
        self.addListFilterToQuery(value: userFilterData.filterDesiredRelation, key: u_desiredRelation)
        self.addListFilterToQuery(value: userFilterData.filterReligion, key: u_religion)

        self.addYesNoFilterToQuery(value: userFilterData.filterKids, key: u_hasKids)
        
        self.findMatchesQuery!.child("users").observeSingleEvent(of : .value, with: { (snapshot) in
            self.usersFound.removeAllObjects()
            var results = [NSDictionary]()
            let teamDict = snapshot.value as? [String: Any]
             if let teamDict = teamDict {
                for team in teamDict {
                    let teamValue = team.value as? NSDictionary ?? nil
                    if teamValue != nil, self.isCheckInFilterCondition(user: teamValue!) {
                        results.append(teamValue!)
                    }
                }
             } else {
            }
            let array:NSMutableArray = NSMutableArray(array: results)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fn(array)
            }
        })
    }
    
    func isCheckInFilterCondition(user: NSDictionary) -> Bool {
        
        let userId: String? = user.object(forKey: "userId") as? String
        if userId == nil {
            return false
        }
        let currentId: String = currentuser?.object(forKey: "userId") as! String
        if userId!.elementsEqual(currentId) {
            return false
        }
        
        let userFilterData = UserFilterData(user: currentuser)
        // Email Verified
//        let emailVerified: Bool = user.object(forKey: u_emailVerified) as? Bool ?? false
//        if !emailVerified {
//            return false
//        }
        // Age
        let age: Int = user.object(forKey: u_age) as? Int ?? 28
        if age < userFilterData.filterAgeMin {
            return false
        } else if age > userFilterData.filterAgeMax {
            return false
        }
        // Height
        let height: Int = user.object(forKey: u_height) as? Int ?? 175
        if height < userFilterData.filterHeightMin {
            return false
        } else if height > userFilterData.filterHeightMax {
            return false
        }
        // Interest
        let gender: Int = user.object(forKey: "gender") as? Int ?? 0
        if userFilterData.filterGender != 4, gender != userFilterData.filterGender {
            return false
        }
        // Location
        let distance = calcDistanceInKm(from: currentuser, to: user)
        if distance > userFilterData.filterLocationMax  || distance < userFilterData.filterLocationMin{
            return false
        }
        
        //Current Relationship
        let curRelationship: Int64 = user.object(forKey: "curRelationship") as? Int64 ?? -1
        if userFilterData.filterCurRelation != 0 {
            if curRelationship == 1 {   // filter is single and relationship is married
                return false
            }
        }

        //Desired Relationship
        let desiredRelationship: Int = user.object(forKey: "desireRelationship") as? Int ?? 0
        if userFilterData.filterDesiredRelation != 0, desiredRelationship != userFilterData.filterDesiredRelation {
            return false
        }
        //kids
        let kids: Int = (user.object(forKey: "hasKids") as? Bool ?? false) == true ? 1 : 0
        
        if userFilterData.filterKids != 2, userFilterData.filterKids != kids{
            return false
        }
        
        //Religion
        let religion: Int = user.object(forKey: "religion") as? Int ?? 0
        if userFilterData.filterReligion != -1, religion != userFilterData.filterReligion {
            return false
        }
        
        return true
    }
    
    private func addListFilterToQuery(value: Int, key: String) {
        if value != -1 {
//            self.findMatchesQuery?.whereKey(key, equalTo: value)
        }
    }

    private func addYesNoFilterToQuery(value: Int, key: String) {
        if value != 2 {
//            self.findMatchesQuery?.whereKey(key, equalTo: value == 0 ? false : true)
        }
    }

    func getPhotos(forKey: [String]) {
        // get user  pics
        self.userpics.removeAll(keepingCapacity: false)
        for f in forKey {
            if let pic = currentuser?.object(forKey: f) as? String {
                self.userpics.append(pic)
            }
        }

        self.profileTableView.reloadData()
        self.view.layoutSubviews()
    }
    
    func showTabBarContent(_ tabItemType: TabItemType) {
        if tabItemType == self.tabItemType {
            return
        }
        
        self.tabItemType = tabItemType
        
        self.stopFindMatches()
        if (tabItemType == .profile) {
            self.titleLabel.text = NSLocalizedString("PROFILE", comment: "")
            self.btnEdit.isHidden = false
            self.btnFilter.isHidden = true
            self.btnAlert.isHidden = true
            self.viewBadgeNewAlert.isHidden = true
            self.profileTableView.isHidden = false
            self.matchesTableView.isHidden = true
            self.findMatchesView.isHidden = true
        } else if (tabItemType == .matchlist) {
            self.titleLabel.text = NSLocalizedString("Match Result", comment: "")
            self.btnEdit.isHidden = true
            self.btnFilter.isHidden = true
            self.btnAlert.isHidden = false
            self.matchesTableView.isHidden = false
            self.profileTableView.isHidden = true
            self.findMatchesView.isHidden = true
            
            loadMatchData()
            checkNewChatRequests()
        } else {
            self.titleLabel.text = NSLocalizedString("DISCOVERY", comment: "")
            self.btnEdit.isHidden = true
            self.btnFilter.isHidden = false
            self.btnAlert.isHidden = true
            self.viewBadgeNewAlert.isHidden = true
            self.findMatchesView.isHidden = false
            self.matchesTableView.isHidden = true
            self.profileTableView.isHidden = true
            
            self.adjustCollectionViewCellFrame()
            
            startFindMatches()
        }
    }
    
    private func showMatchFound(forUser: NSDictionary) {
        if let topVC = topViewController() as? UINavigationController{
            if topVC.viewControllers.last is OtherProfileViewController || topVC.viewControllers.last is MainViewController{
                let matchvc = storyb.instantiateViewController(withIdentifier: "matchfoundvc") as! MatchFoundViewController
                matchvc.getUser = forUser
                matchvc.delegate = self
                matchvc.modalPresentationStyle = .overFullScreen
                matchvc.modalTransitionStyle = .crossDissolve
                self.navigationController?.present(matchvc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func didTapProfile(_ sender: AnyObject) {
        showTabBarContent(.profile)
    }
    
    @IBAction func didTapFindMatch(_ sender: AnyObject) {
        showTabBarContent(.findmatches)
    }
    
    @IBAction func didTapMatchedList(_ sender: AnyObject) {
        showTabBarContent(.matchlist)
    }
    
    @IBAction func searchTapped(_ sender: AnyObject) {
        self.startFindMatches()
    }
    
    @IBAction func onBtnFilter(_ sender: UIButton) {
        let vcSettings = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        vcSettings.postFiltersSet = {
            self.stopFindMatches()
            self.startFindMatches()
        }
        
        self.navigationController?.pushViewController(vcSettings, animated: true)
    }
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.profileTableView {
            return 3;
        } else if tableView == self.matchesTableView {
            if self.rooms.count > 0 {
                return self.rooms.count
            }
            return 1
        }
        
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.profileTableView {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OwnProfileImageCell", for: indexPath) as! OwnProfileImageCell
                
                cell.initCell(user: currentuser)
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePhotosButtonCell", for: indexPath) as! ProfilePhotosButtonCell
                cell.initCell(user: currentuser)
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImagesCell", for: indexPath) as! ProfileImagesCell
                cell.delegate = self
                cell.initCell(photos: self.userpics)
                
                return cell
            }
        } else if tableView == self.matchesTableView {
            if rooms.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nochatcell", for: indexPath)
                cell.selectionStyle = .none
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "chatcell", for: indexPath) as! ChatViewCell
                cell.selectionStyle = .none
                
                let targetObject = rooms[indexPath.row] as NSDictionary
                let targetUser = users[indexPath.row] as NSDictionary
                
                let updatedAtTime = targetObject.object(forKey: "updatedAt") as? Int64
                if (updatedAtTime != nil) {
                    let updatedAt = NSDate.init(timeIntervalSince1970: TimeInterval.init(updatedAtTime!))
                    cell.timeAgo.text = String(format: "%@", updatedAt.formattedAsTimeAgo() ?? NSLocalizedString("Now", comment: ""));
                }
                
                cell.backgroundColor = UIColor.clear
                
                cell.timeAgo.textColor = colorText
                cell.nameUser.textColor = colorText
                cell.lastMessage.textColor = colorText
                
                let targetUserId = targetUser.object(forKey: "userId") as! String
                cell.viewBadgeNewMsg.isHidden = !(self.showChatBadges[targetUserId] ?? false)
                
                getUserInfo(userId: targetUserId) { (fUser) in
                    if (fUser != nil) {
                        cell.nameUser.text = fUser!.object(forKey: u_name) as? String
                        if let pica = fUser?.object(forKey: u_dpLarge) as? String {
                            cell.userdp.sd_setImage(with: URL(string: pica), completed: nil)
                            cell.userdp.layer.borderColor = colorText.cgColor
                        }
                    }
                }
                
                ChatManager.shared.getLastMessage(senderId: (currentuser?.object(forKey: "userId"))! as! String, receiverId: targetUser.object(forKey: "userId")! as! String) { (chatMessage) in
                    guard let chatMessage = chatMessage else {
                        cell.lastMessage.text = ""
                        return
                    }
                    cell.lastMessage.text = chatMessage.message
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.profileTableView {
            return caculateHeightProfileCell(indexPath: indexPath)
        } else if tableView == self.matchesTableView {
            if rooms.count == 0 {
                return 334
            }
            return 104
        }
        return 0
    }
    
    func caculateHeightProfileCell(indexPath:IndexPath) -> CGFloat{
        let screenSize: CGRect = UIScreen.main.bounds
        if indexPath.row == 0 {
            return (UIScreen.main.bounds.size.width - 14) * 133 / 150 + 20
        } else if indexPath.row == 1 {
            return 50
        } else if indexPath.row == 2 {
            if userpics.count == 0 {
                let cellHeight = (screenSize.width - 3) * 1 / 3
                return cellHeight
            } else if userpics.count == 1 || userpics.count == 2 {
                let cellHeight = (screenSize.width - 3) * 2 / 3
                return cellHeight
            } else if userpics.count > 2 {
                return screenSize.width - 3
            }
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if tableView == self.matchesTableView {
            if rooms.count > 0 {
                
                let user = users[indexPath.row] as NSDictionary
                let targetObject = rooms[indexPath.row] as NSDictionary
                
                MBProgressHUD.showAdded(to: self.view, animated: true)
                if targetObject.object(forKey: "pending") as! Bool == true {
                    showAlert(title: "Info", message: NSLocalizedString("Please wait until user accepts your request", comment: ""), vc: self)
                    MBProgressHUD.hide(for: self.view, animated: true)
                    return
                }
                ChatManager.shared.getChat(senderId: (currentuser?.object(forKey: "userId") as! String), receiverId: user.object(forKey: "userId") as! String) { (chat) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    let messagesVC = storyb.instantiateViewController(withIdentifier: "messagesvc") as! ChatMessagesViewController
                    messagesVC.chat = chat
                    messagesVC.room = targetObject
                    messagesVC.incomingUser = user
                    messagesVC.hidesBottomBarWhenPushed = true
                    
                    self.navigationController?.pushViewController(messagesVC, animated: true)
                }
            }
        }
    }
    
    @IBAction func onNewRequests(_ sender: Any) {
        MatchManager.shared.getPendingRequestsToMe { (senders) in
            
            var user : NSDictionary?
            guard let senders = senders else {
                return
            }
            
            for sender in senders {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewRequestViewController") as! NewRequestViewController
                if let tmp = user {
                    if tmp != sender {
                        vc.user = sender
                        vc.delegate = self
                        vc.modalPresentationStyle = .overFullScreen
                        vc.modalTransitionStyle = .crossDissolve
                        topViewController().present(vc, animated: true, completion: nil)
                    }
                } else {
                    vc.user = sender
                    vc.delegate = self
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    topViewController().present(vc, animated: true, completion: nil)
                }

                user = sender
            }
        }
    }
    
    private func checkNewChatRequests() {
        MatchManager.shared.getPendingRequestsToMe { (senders) in
            guard let senders = senders else {
                return
            }
            
            if !senders.isEmpty {
                self.viewBadgeNewAlert.isHidden = false
            }
        }
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}


public extension UIView {
    static func fromNib<T>(withOwner: Any? = nil, options: [UINib.OptionsKey : Any]? = nil) -> T where T: UIView
    {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "\(self)", bundle: bundle)

        guard let view = nib.instantiate(withOwner: withOwner, options: options).first as? T else {
            fatalError("Could not load view from nib file.")
        }
        return view
    }
}

extension MainViewController: ProfileImagesCellDelegate {
    func photoImageTapped(_ index: Int, images: [UIImage]) {
    }
    
    func photoButtonTapped(_ index: Int) {
        photobuttonclicked = index

        let picker = DKImagePickerController()
        picker.singleSelect = false
        picker.sourceType = .both
        picker.assetType = .allPhotos
        
        picker.didSelectAssets = {[unowned self] (assets: [DKAsset]) in
            let numberOfImages = assets.count
            if numberOfImages == 0 {
                return
            }
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            self.uploadMultiImage(forIndex: index, _count: 0, assets: assets)
        }
        
        self.present(picker, animated: true, completion: nil)
    }
    
    func uploadMultiImage(forIndex index: Int, _count: Int, assets: [DKAsset]) {
        
        let postUploadingImages = {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.getPhotos(forKey: user_picKeys)
            self.profileTableView.reloadData()
        }
        
        let numberOfImages = assets.count
        
        var count = _count
        for asset in assets {
            asset.fetchOriginalImage { (image: UIImage?, _: [AnyHashable: Any]?) in
//                let cropper = CropViewController(croppingStyle: .default, image: image!)
//                cropper.delegate = self
//                self.present(cropper, animated: true, completion: nil)
                count += 1
                if let image = image {
                    self.saveImage(imageNumber: index + count, pickedImg: image) {
                        if count == numberOfImages {
                            postUploadingImages()
                        } else {
                            self.uploadMultiImage(forIndex: index, _count: count, assets: assets)
                        }
                    }
                } else {
                    if count == numberOfImages {
                        postUploadingImages()
                    } else {
                        self.uploadMultiImage(forIndex: index, _count: count, assets: assets)
                    }
                }
            }
        }
    }
    
    private func saveImage(imageNumber: Int, pickedImg: UIImage, callback: (() -> ())?) {
        let picFieldName = String(format: "pic%d", imageNumber)
        
        let dataL = scaleImage(image: pickedImg, and: CGSize(width: 320, height: 320)).jpegData(compressionQuality: 0.7)
        
        uploadImage(imageData: dataL!) { (urlStr) in
            currentuser?.setValue(urlStr, forKey: picFieldName)
            if imageNumber == 1 {
                currentuser?.setValue(urlStr, forKey: u_dpLarge)
                currentuser?.setValue(urlStr, forKey: u_dpSmall)
            }
            saveUserInBackground(user: currentuser!) { (result) in
                if result {
                    callback?()
                }
            }
        }
    }
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {        
        self.dismiss(animated: true, completion: nil)
   }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        guard let location = locationManager.location else {
            return
        }
        
        getLocation(location: location)
        locationManager.stopUpdatingLocation()
    }
}

extension MainViewController: MatchFoundViewControllerDelegate {
    func chatNow(room: NSDictionary, user: NSDictionary) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        ChatManager.shared.getChat(senderId: (currentuser?.object(forKey: "userId") as! String), receiverId: user.object(forKey: "userId") as! String) { (chat) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let messagesVC = storyb.instantiateViewController(withIdentifier: "messagesvc") as! ChatMessagesViewController
            messagesVC.chat = chat
            messagesVC.room = room
            messagesVC.incomingUser = user
            self.navigationController?.pushViewController(messagesVC, animated: true)
        }
    }
}

extension MainViewController: MainViewControllerDelegate {
    
    func didChatRequest(userIndex: Int) {
        let user = self.usersFound[userIndex] as! NSDictionary

        let vcConfirm = storyboard?.instantiateViewController(withIdentifier: "ChatRequestConfirmViewController") as! ChatRequestConfirmViewController
        vcConfirm.modalPresentationStyle = .overFullScreen
        vcConfirm.modalTransitionStyle = .crossDissolve
        vcConfirm.user = user
        vcConfirm.userIndex = userIndex
        vcConfirm.delegateMainViewController = self
        self.present(vcConfirm, animated: true, completion: nil)
        
    }
    
    func didConfirmChatRequest(userIndex: Int) {
        let user = self.usersFound[userIndex] as! NSDictionary

        self.updateMatch(liked: true, for: user)

        self.usersFound.removeObject(at: userIndex)

        self.colvMatchedPeople.reloadData()

        if self.usersFound.count == 0 {
            self.searchRipples?.removeFromSuperview()
            self.searchRipples = nil

            self.usersfoundlabel.isHidden = false
            self.noUsersView.isHidden = false
            self.searchButton.isHidden = false

            self.viewMatchedResult.isHidden = true
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.usersFound.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchedPersonCell", for: indexPath) as! MatchedPersonCell

        cell.initCell(user: self.usersFound[indexPath.row] as? NSDictionary, userIndex: indexPath.row)
        cell.delegate = self

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showUserProfile(userIndex: indexPath.row)
    }
}

extension MainViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let extraHeight = (indexPath.row % 4 == 0 || indexPath.row % 4 == 3) ? 30 : 0
        return CGSize(width: 140, height: 200 + extraHeight)
    }
}

extension MainViewController: ChatRequestAcceptViewControllerDelegate {
    func didAcceptChatRequest(userId: String) {
        self.loadMatchData()
        self.addObserverChat(matchedUserId: userId)
        checkNewChatRequests()
    }
}

extension MainViewController: NewRequestViewControllerDelegate {
    func didAcceptNewRequest(userId: String) {
        self.loadMatchData()
        self.addObserverChat(matchedUserId: userId)
        checkNewChatRequests()
    }
    
    func didDeclineNewRequest(userId: String) {
        checkNewChatRequests()
    }
}


/* gender: male - 1, female - 2, other - 3
    curRelationship: single - 0 , married - 1, divorce - 2
    haskids= true, false
    desired relationship: whatever - 0, casual - 1, serious - 2, just friend - 3
    religion: none - 0, christianity - 1, Islam - 2, Hinduism - 3, Budhism - 4, Judiasm - 5, other religion - 6
 
 
 filtercurrentRelationship - any-0, single-1
 filterkids = yes - 1, no - 0, any - 2
 filterreligion = don't care  -1, doesnt believe : 0,christianity - 1, Islam - 2, Hinduism - 3, Budhism - 4, Judiasm - 5, other religion - 6
 filterdesiredrelationship - whatever - 0, casual - 1, serious - 2, just friend - 3
 */
