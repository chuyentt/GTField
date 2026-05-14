//
//  PointView.swift
//  SwiftyDrawExample
//
//  Created by Chuyen Trung Tran on 1/24/18.
//  Copyright © 2018 Walzy. All rights reserved.
//

import UIKit

// Chế độ hiển thị đỉnh, điểm giữa
enum PointMode: Int {
    case normal     // Trạng thái thông thường của đỉnh ở chế độ polyline editing
    case editing    // Trạng thái được chọn của đỉnh ở chế độ polyline editing
    case midpoint   // Điểm giữa ở chế độ polyline editing
    case moving     // Trạng thái đang di chuyển
}

// Các sự kiện về đỉnh, điểm giữa
protocol PointViewDelegate: AnyObject {
    // Sự kiện chạm down
    func pointTouchBegan(touch:UITouch)
    // Sự kiện chạm drag
    func pointTouchMoved(touch:UITouch)
    // Sự kiện chạm up
    func pointTouchEnded(touch:UITouch)
}


class PointView: UIView {

    weak var delegate: PointViewDelegate?
    private var iconView: UIImageView = UIImageView(image:#imageLiteral(resourceName: "Vertex"))
    
    var pointMode: PointMode = PointMode.normal {
        didSet(prevValue){
            if prevValue != pointMode {
                switch pointMode {
                case .normal:
                    iconView.image = #imageLiteral(resourceName: "Vertex")
                    iconView.hideHighlight()
                case .editing:
                    iconView.image = #imageLiteral(resourceName: "EditingVertex")
                    iconView.showHighlight()
                case .midpoint:
                    iconView.image = #imageLiteral(resourceName: "Midpoint")
                case .moving:
                    iconView.image = #imageLiteral(resourceName: "MovingVertex")
                    iconView.showHighlight()
                }
            }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.frame = iconView.frame
        self.addSubview(iconView)
        self.isUserInteractionEnabled = true
        // Khởi tạo nhận dạng đa điểm
        initGestureRecognizers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first  {
            print("Point touches Began", touch.tapCount)
            self.delegate?.pointTouchBegan(touch: touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first  {
            print("Point touches Moved")
            self.delegate?.pointTouchMoved(touch: touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first  {
            print("Point touches Ended")
            self.delegate?.pointTouchEnded(touch: touch)
        }
    }
    
    func initGestureRecognizers() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        panGR.cancelsTouchesInView = false
        addGestureRecognizer(panGR)
    }
    
    @objc func didPan(_ panGR: UIPanGestureRecognizer) {
        guard self.pointMode == .moving else {
            return
        }
        self.superview!.bringSubviewToFront(self)
        
        var translation = panGR.translation(in: self)
        
        translation = translation.applying(self.transform)
        
        self.center.x += translation.x
        self.center.y += translation.y
        
        panGR.setTranslation(CGPoint.zero, in: self)
    }

}

