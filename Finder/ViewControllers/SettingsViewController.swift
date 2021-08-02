//
//  SettingsViewController.swift
//  Finder
//
//  Created by SuperDev on 28.05.2020.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit
import DLRadioButton
import RangeSeekSlider
import DropDown

class SettingsViewController: UIViewController {

    @IBOutlet weak var ageLimitSlider       : RangeSeekSlider!
    @IBOutlet weak var locationLimitSlider  : RangeSeekSlider!
    
    @IBOutlet weak var sliderHeight         : RangeSeekSlider!
    @IBOutlet weak var btnCurRelation       : UIButton!
    @IBOutlet weak var btnDesiredRelation   : UIButton!
    @IBOutlet weak var btnReligion          : UIButton!

    @IBOutlet var btnsGender    : [DLRadioButton]!
    @IBOutlet var btnsKids      : [DLRadioButton]!

    var postFiltersSet: (() -> ())?
    
    private var dropDownCurRelation     : DropDown!
    private var dropDownDesiredRelation : DropDown!
    private var dropDownReligion        : DropDown!

    private var curRelations        = [NSLocalizedString("Any", comment: ""), NSLocalizedString("Single", comment: "")]
    private var desiredRelations    = DESIRED_RELATIONSHIPS
    private var religions           = [L_IDONOTCARE] + RELIGIONS
    
    private var userFilterData          : UserFilterData!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userFilterData = UserFilterData(user: currentuser)
        self.createDropDownLists()

        self.initUI()
    }
    
    private func initUI() {
        
        locationLimitSlider.delegate = self
        sliderHeight.delegate = self
        
        ageLimitSlider.selectedMinValue = CGFloat(self.userFilterData.filterAgeMin)
        ageLimitSlider.selectedMaxValue = CGFloat(self.userFilterData.filterAgeMax)

        self.getNoYesBoth(radioBtns: self.btnsGender, value: self.userFilterData.filterGender)

        locationLimitSlider.selectedMinValue = CGFloat(self.userFilterData.filterLocationMin)
        locationLimitSlider.selectedMaxValue = CGFloat(self.userFilterData.filterLocationMax)
        
        sliderHeight.selectedMinValue = CGFloat(self.userFilterData.filterHeightMin)
        sliderHeight.selectedMaxValue = CGFloat(self.userFilterData.filterHeightMax)

        self.setCurRelation(curRelation: self.userFilterData.filterCurRelation)
        dropDownCurRelation.selectRow(self.userFilterData.filterCurRelation, scrollPosition: .bottom)

        self.setDesiredRelation(desiredRelation: self.userFilterData.filterDesiredRelation)
        dropDownDesiredRelation.selectRow(self.userFilterData.filterDesiredRelation, scrollPosition: .bottom)
        
        self.setReligion(religion: self.userFilterData.filterReligion)
        dropDownReligion.selectRow(self.userFilterData.filterReligion + 1, scrollPosition: .bottom)

        self.getNoYesBoth(radioBtns: self.btnsKids, value: self.userFilterData.filterKids)
    }
    
    private func setCurRelation(curRelation: Int) {
        self.userFilterData.filterCurRelation = curRelation
        btnCurRelation.setTitle(self.curRelations[curRelation], for: .normal)
    }
    
    private func setDesiredRelation(desiredRelation: Int) {
        self.userFilterData.filterDesiredRelation = desiredRelation
        btnDesiredRelation.setTitle(self.desiredRelations[desiredRelation], for: .normal)
    }

    private func setReligion(religion: Int) {
        self.userFilterData.filterReligion = religion
        btnReligion.setTitle(self.religions[religion + 1], for: .normal)
    }

    private func createDropDownLists() {
        dropDownCurRelation = DropDown()
        dropDownCurRelation.anchorView = self.btnCurRelation
        dropDownCurRelation.dataSource = self.curRelations
        dropDownCurRelation.selectionAction = { (index: Int, item: String) in
            self.setCurRelation(curRelation: index)
        }
        dropDownCurRelation.backgroundColor = .white

        dropDownDesiredRelation = DropDown()
        dropDownDesiredRelation.anchorView = self.btnDesiredRelation
        dropDownDesiredRelation.dataSource = self.desiredRelations
        dropDownDesiredRelation.selectionAction = { (index: Int, item: String) in
            self.setDesiredRelation(desiredRelation: index)
        }
        dropDownDesiredRelation.backgroundColor = .white

        dropDownReligion = DropDown()
        dropDownReligion.anchorView = self.btnReligion
        dropDownReligion.dataSource = self.religions
        dropDownReligion.selectionAction = { (index: Int, item: String) in
            self.setReligion(religion: index - 1)
        }
        dropDownReligion.backgroundColor = .white
    }
    
    @IBAction func onBtnCurRelation(_ sender: UIButton) {
        dropDownCurRelation.show()
    }
    
    @IBAction func onBtnDesiredRelation(_ sender: UIButton) {
        dropDownDesiredRelation.show()
    }

    @IBAction func onBtnReligion(_ sender: UIButton) {
        dropDownReligion.show()
    }
 
    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        currentuser?.setValue(Int(ageLimitSlider.selectedMinValue), forKey: u_minAge)  //[u_minAge] = Int(ageLimitSlider.selectedMinValue)
        currentuser?.setValue(Int(ageLimitSlider.selectedMaxValue), forKey: u_maxAge)  // [u_maxAge] = Int(ageLimitSlider.selectedMaxValue)

        self.setNoYesBoth(radioBtns: self.btnsGender, field: u_interested)
        
        currentuser?.setValue(Int(locationLimitSlider.selectedMinValue), forKey: u_locationLimitMin)  //[u_locationLimitMin] = Int(locationLimitSlider.selectedMinValue)
        currentuser?.setValue(Int(locationLimitSlider.selectedMaxValue), forKey: u_locationLimit)  //[u_locationLimit] = Int(locationLimitSlider.selectedMaxValue)
        
        currentuser?.setValue(Int(sliderHeight.selectedMinValue), forKey: u_filterHeightMin)  // [u_filterHeightMin] = Int(sliderHeight.selectedMinValue)
        currentuser?.setValue(Int(sliderHeight.selectedMaxValue), forKey: u_filterHeightMax)  // [u_filterHeightMax] = Int(sliderHeight.selectedMaxValue)

        currentuser?.setValue(self.userFilterData.filterCurRelation, forKey: u_filterCurRelation) //[u_filterCurRelation] = self.userFilterData.filterCurRelation
        currentuser?.setValue(self.userFilterData.filterDesiredRelation, forKey: u_filterDesiredRelation)  // [u_filterDesiredRelation] = self.userFilterData.filterDesiredRelation
        currentuser?.setValue(self.userFilterData.filterReligion, forKey: u_filterReligion)  // [u_filterReligion] = self.userFilterData.filterReligion

        self.setNoYesBoth(radioBtns: self.btnsKids, field: u_filterKids)

        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        saveUserInBackground(user: currentuser!) { (result) in
            if result {
                self.postFiltersSet?()
                self.navigationController?.popViewController(animated: true)
            }
        }
//        currentuser?.saveInBackground { (done, error) -> Void in
//             MBProgressHUD.hide(for: self.view, animated: true)
//            if error == nil {
//                self.postFiltersSet?()
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
    }

    private func getNoYesBoth(radioBtns: [DLRadioButton], value: Int) {
        for radioBtn in radioBtns {
            if radioBtn.tag == value {
                radioBtn.isSelected = true
                break
            }
        }
    }

    private func setNoYesBoth(radioBtns: [DLRadioButton], field: String) {
        for radioBtn in radioBtns {
            if radioBtn.isSelected {
                currentuser?.setValue(radioBtn.tag, forKey: field)  // [field] = radioBtn.tag
                break
            }
        }
    }
}

extension SettingsViewController: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        return sliderValueWithUnit(slider, value: minValue)
    }

    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        return sliderValueWithUnit(slider, value: maxValue)
    }
    
    private func sliderValueWithUnit(_ slider: RangeSeekSlider, value: CGFloat) -> String {
        var unit = ""
        if slider == self.locationLimitSlider {
            unit = "km"
        } else if slider == self.sliderHeight {
            unit = "cm"
        }
        return "\(Int(value)) \(unit)"
    }
}
