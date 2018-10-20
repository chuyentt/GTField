//
//  RulerBarView.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/12/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import UIKit

public class RulerBarView: UIView {
    private var basePointsPI: CGFloat = 154.0
    public var isShowRuler: Bool = true
    private var strokeTextAttributes = [
        NSAttributedString.Key.strokeColor : UIColor.white,
        NSAttributedString.Key.foregroundColor : UIColor.black,
        NSAttributedString.Key.strokeWidth : -5.0,
        NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 11)
        ] as [NSAttributedString.Key : Any]
    private var coordinateLabelStrokeTextAttributes = [
        NSAttributedString.Key.strokeColor : UIColor.white,
        NSAttributedString.Key.foregroundColor : UIColor.orange,
        NSAttributedString.Key.strokeWidth : -4.0,
        NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)
        ] as [NSAttributedString.Key : Any]
    @IBOutlet weak var scaleLabel: UILabel!
    @IBOutlet weak var scaleLabelBottomConstant: NSLayoutConstraint!
    
    @IBOutlet weak var coordinateLabelVerticalSpaceConstant: NSLayoutConstraint!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var crossLine: UIImageView!
    @IBOutlet weak var mapFrameVerticalSpaceConstant: NSLayoutConstraint!
    
    public override func awakeFromNib() {
        
        super.awakeFromNib()
        commonSetup()
    }
    
    class func designCodeView(nibNamed: String) -> UIView {
        return Bundle(for: self).loadNibNamed(nibNamed, owner: self, options: nil)![0] as! UIView
    }

    fileprivate func commonSetup() {
        basePointsPI = UIScreen.pixelsPerInch!/UIScreen.main.nativeScale
        scaleLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        let unit = getDistanceUnit()
        switch unit {
        case 0, 1:
            scaleLabelBottomConstant.constant = CGFloat((basePointsPI/25.4)*15)
        default:
            scaleLabelBottomConstant.constant = CGFloat(basePointsPI/2)
        }

        crossLine.isHidden = !ENABLE_MAP_CENTER_COORDINATE
        coordinateLabel.isHidden = !ENABLE_MAP_CENTER_COORDINATE
        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .right
        
        // UIScreen.main.nativeScale là tỷ lệ vật lý (<= scale)
        // Lưu ý: Ví dụ đối với iPhone 6 Plus:
        // - Simulator thì UIScreen.main.scale và UIScreen.main.nativeScale đều = 3
        // - Thiết bị vật lý thì scale = 3.0 còn nativeScale = 2.60869565217391
        // Như vậy, việc đo thước cm trên simulator và thiết bị vật lý là khác nhau
        // Để đảm bảo đúng với thiết bị thật thì nên sử dụng nativeScale
        print(UIScreen.main.scale, UIScreen.main.nativeScale)
        
        
    }
    
    // Cập nhật nhãn 1 đơn vị thước đo bằng số đơn vị thực tế
    // Giống như tỷ lệ bản đồ
    public func updateScaleLabel() {
        guard let mapView: GMSMapView = self.superview as? GMSMapView else { return }
        if isShowRuler {
            let unit = getDistanceUnit()
            switch unit {
            case 0, 1:
                let scaleDist: CGFloat = getDistanceInOneCentimeter(mapView)
                var scaleText: String = ""
                if scaleDist < 1000.0 {
                    scaleText = "1 cm ≈ " + Double(scaleDist).toString(1) + " m"
                } else {
                    scaleText = "1 cm ≈ " + Double(scaleDist/1000.0).toString(1) + " km"
                }
                scaleLabel.attributedText = NSAttributedString(
                    string: scaleText,
                    attributes: strokeTextAttributes)
            default:
                let scaleDist: CGFloat = getDistanceInOneInch(mapView)
                var scaleText: String = ""
                if scaleDist < 5280 {
                    scaleText = "1 inch ≈ " + Double(scaleDist).toString(1) + " ft"
                } else {
                    scaleText = "1 inch ≈ " + Double(scaleDist/5280).toString(1) + " mi"
                }
                scaleLabel.attributedText = NSAttributedString(
                    string: scaleText,
                    attributes: strokeTextAttributes)
            }
        }
        
        // Cập nhật tọa độ tâm bản đồ
        let mapCenter = crossLine.center
        self.coordinateLabel.attributedText = NSMutableAttributedString(string: mapView.projection.coordinate(for: mapCenter).latLngFormated(withTarget: true), attributes: coordinateLabelStrokeTextAttributes)
    }
    
    public func hideCoordinateLabel(_ hidden: Bool) {
        if ENABLE_MAP_CENTER_COORDINATE {
            coordinateLabel.isHidden = hidden
        }
    }
    
    public func showCrossMarker(_ show: Bool) {
        if show {
            crossLine.showHighlight()
        } else {
            crossLine.hideHighlight()
        }
    }
        
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        mapFrameVerticalSpaceConstant.constant = UIApplication.shared.statusBarFrame.height
        coordinateLabelVerticalSpaceConstant.constant = UIApplication.shared.statusBarFrame.height + 54
        if isShowRuler {
            let unit = getDistanceUnit()
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            var count:Int = 0
            switch unit {
            case 0, 1:
                let linesDist: CGFloat = (basePointsPI/25.4) // 1 ppi = 25.4 mm per inch
                let linesWidthShort: CGFloat = 2.0
                let linesWidthMedium: CGFloat = 5.0
                let linesWidthLong: CGFloat = 8.0
                
                // Vẽ ruler dọc
                for tickMark:CGFloat in stride(from: screenHeight, through: 0, by: -linesDist) {
                    let linesWidth = (count % 10 == 0) ? linesWidthLong : (count % 5 == 0) ? linesWidthMedium : linesWidthShort
                    let fillColor = (count % 10 == 0) ? UIColor.darkGray : (count % 5 == 0) ? UIColor.gray : UIColor.lightGray
                    fillColor.setFill()
                    
                    // trái
                    UIRectFill(CGRect(x: 0.0, y: tickMark, width: linesWidth, height: 1.0))
                    
                    // phải
                    UIRectFill(CGRect(x: screenWidth, y: tickMark, width: -linesWidth, height: 1.0))
                    count += 1
                }
                
                count = 0
                // Vẽ ruler ngang
                for tickMark:CGFloat in stride(from: 0, through: screenWidth, by: linesDist) {
                    let linesWidth = (count % 10 == 0) ? linesWidthLong : (count % 5 == 0) ? linesWidthMedium : linesWidthShort
                    let fillColor = (count % 10 == 0) ? UIColor.darkGray : (count % 5 == 0) ? UIColor.gray : UIColor.lightGray
                    fillColor.setFill()
                    
                    // dưới
                    UIRectFill(CGRect(x: tickMark, y: screenHeight, width: 1.0, height: -linesWidth))
                    
                    // trên
                    UIRectFill(CGRect(x: tickMark, y: 0.0, width: 1.0, height: linesWidth))
                    count += 1
                }
                break
            default:
                let linesDist: CGFloat = basePointsPI/16.0
                let linesSixteenthInch: CGFloat = 2.0
                let linesEighthInch: CGFloat = 4.0
                let linesQuarterInch: CGFloat = 4.0
                let linesHalfInch: CGFloat = 6.0
                let linesFullInch: CGFloat = 8.0
                
                for tickMark:CGFloat in stride(from: screenHeight, through: 0, by: -linesDist) {
                    let linesWidth = (count % 16 == 0) ? linesFullInch : (count % 8 == 0) ? linesHalfInch : (count % 4 == 0) ? linesQuarterInch : (count % 2 == 0) ? linesEighthInch : linesSixteenthInch
                    let fillColor = (count % 16 == 0) ? UIColor.brown : (count % 8 == 0) ? UIColor.darkGray : (count % 4 == 0) ? UIColor.gray : (count % 2 == 0) ? UIColor.lightGray : UIColor.lightGray
                    fillColor.setFill()
                    
                    // trái
                    UIRectFill(CGRect(x: 0.0, y: tickMark, width: linesWidth, height: 1.0))
                    
                    // phải
                    UIRectFill(CGRect(x: screenWidth, y: tickMark, width: -linesWidth, height: 1.0))
                    count += 1
                }
                count = 0
                for tickMark:CGFloat in stride(from: 0, through: screenWidth, by: linesDist) {
                    let linesWidth = (count % 16 == 0) ? linesFullInch : (count % 8 == 0) ? linesHalfInch : (count % 4 == 0) ? linesQuarterInch : (count % 2 == 0) ? linesEighthInch : linesSixteenthInch
                    let fillColor = (count % 16 == 0) ? UIColor.darkGray : (count % 8 == 0) ? UIColor.gray : (count % 4 == 0) ? UIColor.lightGray : (count % 2 == 0) ? UIColor.lightGray : UIColor.lightGray
                    fillColor.setFill()
                    
                    // dưới
                    UIRectFill(CGRect(x: tickMark, y: screenHeight, width: 1.0, height: -linesWidth))
                    
                    // trên
                    UIRectFill(CGRect(x: tickMark, y: 0.0, width: 1.0, height: linesWidth))
                    count += 1
                }
                break
            }
            
        }
    }
    
    private func getDistanceInOneCentimeter(_ mapView: GMSMapView) -> CGFloat {
        let centerPoint = mapView.center
        let centerLatLng = mapView.projection.coordinate(for: centerPoint)
        var rightPoint = centerPoint
        rightPoint.x += (basePointsPI/25.4) * 10.0 // 1cm
        let latLngRight = mapView.projection.coordinate(for: rightPoint)
        let screenDistance = centerLatLng.distance(from: latLngRight)
        return screenDistance
    }
    
    private func getDistanceInOneInch(_ mapView: GMSMapView) -> CGFloat {
        let centerPoint = mapView.center
        let centerLatLng = mapView.projection.coordinate(for: centerPoint)
        var rightPoint = centerPoint
        rightPoint.x += basePointsPI
        let latLngRight = mapView.projection.coordinate(for: rightPoint)
        let screenDistance = centerLatLng.distance(from: latLngRight)
        return CGFloat(screenDistance.meter().converted(LengthUnit.foot).amount.floatValue)
    }
}

public extension GMSMapView {
    
    struct RulerBarViewConstants {
        // cần quản lý các tag cho đỡ bị trùng nhau
        static let Tag = 200
    }
    
    public func updateRulerBarLabel() {
        if let rulerBarXibView: RulerBarView = self.viewWithTag(RulerBarViewConstants.Tag) as? RulerBarView {
            // Nếu tồn tại
            rulerBarXibView.updateScaleLabel()
        }
    }
    
    public func hideCoordinateLabel(_ hidden: Bool) {
        if let rulerBarXibView: RulerBarView = self.viewWithTag(RulerBarViewConstants.Tag) as? RulerBarView {
            rulerBarXibView.hideCoordinateLabel(hidden)
        }
    }
    
    public func getFixedMapCenter() -> CGPoint {
        if let rulerBarXibView: RulerBarView = self.viewWithTag(RulerBarViewConstants.Tag) as? RulerBarView {
            return rulerBarXibView.crossLine.center
        }
        return self.center
    }
    
    public func showCrossMarker(_ show: Bool) {
        if let rulerBarXibView: RulerBarView = self.viewWithTag(RulerBarViewConstants.Tag) as? RulerBarView {
            rulerBarXibView.showCrossMarker(show)
        }
    }
    
    public func showRulerBar(_ show: Bool) {
        // Tìm RulerBarView
        if let rulerBarXibView: RulerBarView = self.viewWithTag(RulerBarViewConstants.Tag) as? RulerBarView {
            // Nếu tồn tại
            rulerBarXibView.isShowRuler = show
            rulerBarXibView.setNeedsLayout()
        } else {
            let rulerBarXibView: RulerBarView = RulerBarView.designCodeView(nibNamed: "RulerBarView") as! RulerBarView
            rulerBarXibView.frame = self.bounds
            rulerBarXibView.tag = RulerBarViewConstants.Tag
            self.addSubview(rulerBarXibView)
            rulerBarXibView.isShowRuler = show
            rulerBarXibView.setNeedsLayout()
        }
    }
}
