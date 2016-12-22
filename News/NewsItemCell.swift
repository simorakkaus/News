//
//  NewsItemCell.swift
//  News
//
//  Created by Simo on 28.11.16.
//  Copyright © 2016 Simo. All rights reserved.
//

import UIKit

class NewsItemCell: UITableViewCell {
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemPubDate: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemImage.layer.borderWidth = 1
        itemImage.layer.borderColor = UIColor.clear.cgColor
        itemImage.layer.masksToBounds = false
        itemImage.layer.cornerRadius = 4
        itemImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
