//
//  HealthKitManager.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 4/19/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import HealthKit


class HealthKitManager {
    let healthKitStore = HKHealthStore()
    
    func readHealthData() -> (age : Int? , bloodType : HKBloodTypeObject?){
        var age : Int?
        var bloodType : HKBloodTypeObject?
        
        //Read Data
        do{
            let birthday = try healthKitStore.dateOfBirthComponents()
            bloodType = try healthKitStore.bloodType()
            
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            age = currentYear - birthday.year!
            
        }catch{}
        
        return (age, bloodType)
    }

    
        func readActiveCaloriesBurned(){
            let activeCaloriesBurned = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
    
            let query = HKSampleQuery(sampleType: activeCaloriesBurned, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                if let result = results?.last as? HKQuantitySample{
                    print("Active Calories => \(result.quantity)")
                }else{
                    print(error?.localizedDescription)
                }
            }
            healthKitStore.execute(query)
        }
    
        func readBasalEnergyBurned(){
            let basalCaloriesBurned = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!
    
            let query = HKSampleQuery(sampleType: basalCaloriesBurned, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                if let result = results?.last as? HKQuantitySample{
                    print("Basal Calories => \(result.quantity)")
                }else{
                    print(error?.localizedDescription)
                }
            }
            healthKitStore.execute(query)
        }
    
    
    func readDistanceWalkingRunning() -> Double{
        var value: Double = 0
        let distanceWalkingRunning = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        
        let date =  Date()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceWalkingRunning, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            if error != nil {
                print("something went wrong")
            } else if let quantity = statistics?.sumQuantity() {
                value = quantity.doubleValue(for: HKUnit.meter())
                //print("Distancia => \(value)")
            }
        }
        healthKitStore.execute(query)
        return value
    }
    
    func readSteps() -> Double{
        var value: Double = 0
        let steps = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        let date =  Date()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
            if error != nil {
                print("something went wrong")
            } else if let quantity = statistics?.sumQuantity() {
                value = quantity.doubleValue(for: HKUnit.count())
                //print("Pasos => \(value)")
            }
        }
        healthKitStore.execute(query)
        return value
    }
    
    func autorizarHealthKit(){
        let healtKitTypesToRead : Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        ]
        
        let healtKitTypesToWrite : Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
        
        if !HKHealthStore.isHealthDataAvailable(){
            print("Ocurrio un error al autorizar")
            return
        }
        
        healthKitStore.requestAuthorization(toShare: healtKitTypesToWrite, read: healtKitTypesToRead) { (success, error) in
            print("Se autorizo correctamente")
        }
    }
    
}

extension HKBloodType {
    
    var stringRepresentation: String {
        switch self {
        case .notSet: return "Unknown"
        case .aPositive: return "A+"
        case .aNegative: return "A-"
        case .bPositive: return "B+"
        case .bNegative: return "B-"
        case .abPositive: return "AB+"
        case .abNegative: return "AB-"
        case .oPositive: return "O+"
        case .oNegative: return "O-"
        }
    }
}
