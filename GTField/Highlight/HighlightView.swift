//
//  HighlightView.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/9/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import UIKit

public class HighlightView: UIView {
    
    @IBOutlet public weak var indicatorView: SpringView!
    
    override public func awakeFromNib() {
        let animation = CABasicAnimation()
        animation.keyPath = "transform.rotation.z"
        animation.fromValue = degreesToRadians(degrees: 0)
        animation.toValue = degreesToRadians(degrees: 360)
        animation.duration = 5
        animation.repeatCount = HUGE
        indicatorView.layer.add(animation, forKey: "")
    }
    
    class func designCodeHighlightView() -> UIView {
        
        return Bundle(for: self).loadNibNamed("HighlightView", owner: self, options: nil)![0] as! UIView
    }
}

public extension UIView {
    
    struct HighlightViewConstants {
        static let Tag = 1001
    }
    
    func showHighlight() {
        
        if self.viewWithTag(HighlightViewConstants.Tag) != nil {
            // If highight view is already found in current view hierachy, do nothing
            return
        }
        
        let highlightXibView = HighlightView.designCodeHighlightView()
        highlightXibView.frame = self.bounds
        highlightXibView.tag = HighlightViewConstants.Tag
        self.addSubview(highlightXibView)
        
        highlightXibView.alpha = 0
        SpringAnimation.spring(duration: 0.7, animations: {
            highlightXibView.alpha = 1
        })
    }
    
    func hideHighlight() {
        
        if let highlightXibView = self.viewWithTag(HighlightViewConstants.Tag) {
            highlightXibView.alpha = 1
            
            SpringAnimation.springWithCompletion(duration: 0.7, animations: {
                highlightXibView.alpha = 0
                highlightXibView.transform = CGAffineTransform(scaleX: 3, y: 3)
            }, completion: { (completed) -> Void in
                highlightXibView.removeFromSuperview()
            })
        }
    }
    
}
