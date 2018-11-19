//
//  MagnifyView.swift
//  SwiftyDrawExample
//
//  Created by Chuyen Trung Tran on 1/24/18.
//  Copyright © 2018 Walzy. All rights reserved.
//

import UIKit
import QuartzCore

class MagnifyView: UIView {

    public var viewToMagnify: UIView!
    public var touchPoint: CGPoint! {
        didSet {
            self.center = CGPoint(x: touchPoint.x, y: touchPoint.y - frame.height/2)
        }
    }
    
    public var scale: CGFloat = 2.0
    
    required public convenience init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0 // =3 sau khi fix xong
        self.layer.cornerRadius = frame.size.width / 2
        self.layer.masksToBounds = true
        self.viewToMagnify = nil
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: self.frame.size.width/2, y: self.frame.size.height/2)
        context.scaleBy(x: self.scale, y: self.scale)
        context.translateBy(x: -self.touchPoint.x, y: -self.touchPoint.y)
        
        // TODO: Chưa fix được lỗi này [Unknown process name] CGImageCreate: invalid image alphaInfo: kCGImageAlphaNone. It should be kCGImageAlphaNoneSkipLast
        //self.viewToMagnify.layer.render(in: context)
        print(self.viewToMagnify.layer)
    }
}
