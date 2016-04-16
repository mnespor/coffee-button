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
    let sixteenOzLatte = 225

    var flooredSliderValue: Int {
        return Int(slider.value) - Int(slider.value % 5)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        slider.setThumbImage(UIImage(named: "bean"), forState: .Normal)
        let valueFromUserDefaults = NSUserDefaults.standardUserDefaults().integerForKey(milligramKey)
        slider.value = Float(valueFromUserDefaults > 0 ? valueFromUserDefaults : sixteenOzLatte)
        label.text = "\(flooredSliderValue)"
    }

    @IBAction func sliderDidSlide(sender: UISlider) {
        label.text = "\(flooredSliderValue)"
        NSUserDefaults.standardUserDefaults().setInteger(flooredSliderValue, forKey: milligramKey)
    }

    @IBAction func drink(sender: UIButton) {
        HealthManager.instance.saveCaffeineSample(Double(flooredSliderValue)) {
            NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                self?.warn()
            }
        }
    }

    private func warn() {
        let alert = UIAlertController(
            title: NSLocalizedString("main_view.cant_write.title", comment: "title"),
            message: NSLocalizedString("main_view.cant_write.message", comment: "message"),
            preferredStyle: .Alert
        )

        let cancel = UIAlertAction(
            title: NSLocalizedString("main_view.cant_write.cancel", comment: "cancel"),
            style: .Cancel,
            handler: nil
        )

        let settings = UIAlertAction(
            title: NSLocalizedString("main_view.cant_write.settings", comment: "settings"),
            style: .Default) { action in
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
        }

        alert.addAction(cancel)
        alert.addAction(settings)

        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

