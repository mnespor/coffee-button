//
//  ViewController.swift
//  CoffeeButton
//
//  Created by Matthew Nespor on 4/13/16.
//  Copyright © 2016 Matthew Nespor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var slider: UISlider!
    let milligramKey = "mg"

    var flooredSliderValue: Int {
        return Int(slider.value) - Int(slider.value % 5)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        slider.value = Float(NSUserDefaults.standardUserDefaults().integerForKey(milligramKey))
        label.text = "\(flooredSliderValue)"
    }

    @IBAction func sliderDidSlide(sender: UISlider) {
        label.text = "\(flooredSliderValue)"
        NSUserDefaults.standardUserDefaults().setInteger(flooredSliderValue, forKey: milligramKey)
    }

    @IBAction func drink(sender: UIButton) {
        HealthManager.instance.saveCaffeineSample(Double(flooredSliderValue))
    }

    @IBAction func undo(sender: UIButton) {
        
    }
}

