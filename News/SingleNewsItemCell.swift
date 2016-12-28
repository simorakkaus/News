//
//  SingleNewsItemCell.swift
//  News
//
//  Created by Simo on 14.12.16.
//  Copyright © 2016 Simo. All rights reserved.
//

import UIKit

class SingleNewsItemCell: UITableViewCell {

    
    @IBOutlet weak var currentNewsItemImage: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var thumbUp: UILabel!
    @IBOutlet weak var thumbDown: UILabel!
    @IBOutlet weak var currentNewsItemTitle: UILabel!
    @IBOutlet weak var currentNewsItemDescription: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    
    
    var vidLink = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
