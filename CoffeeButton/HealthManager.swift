//
//  HealthManager.swift
//  CoffeeButton
//
//  Created by Matthew Nespor on 4/15/16.
//  Copyright © 2016 Matthew Nespor. All rights reserved.
//

import Foundation
import HealthKit
import SwiftDate

class HealthManager {
    static let instance = HealthManager()
    let localSampleDefaultsKey = "caffeineSamples"
    let localSampleDateKey = "date"
    let localSampleDoseKey = "dose"
    let store = HKHealthStore()

    private static let milligramUnit = HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Milli)
    private static let quantityType = HKQuantityType.quantityTypeForIdentifier(
        HKQuantityTypeIdentifierDietaryCaffeine
    )!

    private let sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]

    var canWrite: Bool {
        return store.authorizationStatusForType(HealthManager.quantityType) == .SharingAuthorized
    }

    private init() {

    }

    func requestShareAuthorization(completion: ((Bool) -> Void)?) {
        let types: Set = [HealthManager.quantityType]
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


    func approxBloodstreamCaffeine(atDate date: NSDate, completion: (Double) -> Void) {
        fetchCaffeineSamples(24.hours.ago) { samples in
            guard let samples = samples else {
                completion(0)
                return
            }

            let amount = samples.reduce(0, combine: { (accumulator, sample) -> Double in
                guard let sample = sample as? HKQuantitySample else { return accumulator }
                return accumulator + HealthManager.residualCaffeine(atDate: date, sample: sample)
            })

            completion(amount)
        }
    }

    func totalCaffeineToday(completion: (Double) -> Void) {
        fetchCaffeineSamples(NSDate().startOf(.Day)) { samples in
            guard let samples = samples else { return }
            let amount = samples.reduce(0, combine: { (accumulator, sample) -> Double in
                guard let sample = sample as? HKQuantitySample else { return accumulator }
                return accumulator + sample
                    .quantity
                    .doubleValueForUnit(HealthManager.milligramUnit)
            })

            completion(amount)
        }
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
            type: HealthManager.quantityType,
            quantity: HKQuantity(unit: HealthManager.milligramUnit, doubleValue: mg),
            startDate: now,
            endDate: now
        )

        store.saveObject(sample) { succeeded, error in
            completion?(succeeded, error)
        }
    }

    private func fetchCaffeineSamples(starting: NSDate, completion: ([HKSample]?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let now = NSDate()
        let predicate = HKQuery.predicateForSamplesWithStartDate(
            starting,
            endDate: now,
            options: [.None])

        let query = HKSampleQuery(
            sampleType: HealthManager.quantityType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil) { (query, samples, error) in
                completion(samples)
        }

        store.executeQuery(query)
    }

    private static func residualCaffeine(atDate date: NSDate, sample: HKQuantitySample) -> Double {
        let t = date.timeIntervalSinceDate(sample.startDate) / 3600.0
        let halfLife = 4.5
        let quantity = sample.quantity.doubleValueForUnit(HealthManager.milligramUnit)
        let exponent = -1 * log(2) * (t / halfLife)
        return quantity * pow(M_E, exponent)
    }
}
