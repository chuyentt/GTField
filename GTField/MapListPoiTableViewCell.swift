//
//  by AppyStudio:
//
//  ------------------------------------------------------
//  CodeCanyon Page:
//  http://codecanyon.net/user/appystudio/portfolio
//
//  ChupaMobile Page:
//  http://www.chupamobile.com/author/AppyStudio
//
//  Facebook:
//  https://www.facebook.com/appystudionet/
//
//  ------------------------------------------------------
//  Copyright (c) 2016 Nicola Canali. All rights reserved.
//  https://www.facebook.com/nicolacanali
//  ------------------------------------------------------

import UIKit

class MapListPoiTableViewCell: UITableViewCell {

    @IBOutlet var imgPoi: UIImageView!
    @IBOutlet var lblPoiName: UILabel!
    @IBOutlet var lblPoiIdName: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgPoi.alpha = 0.9
        imgPoi.clipsToBounds = true
        imgPoi.layer.cornerRadius = 3

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
