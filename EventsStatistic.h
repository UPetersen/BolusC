//
//  Events.h
//  BolusC
//
//  Created by Uwe Petersen on 06.01.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Event+Extensions.h"


@interface EventsStatistic : NSObject
-(id) initWithArrayOfEvents: (NSArray *) events;

@property (nonatomic, strong) NSNumber *bloodSugarAvg;
@property (nonatomic, strong) NSNumber *bloodSugarWeightedAvg;
@property (nonatomic, strong) NSNumber *bloodSugarMin;
@property (nonatomic, strong) NSNumber *bloodSugarMax;
@property (nonatomic, strong) NSNumber *hba1c;

@property (nonatomic, strong) NSNumber *chuDailyAvg;
@property (nonatomic, strong) NSNumber *chuFactorAvg;
@property (nonatomic, strong) NSNumber *effectiveChuFactorAvg;

@property (nonatomic, strong) NSNumber *fpuDailyAvg;
@property (nonatomic, strong) NSNumber *fpuFactorAvg;
@property (nonatomic, strong) NSNumber *effectiveFpuFactorAvg;

@property (nonatomic, strong) NSNumber *insulinDailyAvg;
@property (nonatomic, strong) NSNumber *shortBolusDailyAvg;
@property (nonatomic, strong) NSNumber *chuBolusDailyAvg;
@property (nonatomic, strong) NSNumber *fpuBolusDailyAvg;
@property (nonatomic, strong) NSNumber *basalDosisDailyAvg;

@property (nonatomic, strong) NSNumber *energyDailyAvg;
@property (nonatomic, strong) NSNumber *numberOfBloodSugarMeasurementsDailyAvg;
@property (nonatomic, strong) NSNumber *weightAvg;


@property (nonatomic, strong) NSDate *firstDay;
@property (nonatomic, strong) NSDate *lastDay;
@property (nonatomic) NSInteger numberOfDays;
@property (nonatomic) NSUInteger numberOfEntries;

-(NSArray *) arrayOfEventsForNumberOfConsecutiveDays: (NSInteger) days;

@end
