//
//  UILocalizedLabel.swift
//  Finder
//
//  Created by Tai on 6/15/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import UIKit

class UILocalizedLabel: UILabel {

    @IBInspectable var keyString: String = "" {
        didSet {
            self.text = NSLocalizedString(self.keyString, comment: self.commentString)
        }
    }
    
    @IBInspectable var commentString: String = "" {
        didSet {
            self.text = NSLocalizedString(self.keyString, comment: self.commentString)
        }
    }
}
