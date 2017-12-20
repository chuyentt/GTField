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
        return "\(sign)\(d)°\(m)'\(s.toString(fractionDigits))\""
    }

    func areaUnit() -> String {
        switch getAreaUnit() {
        case 0:
            return self.squareMeter().rounded(3).description
        case 1:
            return self.squareMeter().converted(squareKilometer().unit).rounded(3).description
        case 2:
            return self.squareMeter().converted(hectare().unit).rounded(3).description
        case 3:
            return self.squareMeter().converted(squareYard().unit).rounded(3).description
        case 4:
            return self.squareMeter().converted(squareMile().unit).rounded(3).description
        case 5:
            return self.squareMeter().converted(acre().unit).rounded(3).description
        default:
            break
        }
        return toString(3)
    }
    
    func distanceUnit() -> String {
        switch getDistanceUnit() {
        case 0:
            return self.meter().rounded(3).description
        case 1:
            return self.meter().converted(kilometer().unit).rounded(3).description
        case 2:
            return self.meter().converted(yard().unit).rounded(3).description
        case 3:
            return self.meter().converted(mile().unit).rounded(3).description
        default:
            break
        }
        return toString(3)
    }
    
    func courseUnit() -> String {
        if self < 0.0 {
            return NSLocalizedString("Unknown", comment: "")
        } else {
            return "\(self.toString(1))°"
        }
    }
    
    func speedUnit() -> String {
        if self < 0.0 {
            return NSLocalizedString("Unknown", comment: "")
        } else {
            return "\(self.toString(1)) m/s"
        }
    }
}
