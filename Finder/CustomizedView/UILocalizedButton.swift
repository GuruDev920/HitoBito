//
//  UILocalizedButton.swift
//  Finder
//
//  Created by Tai on 6/17/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit

class UILocalizedButton: UIButton {

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
