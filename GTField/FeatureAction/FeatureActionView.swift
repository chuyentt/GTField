//
//  FeatureActionView.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 2/10/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import UIKit

public class FeatureActionView: SpringView, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    weak var headerImageView: UIView!

    override public func awakeFromNib() {
        
        super.awakeFromNib()
        commonSetup()
    }
    
    class func designCodeView(nibNamed: String) -> UIView {
        return Bundle(for: self).loadNibNamed(nibNamed, owner: self, options: nil)![0] as! UIView
    }
    
    fileprivate func commonSetup() {
        //setupParallaxHeader()
        tableView.register(UINib(nibName: "FeatureTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    public func setupParallaxHeader() {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Logo")
        imageView.contentMode = .scaleAspectFill

        headerImageView = imageView
        tableView.parallaxHeader.view = headerImageView
        tableView.parallaxHeader.height = 320
        tableView.parallaxHeader.minimumHeight = 0
        tableView.parallaxHeader.mode = .topFill
        tableView.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            print(parallaxHeader.progress)
        }
        tableView.tableHeaderView = segmentedControl
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeFromSuperview()
    }
    
    @IBAction func btnClose(_ sender: Any) {
        removeFromSuperview()
    }
    
    /*
     * UITableViewDataSource
     */
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
}

public extension GMSMapView {
    
    struct FeatureActionViewConstants {
        // cần quản lý các tag cho đỡ bị trùng nhau
        static let tag = 201
    }
    
    public func showFeatureAction(_ show: Bool) {
        // Tìm FeatureActionView
        if let featureActionXibView: FeatureActionView = self.viewWithTag(FeatureActionViewConstants.tag) as? FeatureActionView {
            // Nếu tồn tại
            //featureActionXibView.isShowRuler = show
            featureActionXibView.setNeedsLayout()
        } else {
            let featureActionXibView: FeatureActionView = FeatureActionView.designCodeView(nibNamed: "FeatureActionView") as! FeatureActionView
            featureActionXibView.frame = self.bounds
            featureActionXibView.tag = FeatureActionViewConstants.tag
            self.addSubview(featureActionXibView)
            featureActionXibView.setupParallaxHeader()
            //
            //featureActionXibView.isShowRuler = show
            featureActionXibView.setNeedsLayout()
        }
    }
}
