//
//  MotionContainer.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/16/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import CoreMotion
import UIKit
import simd

protocol MotionContainer {
    
    var motionManager: CMMotionManager? { get set }
    
    func startUpdateMotion()
    
    func stopUpdateMotion()
}

extension MotionContainer {

}
