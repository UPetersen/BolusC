//
//  Events.m
//  BolusC
//
//  Created by Uwe Petersen on 06.01.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

#import "EventsStatistic.h"
#import "Event.h"
#import "Event+Extensions.h"
#import "NSCalendar+mySpecialCalculations.h"

@interface EventsStatistic()

@property (nonatomic, strong) NSArray *events;
//@property (nonatomic, strong) NSNumber *chuSum;
//@property (nonatomic, strong) NSNumber *fpuSum;
//@property (nonatomic, strong) NSNumber *energySum;
@property (nonatomic, strong) NSNumber *shortBolusSum;
@property (nonatomic, strong) NSNumber *correctionBolusSum;
@property (nonatomic, strong) NSNumber *chuBolusSum;
@property (nonatomic, strong) NSNumber *fpuBolusSum;
@property (nonatomic, strong) NSNumber *basalDosisSum;
@property (nonatomic, strong) NSNumber *insulinSum;

@property (nonatomic) NSInteger bloodSugarMeasurementsCount;

@end

@implementation EventsStatistic

-(id) init {
    self = [super init];
    
    NSLog(@"Error in Events.m (init): use designated initializer, i.e. initWithArrayOfEvents:");
    NSLog(@"App will now be aborted");

    abort();
    
    return self;
}

-(id) initWithArrayOfEvents:(NSArray *)events {
    self = [super init];
    
    self.events = [[NSArray alloc] initWithArray:events];
    
    self.firstDay = [self.events valueForKeyPath:@"@min.timeStamp"];
    self.lastDay  = [self.events valueForKeyPath:@"@max.timeStamp"];
    
    self.bloodSugarMin = [self.events valueForKeyPath:@"@min.bloodSugar"];
    self.bloodSugarMax = [self.events valueForKeyPath:@"@max.bloodSugar"];
    
//    self.correctionBolusSum = [self.events valueForKeyPath:@"@sum.correctionBolus"];
//    self.shortBolusSum      = [self.events valueForKeyPath:@"@sum.shortBolus"];
//    self.chuBolusSum        = [self.events valueForKeyPath:@"@sum.chuBolus"];
//    self.fpuBolusSum        = [self.events valueForKeyPath:@"@sum.fpuBolus"];
//    self.basalDosisSum      = [self.events valueForKeyPath:@"@sum.basalDosis"];
//    self.insulinSum = [NSNumber numberWithFloat:[self.shortBolusSum floatValue] + [self.fpuBolusSum floatValue] + [self.basalDosisSum floatValue]];

//    if (self.numberOfDays > 0) {
//        self.correctionBolusDailyAvg = [NSNumber numberWithFloat:[self.correctionBolusSum floatValue] / (CGFloat)self.numberOfDays];
//        self.shortBolusDailyAvg      = [NSNumber numberWithFloat:[self.shortBolusSum      floatValue] / (CGFloat)self.numberOfDays];
//        self.chuBolusDailyAvg        = [NSNumber numberWithFloat:[self.chuBolusSum        floatValue] / (CGFloat)self.numberOfDays];
//        self.fpuBolusDailyAvg        = [NSNumber numberWithFloat:[self.fpuBolusSum        floatValue] / (CGFloat)self.numberOfDays];
//        self.basalDosisDailyAvg      = [NSNumber numberWithFloat:[self.basalDosisSum      floatValue] / (CGFloat)self.numberOfDays];
//        self.insulinDailyAvg         = [NSNumber numberWithFloat:[self.insulinSum         floatValue] / (CGFloat)self.numberOfDays];
//    }

    return self;
}
-(NSNumber *) insulinDailyAvg {
    if (!_insulinDailyAvg && self.numberOfDays > 0) {
        _insulinDailyAvg = [NSNumber numberWithFloat: ([self.shortBolusSum floatValue] + [self.fpuBolusSum floatValue] + [self.basalDosisSum floatValue]) / (CGFloat) self.numberOfDays];
    }
    return _insulinDailyAvg;
}

-(NSNumber *) shortBolusSum {
    if (!_shortBolusSum) {
        _shortBolusSum = [self.events valueForKeyPath:@"@sum.shortBolus"];
    }
    return _shortBolusSum;
}
-(NSNumber *) shortBolusDailyAvg {
    if (!_shortBolusDailyAvg) {
        if (self.numberOfDays > 0) {
            _shortBolusDailyAvg = [NSNumber numberWithFloat: self.shortBolusSum.floatValue / (CGFloat) self.numberOfDays];
        }
    }
    return _shortBolusDailyAvg;
}

-(NSNumber *) chuBolusSum {
    if (!_chuBolusSum) {
        _chuBolusSum = [self.events valueForKeyPath:@"@sum.chuBolus"];
    }
    return _chuBolusSum;
}
-(NSNumber *) chuBolusDailyAvg {
    if (!_chuBolusDailyAvg) {
        if (self.numberOfDays > 0) {
            _chuBolusDailyAvg = [NSNumber numberWithFloat: self.chuBolusSum.floatValue / (CGFloat) self.numberOfDays];
        }
    }
    return _chuBolusDailyAvg;
}

-(NSNumber *) basalDosisSum {
    if (!_basalDosisSum) {
        _basalDosisSum = [self.events valueForKeyPath:@"@sum.basalDosis"];
    }
    return _basalDosisSum;
}
-(NSNumber *) basalDosisDailyAvg {
    if (!_basalDosisDailyAvg) {
        if (self.numberOfDays > 0) {
            _basalDosisDailyAvg = [NSNumber numberWithFloat: self.basalDosisSum.floatValue / (CGFloat) self.numberOfDays];
        }
    }
    return _basalDosisDailyAvg;
}

-(NSNumber *) fpuBolusSum {
    if (!_fpuBolusSum) {
        _fpuBolusSum = [self.events valueForKeyPath:@"@sum.fpuBolus"];
    }
    return _fpuBolusSum;
}
-(NSNumber *) fpuBolusDailyAvg {
    if (!_fpuBolusDailyAvg) {
        if (self.numberOfDays > 0) {
            _fpuBolusDailyAvg = [NSNumber numberWithFloat: self.fpuBolusSum.floatValue / (CGFloat) self.numberOfDays];
        }
    }
    return _fpuBolusDailyAvg;
}

-(NSNumber *) correctionBolusDailyAvg {
    if (!_correctionBolusDailyAvg) {
        NSNumber *sum = [self.events valueForKeyPath:@"@sum.correctionBolus"];
        if (self.numberOfDays > 0) {
            _correctionBolusDailyAvg = [NSNumber numberWithFloat: sum.floatValue / (CGFloat) self.numberOfDays];
        }
    }
    return _correctionBolusDailyAvg;
}
-(NSNumber *) positiveCorrectionBolusDailyAvg {
    if (!_positiveCorrectionBolusDailyAvg) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"correctionBolus > 0"];
        NSArray *eventsWithNonNilValues = [self.events filteredArrayUsingPredicate:predicate];
        NSNumber *sum = [eventsWithNonNilValues valueForKeyPath:@"@sum.correctionBolus"];
        if (self.numberOfDays > 0) {
            _positiveCorrectionBolusDailyAvg = [NSNumber numberWithFloat:sum.floatValue / (CGFloat) self.numberOfDays];
        }
    }
    return _positiveCorrectionBolusDailyAvg;
}
-(NSNumber *) negativeCorrectionBolusDailyAvg {
    if (!_negativeCorrectionBolusDailyAvg) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"correctionBolus < 0"];
        NSArray *eventsWithNonNilValues = [self.events filteredArrayUsingPredicate:predicate];
        NSNumber *sum = [eventsWithNonNilValues valueForKeyPath:@"@sum.correctionBolus"];
        if (self.numberOfDays > 0) {
            _negativeCorrectionBolusDailyAvg = [NSNumber numberWithFloat:sum.floatValue / (CGFloat) self.numberOfDays];
        }
    }
    return _negativeCorrectionBolusDailyAvg;
}

-(NSNumber *) daysWithCommentsContainingSport {
    if (!_daysWithCommentsContainingSport) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"comment contains[c] 'Sport'"]; // [c] for case insensitive search
        NSArray *eventsWithNonNilValues = [self.events filteredArrayUsingPredicate:predicate];
        _daysWithCommentsContainingSport = [NSNumber numberWithInteger:eventsWithNonNilValues.count];
    }
    return _daysWithCommentsContainingSport;
}

-(NSInteger) numberOfDays {
    if (!_numberOfDays) {
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//        [gregorianCalendar setTimeZone:[NSTimeZone localTimeZone]];

        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:self.firstDay
                                                              toDate:self.lastDay
                                                             options:0];
        _numberOfDays = [components day]+1;
        
   }
    return _numberOfDays;
}

-(NSArray *) arrayOfEventsForNumberOfConsecutiveDays: (NSInteger) days {
    

    NSMutableArray *arrayOfEventArrays = [[NSMutableArray alloc] init];
    
    // For comparisson get the date for 0:00 hours one day after the last day of the events. I.e. if the last entry in the events was today 13:45 hours, then get tomorrow 0:00 hours.
    //NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    // TODO: prüfen, ob das raus kann.
//    [calendar setTimeZone:[NSTimeZone localTimeZone]];
//    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *components = [calendar components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.lastDay];
    components.day++; // Add one day
    NSDate *lastDay = [calendar dateFromComponents:components];  // Next day 0:00 hours
    

    //  create date component with number of days that reflect the intervall of n days, e.g. -7 days for the intervall of seven days
    NSDateComponents *componentsDays = [[NSDateComponents alloc] init];
    componentsDays.day = -days;
    
    
//    NSTimeInterval timeInterval = -days * 24.0 * 3600.0;  // The time intervall, defining the unit of events to be
    NSDate *firstDay; // = [NSDate dateWithTimeInterval:timeInterval sinceDate: lastDay];

    // TODO: noch sortieren nach Zeit, absteigend
    while ([self.firstDay compare: lastDay] == NSOrderedAscending) {
        
        // Get all events between firstDay and lastDay
//        firstDay = [NSDate dateWithTimeInterval: timeInterval sinceDate: lastDay];
        firstDay = [calendar dateByAddingComponents:componentsDays toDate:lastDay options:0];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(timeStamp >= %@) AND (timeStamp < %@)", firstDay, lastDay];
        NSLog(@"firstDayOf.. und lastDayOf.. %@, %@, %ld", firstDay, lastDay, (long) days);
        
        // Get all events that lie within that time intervall and store this array in the output array of this method
        NSArray *eventsInTimeIntervall = [self.events filteredArrayUsingPredicate:predicate];
        [arrayOfEventArrays addObject:eventsInTimeIntervall];
        
        // Prepare for next intervall
        lastDay = firstDay;
        
    }
    return arrayOfEventArrays;
}

-(NSUInteger) numberOfEntries {
    if (!_numberOfEntries) {
        _numberOfEntries = self.events.count;
    }
    return _numberOfEntries;
}


-(NSNumber *) hba1c {
    /*
    Berechnungsvorschriften für HBA1C:
    1.) Nach Wikipedia:
        a) HbA1c [%] = (Mittlerer Blutzucker [mg/dl] + 86) / 33,3
        b) HbA1c [%] = (Mittlerer Blutzucker [mg/dl] + 77,3) / 35,6
    2.) Nach "http://www.med4you.at/laborbefunde/lbef2/lbef_hba1c.htm":
        Durchschnittlicher Blutzuckerspiegel(in mg/dl) = 28.7 x HbA1c (%) - 46.7
    */
    NSLog(@"bloodSugarWeightedAvg und bloodSugarMin: %@, %@", self.bloodSugarWeightedAvg, self.bloodSugarMin);
    
    if (!_hba1c && ([self.bloodSugarWeightedAvg doubleValue] >= [self.bloodSugarMin doubleValue] && self.bloodSugarWeightedAvg.doubleValue >=1)) {
        _hba1c = [NSNumber numberWithDouble: ([self.bloodSugarWeightedAvg doubleValue] + 86.0) / 33.3 ];
    }
    return _hba1c;
}

-(NSNumber *) bloodSugarWeightedAvg {
    if (!_bloodSugarWeightedAvg) {
        // Only use Events with blood sugar measurements
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bloodSugar > 0"];
        NSArray *eventsWithNonNilBloodSugar = [self.events filteredArrayUsingPredicate:predicate];

        if (!eventsWithNonNilBloodSugar.count) {
            // return nil, if no event found with blood sugar values
            return _bloodSugarWeightedAvg;
        } else if (eventsWithNonNilBloodSugar.count == 1) {
            // if only one value is given, i.e. there is one event, return the blood sugar value of this event
            _bloodSugarWeightedAvg = [[eventsWithNonNilBloodSugar objectAtIndex:0] bloodSugar];
            return _bloodSugarWeightedAvg;
        }
        
        NSTimeInterval tDelta, tOverallDelta; // is double
        tOverallDelta = [[[eventsWithNonNilBloodSugar lastObject]  timeStamp] timeIntervalSince1970 ]
                      - [[[eventsWithNonNilBloodSugar firstObject] timeStamp] timeIntervalSince1970 ];
        
        // Loop over all Events (i.e. timeIntervalls)
        double bloodSugarWeightedAvg = 0.0;
        for (NSUInteger i=0; i < eventsWithNonNilBloodSugar.count - 1; i++) {

            tDelta = [[[eventsWithNonNilBloodSugar objectAtIndex:i+1] timeStamp] timeIntervalSince1970 ]
                   - [[[eventsWithNonNilBloodSugar objectAtIndex:i]   timeStamp] timeIntervalSince1970 ];
            
            bloodSugarWeightedAvg += 0.5 * ( [[[eventsWithNonNilBloodSugar objectAtIndex:i]  bloodSugar] doubleValue] +
                                            [[[eventsWithNonNilBloodSugar objectAtIndex:i+1] bloodSugar] doubleValue] ) * (double) tDelta;
        }
        
        // Calculation is possible, if there are at least two values and thus one tDelta (the case of two values is handled above)
        if (tOverallDelta !=0) {
            bloodSugarWeightedAvg = bloodSugarWeightedAvg / tOverallDelta;
            _bloodSugarWeightedAvg = [NSNumber numberWithDouble: bloodSugarWeightedAvg ];
        }
    }
    return _bloodSugarWeightedAvg;
}

-(NSInteger) bloodSugarMeasurementsCount {

    if (!_bloodSugarMeasurementsCount) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bloodSugar > 0"];
        NSArray *eventsWithNonNilValues = [self.events filteredArrayUsingPredicate:predicate];
        _bloodSugarMeasurementsCount = eventsWithNonNilValues.count;
    }
    return _bloodSugarMeasurementsCount;
}
-(NSNumber *) numberOfBloodSugarMeasurementsPerDay {
    if (!_numberOfBloodSugarMeasurementsPerDay && self.numberOfDays >= 1) {
        _numberOfBloodSugarMeasurementsPerDay = [NSNumber numberWithFloat:(CGFloat) self.bloodSugarMeasurementsCount / (CGFloat) self.numberOfDays];
    }
    return _numberOfBloodSugarMeasurementsPerDay;
}

-(NSNumber *) numberOfInjectionsPerDay {
    if (!_numberOfInjectionsPerDay) {
        _numberOfInjectionsPerDay = [NSNumber numberWithFloat: self.numberOfShortBolusInjectionsPerDay.floatValue + self.numberOfFpuBolusInjectionsPerDay.floatValue + self.numberOfBasalDosisInjectionsPerDay.floatValue];
    }
    return _numberOfInjectionsPerDay;
}

-(NSNumber *) numberOfEntriesPerDay {
    if (!_numberOfEntriesPerDay) {
        _numberOfEntriesPerDay = [NSNumber numberWithFloat: (CGFloat) self.numberOfEntries / (CGFloat) self.numberOfDays];
    }
    return _numberOfEntriesPerDay;
}

-(NSNumber *) numberOfBasalDosisInjectionsPerDay {
    if (!_numberOfBasalDosisInjectionsPerDay) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"basalDosis > 0"];
        NSArray *eventsWithNonNilValues = [self.events filteredArrayUsingPredicate:predicate];
        _numberOfBasalDosisInjectionsPerDay = [NSNumber numberWithFloat: (CGFloat) eventsWithNonNilValues.count / (CGFloat) self.numberOfDays];
    }
    return _numberOfBasalDosisInjectionsPerDay;
}
-(NSNumber *) numberOfFpuBolusInjectionsPerDay {
    if (!_numberOfFpuBolusInjectionsPerDay) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fpuBolus > 0"];
        NSArray *eventsWithNonNilValues = [self.events filteredArrayUsingPredicate:predicate];
        _numberOfFpuBolusInjectionsPerDay = [NSNumber numberWithFloat: (CGFloat) eventsWithNonNilValues.count / (CGFloat) self.numberOfDays];
    }
    return _numberOfFpuBolusInjectionsPerDay;
}
-(NSNumber *) numberOfShortBolusInjectionsPerDay {
    if (!_numberOfShortBolusInjectionsPerDay) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortBolus > 0"];
        NSArray *eventsWithNonNilValues = [self.events filteredArrayUsingPredicate:predicate];
        _numberOfShortBolusInjectionsPerDay = [NSNumber numberWithFloat: (CGFloat) eventsWithNonNilValues.count / (CGFloat) self.numberOfDays];
    }
    return _numberOfShortBolusInjectionsPerDay;
}

-(NSNumber *) chuDailyAvg {
    if (!_chuDailyAvg && self.numberOfDays > 0) {
        NSNumber *chuSum = [self.events valueForKeyPath:@"@sum.chu"];
        _chuDailyAvg = [NSNumber numberWithFloat:[chuSum floatValue]/ (CGFloat) self.numberOfDays];
    }
    return _chuDailyAvg;
}
-(NSNumber *) fpuDailyAvg {
    if (!_fpuDailyAvg && self.numberOfDays > 0) {
        NSNumber *fpuSum = [self.events valueForKeyPath:@"@sum.fpu"];
        _fpuDailyAvg = [NSNumber numberWithFloat:[fpuSum floatValue]/ (CGFloat) self.numberOfDays];
    }
    return _fpuDailyAvg;
}

-(NSNumber *) chuFactorAvg {
    if (!_chuFactorAvg) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chuFactor > 0"];
        NSArray *eventsWithNonNilValues = [self.events filteredArrayUsingPredicate:predicate];
        _chuFactorAvg = [eventsWithNonNilValues valueForKeyPath:@"@avg.chuFactor"];
    }
    return _chuFactorAvg;
}
-(NSNumber *) fpuFactorAvg {
    if (!_fpuFactorAvg) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fpuFactor > 0"];
        NSArray *eventsWithNonNilValues = [self.events filteredArrayUsingPredicate:predicate];
        _fpuFactorAvg = [eventsWithNonNilValues valueForKeyPath:@"@avg.fpuFactor"];
    }
    return _fpuFactorAvg;
}
-(NSNumber *) energyDailyAvg {
    if (!_energyDailyAvg) {
        NSNumber *sum = [self.events valueForKeyPath:@"@sum.energy"];
        _energyDailyAvg = [NSNumber numberWithFloat:[sum floatValue] / (CGFloat) self.numberOfDays];
    }
    return _energyDailyAvg;
}
-(NSNumber *) carbsPerDay {
    if (!_carbsPerDay) {
        NSNumber *sum = [self.events valueForKeyPath:@"@sum.carb"];
        _carbsPerDay = [NSNumber numberWithFloat:[sum floatValue] / (CGFloat) self.numberOfDays];
    }
    return _carbsPerDay;
}
-(NSNumber *) fatPerDay {
    if (!_fatPerDay) {
        NSNumber *sum = [self.events valueForKeyPath:@"@sum.fat"];
        _fatPerDay = [NSNumber numberWithFloat:[sum floatValue] / (CGFloat) self.numberOfDays];
    }
    return _fatPerDay;
}
-(NSNumber *) proteinPerDay {
    if (!_proteinPerDay) {
        NSNumber *sum = [self.events valueForKeyPath:@"@sum.protein"];
        _proteinPerDay = [NSNumber numberWithFloat:[sum floatValue] / (CGFloat) self.numberOfDays];
    }
    return _proteinPerDay;
}


-(NSNumber *) effectiveChuFactorAvg {
    if (!_effectiveChuFactorAvg) {
        if (self.chuDailyAvg) {
            _effectiveChuFactorAvg = [NSNumber numberWithDouble:[self.shortBolusDailyAvg doubleValue] / [self.chuDailyAvg doubleValue]];
        }
    }
    return _effectiveChuFactorAvg;
}
-(NSNumber *) effectiveFpuFactorAvg {
    if (!_effectiveFpuFactorAvg) {
        _effectiveFpuFactorAvg = [NSNumber numberWithDouble:[self.fpuBolusDailyAvg doubleValue] / [self.fpuDailyAvg doubleValue]];
    }
    return _effectiveFpuFactorAvg;
}


-(NSNumber *) bloodSugarAvg {
    if (!_bloodSugarAvg) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bloodSugar > 0"];
        NSArray *eventsWithNonNilBloodSugar = [self.events filteredArrayUsingPredicate:predicate];
        _bloodSugarAvg = [eventsWithNonNilBloodSugar valueForKeyPath:@"@avg.bloodSugar"];
    }
    return _bloodSugarAvg;
}



@end
