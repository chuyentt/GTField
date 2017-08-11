//
//  PhotoTableViewCell.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 8/9/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var lblPhotoName: UILabel!
    @IBOutlet var lblPhotoDate: UILabel!
    @IBOutlet var lblPhotoLocation: UILabel!
    @IBOutlet var lblPhotoSize: UILabel!
    @IBOutlet var lblPhotoAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        thumbnailView.alpha = 1.0
        thumbnailView.clipsToBounds = true
        thumbnailView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
