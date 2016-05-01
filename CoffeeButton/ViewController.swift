//
//  ViewController.swift
//  CoffeeButton
//
//  Created by Matthew Nespor on 4/13/16.
//  Copyright © 2016 Matthew Nespor. All rights reserved.
//

import UIKit
import SwiftDate

class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var slider: UISlider!

    var flooredSliderValue: Int {
        return Int(slider.value) - Int(slider.value % 10)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        slider.setThumbImage(UIImage(named: "bean"), forState: .Normal)
        slider.value = Float(Prefs.dose)
        label.text = "\(Prefs.dose)"
    }

    override func viewWillAppear(animated: Bool) {
        updateChart()
    }

    @IBAction func sliderDidSlide(sender: UISlider) {
        label.text = "\(flooredSliderValue)"
        Prefs.dose = flooredSliderValue
    }

    @IBAction func drink(sender: UIButton) {
        HealthManager.instance.saveCaffeineSample(Double(flooredSliderValue))
        { [weak self] succeeded, error in
            guard succeeded else {
                NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                    self?.warn()
                }

                return
            }

            self?.updateLabel()
        }
    }

    private func updateLabel() {

    }

//    private func configureChart() {
//
//    }

//    private func updateChart() {
//        let startOfHour = NSDate().startOf(.Hour)
//        let xs = (-1...11).map { startOfHour + $0.hours }
//        let ys = xs.map { date in
//            HealthManager
//                .instance
//                .approxBloodstreamCaffeine(atDate: date) { [weak self] amount in
//
//        }
//            let data = LineChartData(xVals: xs.map { $0.toString() }, dataSets: <#T##[IChartDataSet]?#>)
//    }

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

