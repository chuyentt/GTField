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
    
    public override func awakeFromNib() {
        
        super.awakeFromNib()
        commonSetup()
    }
    
    class func designCodeView(nibNamed: String) -> UIView {
        return Bundle(for: self).loadNibNamed(nibNamed, owner: self, options: nil)![0] as! UIView
    }

    fileprivate func commonSetup() {
        basePointsPI = UIScreen.pixelsPerInch!/UIScreen.main.nativeScale
        // UIScreen.main.nativeScale là tỷ lệ vật lý (<= scale)
        // Lưu ý: Ví dụ đối với iPhone 6 Plus:
        // - Simulator thì UIScreen.main.scale và UIScreen.main.nativeScale đều = 3
        // - Thiết bị vật lý thì scale = 3.0 còn nativeScale = 2.60869565217391
        // Như vậy, việc đo thước cm trên simulator và thiết bị vật lý là khác nhau
        // Để đảm bảo đúng với thiết bị thật thì nên sử dụng nativeScale
        print(UIScreen.main.scale, UIScreen.main.nativeScale)
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
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
                
                for tickMark:CGFloat in stride(from: 0, through: screenHeight, by: linesDist) {
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
}

public extension GMSMapView {
    
    struct RulerBarViewConstants {
        // cần quản lý các tag cho đỡ bị trùng nhau
        static let Tag = 200
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
