//
//  ScaleBarView.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/10/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import GoogleMaps

public class ScaleBarView: UIView {
    private var defaultWidth: CGFloat = 100.0
    @IBOutlet weak var scaleBarKmConstant: NSLayoutConstraint!
    @IBOutlet weak var scaleBarMiConstant: NSLayoutConstraint!
    @IBOutlet weak var trailingViewKmConstant: NSLayoutConstraint!
    @IBOutlet weak var bottomViewKmConstant: NSLayoutConstraint!
    @IBOutlet weak var trailingViewMiConstant: NSLayoutConstraint!
    @IBOutlet weak var bottomViewMiConstant: NSLayoutConstraint!
    @IBOutlet weak var distanceLabelKm: UILabel!
    @IBOutlet weak var distanceLabelMi: UILabel!
    private var strokeTextAttributes:[NSAttributedStringKey : Any]?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        trailingViewKmConstant.constant = 150
        bottomViewKmConstant.constant = 16
        trailingViewMiConstant.constant = 150
        bottomViewMiConstant.constant = 16
        strokeTextAttributes = [
            NSAttributedStringKey.strokeColor : UIColor.white,
            NSAttributedStringKey.foregroundColor : UIColor.black,
            NSAttributedStringKey.strokeWidth : -5.0,
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 11)
        ]
    }
    
    class func designCodeScaleBarView() -> UIView {
        return Bundle(for: self).loadNibNamed("ScaleBarView", owner: self, options: nil)![0] as! UIView
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let mapView: GMSMapView = self.superview as? GMSMapView else { return }
        
        let projection = mapView.projection
        let screenWidth: CGFloat = defaultWidth//mapView.frame.width / 2
        let barWidth: CGFloat = defaultWidth//self.frame.width / 2
        
        self.scaleBarKmConstant.constant = scaledBarWidth(projection: projection, scaleWidth: barWidth, screenWidth: screenWidth, unit: LengthUnit.meter)
        let txtKm = roundedDistanceFormatted(projection: projection, scaleWidth: barWidth, screenWidth: screenWidth, unit: LengthUnit.meter)
        distanceLabelKm.attributedText = NSAttributedString(string: txtKm, attributes: strokeTextAttributes)
        
        self.scaleBarMiConstant.constant = scaledBarWidth(projection: projection, scaleWidth: barWidth, screenWidth: screenWidth, unit: LengthUnit.foot)
        
        let txtMi = roundedDistanceFormatted(projection: projection, scaleWidth: barWidth, screenWidth: screenWidth, unit: LengthUnit.foot)
        
        distanceLabelMi.attributedText = NSAttributedString(string: txtMi, attributes: strokeTextAttributes)
    }
    
    private func roundedDistanceFormatted(projection: GMSProjection, scaleWidth: CGFloat, screenWidth: CGFloat, unit: Unit) -> String {
        let latLngLeft = projection.visibleRegion().farLeft
        let latLngRight = projection.visibleRegion().farRight
        let screenDistance = latLngLeft.distance(from: latLngRight).meter().converted(unit).amount.floatValue
        let scaleDistance = scaleWidth/screenWidth * CGFloat(screenDistance)
        let roundedDistance = scaleDistance.roundAsDistance()
        return formatDistance(distance: roundedDistance, unit: unit)
    }
    
    private func scaledBarWidth(projection: GMSProjection, scaleWidth: CGFloat, screenWidth: CGFloat, unit: Unit) -> CGFloat {
        let latLngLeft = projection.visibleRegion().farLeft
        let latLngRight = projection.visibleRegion().farRight
        let screenDistance = latLngLeft.distance(from: latLngRight).meter().converted(unit).amount.floatValue
        let scaleDistance = scaleWidth/screenWidth * CGFloat(screenDistance)
        let roundedDistance = scaleDistance.roundAsDistance()
        let scaleRatio = CGFloat(roundedDistance) / CGFloat(screenDistance)
        let scaleBarWidth =  scaleWidth * scaleRatio
        return CGFloat(scaleBarWidth)
    }
    
    
    private func formatDistance(distance: Int, unit: Unit) -> String {
        if unit == LengthUnit.meter { // Km
            if distance < 1000 {
                return distance.meter().description
            } else {
                return (distance/1000).kilometer().description
            }
        } else { // Mi
            if distance < 5280 {
                return distance.foot().description
            } else {
                return (distance/5280).mile().description
            }
        }
    }
}

public extension GMSMapView {
    
    struct ScaleBarViewConstants {
        static let Tag = 100
    }
    
    public func updateScaleBar() {
        if let scaleBarXibView = self.viewWithTag(ScaleBarViewConstants.Tag) {
            scaleBarXibView.setNeedsLayout()
        }
    }
    
    public func showScaleBar() {
        // Kiểm tra nếu self là mapView
        
        if self.viewWithTag(ScaleBarViewConstants.Tag) != nil {
            // If highight view is already found in current view hierachy, do nothing
            return
        }
        
        let scaleBarXibView = ScaleBarView.designCodeScaleBarView()
        scaleBarXibView.frame = self.bounds
        scaleBarXibView.tag = ScaleBarViewConstants.Tag
        self.addSubview(scaleBarXibView)
        
        scaleBarXibView.alpha = 1
    }
    
    public func hideScaleBar() {
        if let scaleBarXibView = self.viewWithTag(ScaleBarViewConstants.Tag) {
            scaleBarXibView.alpha = 0
        }
    }
}

extension CLLocationCoordinate2D {
    func distance(from coordinate: CLLocationCoordinate2D) -> CGFloat {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        return CGFloat(location1.distance(from: location2))
    }
}

extension CGFloat {
    func roundAsDistance() -> Int {
        var roundedDistance = 1
        var i = 0;
        while (1 + pow(CGFloat(i % 3), 2)) * pow(10, floor(CGFloat(i / 3))) < self {
            roundedDistance =  Int(((1 + pow(CGFloat(i % 3), 2)) * pow(10, floor(CGFloat(i / 3)))))
            i+=1
        }
        return roundedDistance
    }
}

