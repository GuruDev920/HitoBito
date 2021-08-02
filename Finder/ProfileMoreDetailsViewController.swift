//
//  ProfileMoreDetailsViewController.swift
//  Finder
//
//  Created by Tai on 6/15/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit

class ProfileMoreDetailsViewController: UIViewController {

    @IBOutlet weak var lblFullName          : UILabel!
    @IBOutlet weak var lblAge               : UILabel!
    @IBOutlet weak var lblGender            : UILabel!
    @IBOutlet weak var lblLocation          : UILabel!
    @IBOutlet weak var lblDistance          : UILabel!
    @IBOutlet weak var lblHeight            : UILabel!
    @IBOutlet weak var lblCurRelation       : UILabel!
    @IBOutlet weak var lblKids              : UILabel!
    @IBOutlet weak var lblDesiredRelation   : UILabel!
    @IBOutlet weak var lblJob               : UILabel!
    @IBOutlet weak var lblReligion          : UILabel!

    var user            : NSDictionary?
    private var userData: UserData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userData = UserData(user: user)
        
        self.initUI()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.tapOnView))
        self.view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Global_ShowFrostGlass(self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Global_HideFrostGlass()
    }

    private func initUI() {
        self.lblFullName.text       = self.userData.fname
        self.lblAge.text            = "\(self.userData.age)"
        self.lblGender.text         = GENDERS[self.userData.gender - 1]
        self.lblLocation.text       = self.userData.locationText ?? ""
        
        self.lblDistance.text = "\(calcDistanceInKm(from: currentuser, to: userData.location)) km"
        
//        self.lblDistance.text       = calcDistanceInKm(from: currentuser?.object(forKey: u_location) as? PFGeoPoint, to: userData.location)
        self.lblHeight.text         = "\(self.userData.height) cm"
        self.lblCurRelation.text    = CUR_RELATIONSHIPS[self.userData.curRelation]
        self.lblKids.text           = self.userData.hasKids ? L_YES : L_NO
        self.lblDesiredRelation.text = DESIRED_RELATIONSHIPS[self.userData.desiredRelation]
        self.lblJob.text            = self.userData.job
        self.lblReligion.text       = RELIGIONS[self.userData.religion]
    }
    
    @objc func tapOnView(sender : UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
