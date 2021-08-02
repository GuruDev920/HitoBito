//
//  UserFilterData.swift
//  Finder
//
//  Created by Tai on 6/12/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import Foundation

class UserFilterData {
    
    var filterAgeMin        = MIN_AGE
    var filterAgeMax        = MAX_AGE
    var filterGender        = 4
    var filterLocationMin   = MIN_LOCATION
    var filterLocationMax   = MAX_LOCATION
    var filterHeightMin     = MIN_HEIGHT
    var filterHeightMax     = MAX_HEIGHT
    var filterCurRelation   = 0
    var filterKids          = 2
    var filterDesiredRelation = 0
    var filterReligion      = -1
    
    init(user: NSDictionary?) {
        guard let user = user else {
            return
        }

        self.filterAgeMin       = user.object(forKey: u_minAge) as? Int ?? MIN_AGE
        self.filterAgeMax       = user.object(forKey: u_maxAge) as? Int ?? MAX_AGE
        self.filterGender       = user.object(forKey: u_interested) as? Int ?? 4
        self.filterLocationMin  = user.object(forKey: u_locationLimitMin) as? Int ?? MIN_LOCATION
        self.filterLocationMax  = user.object(forKey: u_locationLimit) as? Int ?? MAX_LOCATION
        self.filterHeightMin    = user.object(forKey: u_filterHeightMin) as? Int ?? MIN_HEIGHT
        self.filterHeightMax    = user.object(forKey: u_filterHeightMax) as? Int ?? MAX_HEIGHT
        self.filterCurRelation  = user.object(forKey: u_filterCurRelation) as? Int ?? 0
        self.filterKids         = user.object(forKey: u_filterKids) as? Int ?? 2
        self.filterDesiredRelation  = user.object(forKey: u_filterDesiredRelation) as? Int ?? 0
        self.filterReligion     = user.object(forKey: u_filterReligion) as? Int ?? -1
    }
}
