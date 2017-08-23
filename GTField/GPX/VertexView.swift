//
//  VertexView.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 8/5/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

protocol VertexViewTouchDelegate:class {
    func touchBegan(touch:UITouch)
    func touchEnded(touch:UITouch)
    func touchMoved(touch:UITouch)
}

class VertexView: UIView {
    weak var delegate: VertexViewTouchDelegate?
    var origin: CGPoint {
        set(value) {
            center = value.applying(CGAffineTransform(translationX: 0, y: 36))
        }
        get {
            return center.applying(CGAffineTransform(translationX: 0, y: -36))
        }
    }
    
    init(origin: CGPoint) {
        
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 60, height: 96))
        self.origin = origin
        self.backgroundColor = UIColor.clear
        let imageView = UIImageView(image: #imageLiteral(resourceName: "activeVertex"))
        self.addSubview(imageView)
        self.isUserInteractionEnabled = true
        initGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first  {
            print("touchesBegan", touch.tapCount)
            self.delegate?.touchBegan(touch: touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first  {
            print("touchesMoved")
            self.delegate?.touchMoved(touch: touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first  {
            print("touchesEnded")
            self.delegate?.touchEnded(touch: touch)
        }
    }
    
    func initGestureRecognizers() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        panGR.cancelsTouchesInView = false
        addGestureRecognizer(panGR)
    }
    
    func didPan(_ panGR: UIPanGestureRecognizer) {
        
        self.superview!.bringSubview(toFront: self)
        
        var translation = panGR.translation(in: self)
        
        translation = translation.applying(self.transform)
        
        self.center.x += translation.x
        self.center.y += translation.y
        
        panGR.setTranslation(CGPoint.zero, in: self)
    }
    
//    override func draw(_ rect: CGRect) {
//        
//        // ======== Tạo đường tròn ngoài cùng fill =====
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 8, y: 8), radius: 8, startAngle: 0.0, endAngle:.pi*2, clockwise: true)
//        
//        let circleLayer = CAShapeLayer()
//        circleLayer.path = circlePath.cgPath
//        circleLayer.fillColor = UIColor(hue: 204.0/360.0, saturation: 65.0/100.0, brightness: 50.0/100.0, alpha: 1.0).cgColor
//        layer.addSublayer(circleLayer)
//        
//        // ======== Tạo đường tròn chồng lên =====
//        let circle1Path = UIBezierPath(arcCenter: CGPoint(x: 8, y: 8), radius: 5, startAngle: 0.0, endAngle:.pi*2, clockwise: true)
//        
//        let circle1Layer = CAShapeLayer()
//        circle1Layer.path = circle1Path.cgPath
//        circle1Layer.fillColor = UIColor.clear.cgColor
//        circle1Layer.strokeColor = UIColor.white.cgColor
//        circle1Layer.lineWidth = 3
//        layer.addSublayer(circle1Layer)
//    }
}
