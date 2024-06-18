//
//  Extensions.swift
//  Registration
//
//  Created by Xinyuan_Wang on 2023/8/20.
//

import Foundation
import UIKit

extension UIColor {
    convenience init?(hexString: String) {
        if (hexString.isEmpty) {
            return nil
        }
        var hexValueString = hexString
        if (hexString .hasPrefix("#")) {
            _ = hexValueString.removeFirst()
        }
        if (hexValueString.count == 6) {
            hexValueString.append("ff")
        }
        let scanner = Scanner(string: hexValueString)
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            self.init(hex: hexNumber)
            return
        }
        return nil
    }
    
    convenience init(hex: UInt64) {
        let r = CGFloat((hex & 0xff000000) >> 24) / 255
        let g = CGFloat((hex & 0x00ff0000) >> 16) / 255
        let b = CGFloat((hex & 0x0000ff00) >> 8) / 255
        let a = CGFloat(hex & 0x000000ff) / 255
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    var hexRepresentation: String? {
        if let c = self.cgColor.components {
            return String(format: "#%02x%02x%02xff", Int(c[0] * 255), Int(c[1] * 255), Int(c[2] * 255))
        }
        return nil
    }
}

extension String: DetailDescribable {
    
}
