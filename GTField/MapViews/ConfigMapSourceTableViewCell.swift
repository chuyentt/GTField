//
//  ConfigMapSourceTableViewCell.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/12/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

class ConfigMapSourceTableViewCell: UITableViewCell {

    @IBOutlet var imgCell: UIImageView!
    @IBOutlet var lblCellTitle: UILabel!
    @IBOutlet var lblCellSubtitle: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgCell.alpha = 0.9
        imgCell.clipsToBounds = true
        imgCell.layer.cornerRadius = 3
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
