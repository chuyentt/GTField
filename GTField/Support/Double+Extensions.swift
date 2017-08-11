//
//  CGFloat+Extensions.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/12/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation
extension Double {
    func toString(_ fractionDigits:Int) -> String {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(for: self) ?? "\(self)"
    }
    
    func toDMSString(_ fractionDigits:Int) -> String {
        let sign = self > 0.0 ? "" : "-"
        var sec = fabs(self * 3600.0)
        sec = sec*pow(10, Double(fractionDigits))
        let second = sec.rounded()/pow(10, Double(fractionDigits))
        let d = Int(second / 3600)
        let m = abs(Int(second) % 3600) / 60
        let s = second - (Double(d) * 3600.0 + Double(m) * 60.0)
        return "\(sign)\(d)° \(m)' \(s.toString(fractionDigits))\""
    }
}
