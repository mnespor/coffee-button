//
//  HealthManager.swift
//  CoffeeButton
//
//  Created by Matthew Nespor on 4/15/16.
//  Copyright © 2016 Matthew Nespor. All rights reserved.
//

import Foundation
import HealthKit

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

    func fetchTodaysCaffeine() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        NSDate().startOf
        let yesterday = NSDate().dateByAddingTimeInterval(negativeDay)
                let predicate = HKQuery.predicateForSamplesWithStartDate(yesterday,
//                                                                 endDate: NSDate(),
//                                                                 options: <#T##HKQueryOptions#>)
//        let query = HKSampleQuery(
//            sampleType: quantityType,
//                                  predicate: HK
//                                  limit: <#T##Int#>, sortDescriptors: <#T##[NSSortDescriptor]?#>, resultsHandler: <#T##(HKSampleQuery, [HKSample]?, NSError?) -> Void#>)
//        store.executeQuery(<#T##query: HKQuery##HKQuery#>)
    }

    func saveCaffeineSample(mg: Double, withCompletion completion: ((Bool, ErrorType?) -> Void)?) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard canWrite else {
            requestShareAuthorization { [weak self] canWrite in
                if canWrite {
                    self?.saveCaffeineSample(mg, withCompletion: completion)
                } else {
                    completion?(false, nil)
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

        store.saveObject(sample) { succeeded, error in
            completion?(succeeded, error)
        }
    }
}
