//
//  DLLocalizedRadioButton.swift
//  Finder
//
//  Created by Tai on 6/15/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit
import DLRadioButton

class DLLocalizedRadioButton: DLRadioButton {

    @IBInspectable var keyString: String = "" {
        didSet {
            self.setTitle(NSLocalizedString(self.keyString, comment: self.commentString), for: .normal)
        }
    }
    
    @IBInspectable var commentString: String = "" {
        didSet {
            self.setTitle(NSLocalizedString(self.keyString, comment: self.commentString), for: .normal)
        }
    }
}
