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
    private var basePointsPI: CGFloat = 154.0
    private var defaultWidth: CGFloat = 279
    private var defaultScaleBarConstant: CGFloat = 30
    @IBOutlet weak var scaleBarKmConstant: NSLayoutConstraint!
    @IBOutlet weak var scaleBarMiConstant: NSLayoutConstraint!
    @IBOutlet weak var trailingViewKmConstant: NSLayoutConstraint!
    @IBOutlet weak var bottomViewKmConstant: NSLayoutConstraint!
    @IBOutlet weak var trailingViewMiConstant: NSLayoutConstraint!
    @IBOutlet weak var bottomViewMiConstant: NSLayoutConstraint!
    @IBOutlet weak var distanceLabelKm: UILabel!
    @IBOutlet weak var distanceLabelMi: UILabel!
    @IBOutlet weak var zoomLevelLabel: UILabel!
    private var strokeTextAttributes:[NSAttributedStringKey : Any]?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        basePointsPI = UIScreen.pixelsPerInch!/UIScreen.main.nativeScale
        // defaultScaleBarConstant => thước = 0
        // (basePointsPI/25.4) * 5 => thước = 0.5cm
        scaleBarKmConstant.constant = defaultScaleBarConstant
        scaleBarMiConstant.constant = defaultScaleBarConstant
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
        
        let barWidth: CGFloat = (basePointsPI/25.4)*15.0 // Kích thước nhỏ nhất 15mm
        //km: 5, 10, 20,50,100,200,500,1,2,5,10,20,50,100,200,500,1000,2000
        //mi: 20, 50, 100,200,500,1000,2000,1,2,5,10,20,50,100,200,500,1000
        
        self.scaleBarKmConstant.constant = defaultScaleBarConstant + scaledBarWidth(mapView, barWidth, LengthUnit.meter)
        let txtKm = roundedDistanceFormatted(mapView, barWidth, LengthUnit.meter)
        distanceLabelKm.attributedText = NSAttributedString(string: txtKm, attributes: strokeTextAttributes)
        
        self.scaleBarMiConstant.constant = defaultScaleBarConstant + scaledBarWidth(mapView, barWidth, LengthUnit.foot)
        
        let txtMi = roundedDistanceFormatted(mapView, barWidth, LengthUnit.foot)
        
        distanceLabelMi.attributedText = NSAttributedString(string: txtMi, attributes: strokeTextAttributes)
        
        let zoomLevel = Double(mapView.camera.zoom)
        zoomLevelLabel.attributedText = NSAttributedString(string: zoomLevel.toString(1), attributes: strokeTextAttributes)
        // z:
        //zoomLevelLabel.attributedText = NSAttributedString(string: getDistanceInOneCentimeter(mapView).formatMapScaleLabel(unit: LengthUnit.meter), attributes: strokeTextAttributes)
    }
    
    private func roundedDistanceFormatted(_ mapView: GMSMapView,_ scaleWidth: CGFloat,_ unit: Unit) -> String {
        let centerPoint = mapView.center
        let centerLatLng = mapView.projection.coordinate(for: centerPoint)
        var rightPoint = centerPoint
        rightPoint.x += scaleWidth
        let latLngRight = mapView.projection.coordinate(for: rightPoint)
        let screenDistance = centerLatLng.distance(from: latLngRight).meter().converted(unit).amount.floatValue
        return CGFloat(screenDistance).formatMapScaleLabel(unit: unit)
    }
    
    private func scaledBarWidth(_ mapView: GMSMapView,_ scaleWidth: CGFloat,_ unit: Unit) -> CGFloat {
        let centerPoint = mapView.center
        let centerLatLng = mapView.projection.coordinate(for: centerPoint)
        var rightPoint = centerPoint
        rightPoint.x += scaleWidth
        let latLngRight = mapView.projection.coordinate(for: rightPoint)
        let screenDistance = centerLatLng.distance(from: latLngRight).meter().converted(unit).amount.floatValue
        let roundedDistance = CGFloat(screenDistance).roundAsDistance()
        let scaleRatio = CGFloat(roundedDistance) / CGFloat(screenDistance)
        let scaleBarWidth =  scaleWidth * scaleRatio
        return CGFloat(scaleBarWidth)
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
    
    func formatMapScaleLabel(unit: Unit) -> String {
        let distance = self.roundAsDistance()
        if unit == LengthUnit.meter { // Km <-> m
            if distance < 1000 {
                return distance.meter().description
            } else {
                let distance = (self/1000).roundAsDistance()
                return (distance).kilometer().description
            }
        } else { // Mi <-> Yard
            if distance < 5000 {
                return distance.foot().description
            } else {
                let distance = (self/5280).roundAsDistance()
                return (distance).mile().description
            }
        }
    }
}

