//
//  Prefs.swift
//  CoffeeButton
//
//  Created by Matthew Nespor on 4/30/16.
//  Copyright © 2016 Matthew Nespor. All rights reserved.
//

import Foundation

class Prefs: NSObject {
    private static let milligramKey = "mg"
    private static let sixteenOzLatte = 220

    static var dose: Int {
        get {
            let valueFromDefaults = NSUserDefaults
                .standardUserDefaults()
                .integerForKey(milligramKey)

            if valueFromDefaults > 0 {
                return valueFromDefaults
            }

            return sixteenOzLatte
        }

        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: milligramKey)
        }
    }
}
