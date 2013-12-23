//
//  Event.h
//  BolusC
//
//  Created by Uwe Petersen on 23.12.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * basalDosis;
@property (nonatomic, retain) NSNumber * bloodSugar;
@property (nonatomic, retain) NSNumber * bloodSugarGoal;
@property (nonatomic, retain) NSNumber * carb;
@property (nonatomic, retain) NSNumber * chu;
@property (nonatomic, retain) NSNumber * chuBolus;
@property (nonatomic, retain) NSNumber * chuFactor;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * correctionBolus;
@property (nonatomic, retain) NSNumber * correctionDivisor;
@property (nonatomic, retain) NSString * dayString;
@property (nonatomic, retain) NSNumber * energy;
@property (nonatomic, retain) NSNumber * fat;
@property (nonatomic, retain) NSNumber * fpu;
@property (nonatomic, retain) NSNumber * fpuBolus;
@property (nonatomic, retain) NSNumber * fpuFactor;
@property (nonatomic, retain) NSNumber * protein;
@property (nonatomic, retain) NSNumber * shortBolus;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * useBreadUnits;
@property (nonatomic, retain) NSNumber * weight;

@end
