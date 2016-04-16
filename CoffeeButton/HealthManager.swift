//
//  HealthManager.swift
//  CoffeeButton
//
//  Created by Matthew Nespor on 4/15/16.
//  Copyright © 2016 Matthew Nespor. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager {
    static let instance = HealthManager()
    let store = HKHealthStore()

    private let milligramUnit = HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Milli)
    private let quantityType = HKQuantityType.quantityTypeForIdentifier(
        HKQuantityTypeIdentifierDietaryCaffeine
    )!

    var canWrite: Bool {
        return store.authorizationStatusForType(quantityType) == .SharingAuthorized
    }

    private init() {

    }

    func requestShareAuthorization(completion: ((Bool) -> Void)?) {
        let types: Set = [quantityType]
        store.requestAuthorizationToShareTypes(
            types,
            readTypes: nil) { [weak self] (didSucceed, error) in
                guard let sself = self else {
                    completion?(false)
                    return
                }

                completion?(sself.canWrite)
        }
    }

    func saveCaffeineSample(mg: Double, failure: (() -> Void)?) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard canWrite else {
            requestShareAuthorization { [weak self] canWrite in
                if canWrite {
                    self?.saveCaffeineSample(mg, failure: failure)
                } else {
                    failure?()
                }
            }

            return
        }

        let now = NSDate()
        let sample = HKQuantitySample(
            type: quantityType,
            quantity: HKQuantity(unit: milligramUnit, doubleValue: mg),
            startDate: now,
            endDate: now
        )

        store.saveObject(sample) { (didSucceed, error) in
            guard let
                error = error,
                code = HKErrorCode(rawValue: error.code) else
            {
                return
            }


            switch code {
            case HKErrorCode.ErrorAuthorizationNotDetermined:
                print("hello")
            //    self?.requestShareAuthorization()
            default:
                NSLog("%@", error.localizedDescription)
            }
        }
    }
}
