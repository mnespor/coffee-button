//
//  InterfaceController.swift
//  Coffee Button Extension
//
//  Created by Matthew Nespor on 4/17/16.
//  Copyright © 2016 Matthew Nespor. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var picker: WKInterfacePicker!
    @IBOutlet weak var label: WKInterfaceLabel!

    let pickerValues = (1...50).map { $0 * 10 }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        picker.setItems(pickerValues.map { val in
            let item = WKPickerItem()
            item.title = "+\(val)mg"
            return item
        })

        if let index = pickerValues.indexOf(Prefs.dose) {
            picker.setSelectedItemIndex(index)
        } else {
            picker.setSelectedItemIndex(21)
        }

    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    @IBAction func buttonDidTap(sender: WKInterfaceButton) {
        HealthManager.instance.saveCaffeineSample(Double(Prefs.dose), withCompletion: nil)
    }

    @IBAction func pickerAction(index: Int) {
        Prefs.dose = pickerValues[index]
    }
}
