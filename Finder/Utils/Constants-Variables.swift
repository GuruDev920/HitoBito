//
//  Constants-Variables.swift
//  Finder
//
//  Created by djay mac on 27/01/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit
import Photos

//Database
var isCurrentUserNotExist = false
//User
let u_gender            = "gender"
let u_locationText      = "locationText"
let u_viewedUsers       = "viewedUsers"
let u_emailVerified     = "emailVerified"
let u_pic1              = "pic1"
let u_pic2              = "pic2"
let u_pic3              = "pic3"
let u_pic4              = "pic4"
let u_pic5              = "pic5"
let u_pic6              = "pic6"
let u_name              = "name"
let u_about             = "about"
let u_dpLarge           = "dpLarge"
let u_fname             = "fname"
let u_location          = "location"
let u_username          = "username"
let u_blockUsers        = "blockUsers"
let u_password          = "password"
let u_dpSmall           = "dpSmall"
let u_email             = "email"
let u_age               = "age"
let u_height            = "height"
let u_curRelation       = "curRelationship"
let u_hasKids           = "hasKids"
let u_desiredRelation   = "desiredRelationship"
let u_job               = "job"
let u_religion          = "religion"
let u_fbId              = "fbId"

let u_token             = "token"

//User filtering fields
let u_minAge            = "minAge"
let u_maxAge            = "maxAge"
let u_interested        = "interested" //gender
let u_locationLimitMin  = "locationLimitMin"
let u_locationLimit     = "locationLimit"
let u_filterHeightMin   = "filterHeightMin"
let u_filterHeightMax   = "filterHeightMax"
let u_filterCurRelation = "filterCurRelationship"
let u_filterKids        = "filterKids"
let u_filterDesiredRelation = "filterDesiredRelationship"
let u_filterReligion    = "filterReligion"

//Chat
let ct_id           = "id"
let ct_senderId     = "senderId"
let ct_receiverId   = "receiverId"
let ct_message      = "message"
let ct_imgURL       = "imgURL"
let ct_isRead       = "isRead"
let ct_createdAt    = "createdAt"

//Local Storage
let lc_senderId     = "senderId"

let lc_serverKey    = "AAAAYlusJIg:APA91bFYyK_vVSX-1wOXFIu5AzW6oNP2su4fnJhnj79EuHkc42q4OWpcjeq8sM91ju_-vDT2CbRNdKJDzQhdBCl_zVECi-5Xnv5340SzfYkpvVBsVJgnUte8PLQLgRwejR4fui969FSC"

let USERDEFAULTS = UserDefaults.standard

let MAX_NUMBER_OF_MESSAGES = 200
let MAX_NUMBER_OF_IMAGES = 6
let DEFAULT_AGE     = 18
let MIN_AGE         = 18
let MAX_AGE         = 80
let MIN_LOCATION    = 0
let MAX_LOCATION    = 1000

let APPLE_ID_EMAIL = "apple_email"
let APPLE_ID_NAME = "apple_name"

// Height in centimeters
let MIN_HEIGHT      = 150
let MAX_HEIGHT      = 190
let DEFAULT_HEIGHT_MALE     = 180
let DEFAULT_HEIGHT_FEMALE   = 165
func getHeightList() -> [String] {
    var heights: [String] = []
    for i in MIN_HEIGHT ... MAX_HEIGHT {
        heights.append("\(i) cm")
    }
    return heights
}
let HEIGHTS = getHeightList()

let CUR_RELATIONSHIPS = [NSLocalizedString("Single", comment: ""),
                         NSLocalizedString("Married", comment: ""),
                         NSLocalizedString("Divorce", comment: "")]

let DESIRED_RELATIONSHIPS = [NSLocalizedString("Whatever I can get", comment: ""),
                             NSLocalizedString("Casual relationship", comment: ""),
                             NSLocalizedString("Serious relationship", comment: ""),
                             NSLocalizedString("Just friends", comment: "")]

let RELIGIONS = [NSLocalizedString("None believer", comment: ""),
                 NSLocalizedString("Christianity", comment: ""),
                 NSLocalizedString("Islam", comment: ""),
                 NSLocalizedString("Hinduism", comment: ""),
                 NSLocalizedString("Buddhism", comment: ""),
                 NSLocalizedString("Judaism", comment: ""),
                 NSLocalizedString("Other religions", comment: "")]

let GENDERS = [NSLocalizedString("Male", comment: ""),
               NSLocalizedString("Female", comment: ""),
               NSLocalizedString("Others", comment: "")]

let phonewidth = UIScreen.main.bounds.width
let phoneheight = UIScreen.main.bounds.height

let storyb = UIStoryboard(name: "Main", bundle: nil)

var currentuser : NSMutableDictionary? // PFUser.current()
var matchedPf = NSDictionary()
var justSignedUp = false

func showAlert(title: String?, message: String?, vc: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    vc.present(alertController, animated: true, completion: nil)
}

func calcDistanceInKm(from: CLLocation?, to: CLLocation?) -> String {
    guard let startPoint = from, let endPoint = to else {
        return "---"
    }
    
    let distance = Int(startPoint.distance(from: endPoint) / 1000)
    return "\(distance) km"
}

func calcDistanceInKm(from: NSDictionary?, to: CLLocation?) -> Int {
    
    guard let startPoint = from?.object(forKey: u_location) as? [Double] else {
        return 0
    }
    
    guard let endLoc = to else {
        return 0
    }
    let startLoc = CLLocation.init(latitude: startPoint[0], longitude: startPoint[1])
    
    return Int(startLoc.distance(from: endLoc) / 1000)
}

func calcDistanceInKm(from: NSDictionary?, to: NSDictionary?) -> Int {
    
    guard let startPoint = from?.object(forKey: u_location) as? [Double] else {
        return 0
    }
    
    guard let endPoint = to?.object(forKey: u_location) as? [Double] else {
        return 0
    }
    let startLoc = CLLocation.init(latitude: startPoint[0], longitude: startPoint[1])
    let endLoc = CLLocation.init(latitude: endPoint[0], longitude: endPoint[1])
    
    return Int(startLoc.distance(from: endLoc) / 1000)
}

func topViewController() -> UIViewController {
    var topController = UIApplication.shared.keyWindow?.rootViewController
    while let presentedViewController = topController!.presentedViewController {
        topController = presentedViewController
    }
    if topController?.isKind(of: UIAlertController.self) == true {
        return (topController!.presentingViewController)!
    }
    return topController!
}

//Blur Effect Background
var FrostGlassBackground: VisualEffectView!
func Global_ShowFrostGlass(_ vw: UIView!) {
    vw.insertSubview(FrostGlassBackground, at: 0)
}

func Global_HideFrostGlass() {
    FrostGlassBackground.removeFromSuperview()
}

func Global_SetGlassEffect() {
    FrostGlassBackground = VisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    FrostGlassBackground.colorTint = UIColor.black
    FrostGlassBackground.colorTintAlpha = 0.5
    FrostGlassBackground.blurRadius = 5
    FrostGlassBackground.scale = 1
}

//Localized Strings
let L_ERROR = NSLocalizedString("Error", comment: "")
let L_OK = NSLocalizedString("OK", comment: "")
let L_YES = NSLocalizedString("Yes", comment: "")
let L_NO = NSLocalizedString("No", comment: "")
let L_CANCEL = NSLocalizedString("Cancel", comment: "")
let L_ALL = NSLocalizedString("All", comment: "")
let L_ANY = NSLocalizedString("Any", comment: "")
let L_IDONOTCARE = NSLocalizedString("I don't care", comment: "")
