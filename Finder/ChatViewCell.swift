//
//  ChatViewCell.swift
//  Finder
//
//  Created by djay mac on 02/02/15.
//  Copyright (c) 2015 DJay. All rights reserved.
//

import UIKit

class ChatViewCell: UITableViewCell {

    @IBOutlet weak var userdp           : UIImageView!
    @IBOutlet weak var nameUser         : UILabel!
    @IBOutlet weak var lastMessage      : UILabel!
    @IBOutlet weak var timeAgo          : UILabel!
    @IBOutlet weak var viewBadgeNewMsg  : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
