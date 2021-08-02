//
//  UserData.swift
//  Finder
//
//  Created by Tai on 6/12/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import Foundation

let user_picKeys = [u_pic1, u_pic2, u_pic3, u_pic4, u_pic5, u_pic6]

class UserData {

    var dpLarge : String?
    var dpSmall : String?
    var fname   = ""
    var name    = ""
    var about   = ""
    var age     = DEFAULT_AGE
    var gender  = 1
    var location    : CLLocation?
    var locationText: String?
    var height          = DEFAULT_HEIGHT_MALE
    var curRelation     = 0
    var hasKids         = false
    var desiredRelation = 0
    var job             = ""
    var religion        = 0
    var pics            : [String: String] = [:]
    var picsChanged     : [String: Bool] = [:]
    var picImages       : [String: UIImage] = [:]
    var fbtoken         : String?
    var emailVerified   = false

    init(user: NSDictionary?) {
        
        guard let user = user else {
            return
        }
        
        self.fname          = user.object(forKey: u_fname) as? String ?? ""
        self.name           = user.object(forKey: u_name) as? String ?? ""
        self.about          = user.object(forKey: u_about) as? String ?? ""
        self.age            = user.object(forKey: u_age) as? Int ?? DEFAULT_AGE
        self.gender         = user.object(forKey: u_gender) as? Int ?? 1
        let positions = user.object(forKey: u_location) as? [Double]
//        positions.append(self.location?.coordinate.latitude, self.location?.coordinate.longitude)
        if positions != nil, positions?.count == 2 {
            self.location = CLLocation.init(latitude: positions![0], longitude: positions![1])
        }
        self.locationText   = user.object(forKey: u_locationText) as? String
        self.height         = user.object(forKey: u_height) as? Int ?? (self.gender == 1 ? DEFAULT_HEIGHT_MALE : DEFAULT_HEIGHT_FEMALE)
        self.curRelation    = user.object(forKey: u_curRelation) as? Int ?? 0
        self.hasKids        = user.object(forKey: u_hasKids) as? Bool ?? false
        self.desiredRelation = user.object(forKey: u_desiredRelation) as? Int ?? 0
        self.job            = user.object(forKey: u_job) as? String ?? ""
        self.religion       = user.object(forKey: u_religion) as? Int ?? 0
        for picKey in user_picKeys {
            if let pic = user.object(forKey: picKey) as? String {
                self.pics[picKey] = pic
            }
        }
        self.dpLarge        = user.object(forKey: u_dpLarge) as? String
        self.dpSmall        = user.object(forKey: u_dpSmall) as? String
        self.fbtoken        = user.object(forKey: u_token) as? String
        self.emailVerified  = user.object(forKey: u_emailVerified) as? Bool ?? false
    }
}
