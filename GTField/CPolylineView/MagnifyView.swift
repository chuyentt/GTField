//
//  MagnifyView.swift
//  SwiftyDrawExample
//
//  Created by Chuyen Trung Tran on 1/24/18.
//  Copyright © 2018 Walzy. All rights reserved.
//

import UIKit

class MagnifyView: UIView {

    var viewToMagnify: UIView!
    var touchPoint: CGPoint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        // Set border color, border width and corner radius of the magnify view
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = frame.height / 2
        self.layer.masksToBounds = true
    }
    
    func setTouchPoint(pt: CGPoint) {
        touchPoint = pt
        self.center = CGPoint(x: pt.x, y: pt.y - frame.height)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: frame.width / 2, y: frame.height / 2 )
        context!.scaleBy(x: 1.5, y: 1.5) // 1.5 is the zoom scale
        context!.translateBy(x: -touchPoint.x, y: -touchPoint.y)
        self.viewToMagnify.layer.render(in: context!)
    }
}
