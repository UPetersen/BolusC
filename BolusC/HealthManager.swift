//
//  HealthManager.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import Foundation
import HealthKit
import CoreData
//import Timepiece

//@objc public class HealthManager: NSObject {
class HealthManager: NSObject {

    let healthKitStore:HKHealthStore = HKHealthStore()
    
    @objc public func authorizeHealthKit(completion: ((_ success: Bool, _ error: NSError?) -> Void)?) {
        //        return
        //    }
        //  func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
        //  {
        
        // 1. and 2. Set the types you want to share and read from HK Store
        let healthKitSampleTypesToShare = [
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKQuantityType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.quantityType(forIdentifier: .bloodGlucose),
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed),
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates),
            HKObjectType.quantityType(forIdentifier: .dietaryProtein),
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)
            ]
            .compactMap{$0 as HKSampleType?}
        
        let healthKitObjectTypesToRead = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            HKObjectType.characteristicType(forIdentifier: .bloodType),
            HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            HKObjectType.quantityType(forIdentifier: .bodyMass),
            HKObjectType.quantityType(forIdentifier: .height),
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.quantityType(forIdentifier: .bloodGlucose),
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed),
            HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates),
            HKObjectType.quantityType(forIdentifier: .dietaryProtein),
            HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)
            ]
            .compactMap{$0 as HKObjectType?}
        
        let healthKitTypesToShare: Set? = Set<HKSampleType>(healthKitSampleTypesToShare)
        let healthKitTypesToRead: Set?  = Set<HKObjectType>(healthKitObjectTypesToRead)
        
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable(){
            let error = NSError(domain: "UPP.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if (completion != nil) {
                //        completion(success: false, error: error)
                completion!(false, error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        //    healthKitStore.requestAuthorizationToShareTypes(Set(healthKitTypesToWrite), readTypes: Set(healthKitTypesToRead)) { (success, error) -> Void in
        healthKitStore.requestAuthorization(toShare: healthKitTypesToShare, read: healthKitTypesToRead) { (success, error) -> Void in
            if (completion != nil), let error = error {
                //                if (completion != nil) {
                //        completion(success:success,error:error)
                completion!(success, error as NSError)
            }
        }
    }
    
    
    @objc public func readNutrientData (date: NSDate, completion: ((HKCorrelation?, NSError?) -> Void)!) {
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("HealthKit is not available in this Device")
            return
        }
        
        //        let sampleType = HKSampleType.correlationTypeForIdentifier(HKCorrelationTypeIdentifierFood)
        guard let sampleType = HKSampleType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food) else {
            fatalError("Wrong identifier for food correlation")
        }
        //        let options = HKQueryOptions.None
        let options = HKQueryOptions()
        
        let startDate = NSDate(timeInterval: -60.0*5.0, since: date as Date)
        let endDate = NSDate(timeInterval: 60.0*5.0, since: date as Date)
        
        
        //        let predicate = HKQuery.predicateForSamplesWithStartDate(date, endDate: date, options: options)
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date, options: options)
        print("The predicate is \(predicate)")
        print("start date is \(startDate) and end date is \(endDate)")
        
        // query with completion handler (wherein another completion handler is called
        //        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler:
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler:
        { (sampleQuery, results, error ) -> Void in
            
            print("Bin drin")
            if let queryError = error {
                print( "There was an error while reading the samples: \(queryError.localizedDescription)")
                completion(nil, error as NSError?)
            }
            
            if let results = results {
                let foodCorrelations = results
                    .compactMap{$0 as? HKCorrelation}
                    .filter {$0.correlationType == HKCorrelationType.correlationType(forIdentifier: .food)! as HKCorrelationType}
                
                if foodCorrelations.count > 1 {
                    print("Number of food correlation objects is \(foodCorrelations.count), which is greater than one, which should not happen.")
                    print("Aborting program. Please check and correct your database, Uwe.")
                    abort()
                }
                
                for foodCorrelation in foodCorrelations {
                    print("About to call completion")
                    
                    completion(foodCorrelation, nil)
                    print("... done with call to completion")
                }
            }
        })
        // 5. Execute the Query
        self.healthKitStore.execute(sampleQuery)
    }
    
}
