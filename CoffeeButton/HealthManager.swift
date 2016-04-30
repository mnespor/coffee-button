//
//  HealthManager.swift
//  CoffeeButton
//
//  Created by Matthew Nespor on 4/15/16.
//  Copyright © 2016 Matthew Nespor. All rights reserved.
//

import UIKit
import HealthKit
import SwiftDate

class HealthManager {
    static let instance = HealthManager()
    let localSampleDefaultsKey = "caffeineSamples"
    let localSampleDateKey = "date"
    let localSampleDoseKey = "dose"
    let store = HKHealthStore()

    private let milligramUnit = HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Milli)
    private let quantityType = HKQuantityType.quantityTypeForIdentifier(
        HKQuantityTypeIdentifierDietaryCaffeine
    )!

    private let sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]

    var canWrite: Bool {
        return store.authorizationStatusForType(quantityType) == .SharingAuthorized
    }

    private init() {

    }

    func requestShareAuthorization(completion: ((Bool) -> Void)?) {
        let types: Set = [quantityType]
        store.requestAuthorizationToShareTypes(
            types,
            readTypes: types) { [weak self] (didSucceed, error) in
            guard let sself = self else {
                completion?(false)
                return
            }

            completion?(sself.canWrite)
        }
    }

    func fetchCaffeineSamples() {
//        guard HKHealthStore.isHealthDataAvailable() else { return }
//        let predicate = HKQuery.predicateForSamplesWithStartDate(24.hours.ago,
//                                                                 endDate: NSDate(),
//                                                                 options: <#T##HKQueryOptions#>)
//        let query = HKSampleQuery(
//            sampleType: quantityType,
//                                  predicate: HK
//                                  limit: <#T##Int#>, sortDescriptors: <#T##[NSSortDescriptor]?#>, resultsHandler: <#T##(HKSampleQuery, [HKSample]?, NSError?) -> Void#>)
//        store.executeQuery(<#T##query: HKQuery##HKQuery#>)
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
            guard let error = error else { return }
            NSLog("%@", error.localizedDescription)
        }
    }
}
