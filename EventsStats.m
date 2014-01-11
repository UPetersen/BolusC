//
//  Events.m
//  BolusC
//
//  Created by Uwe Petersen on 06.01.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

#import "EventsStats.h"
#import "Event.h"
#import "Event+Extensions.h"
#import "NSCalendar+mySpecialCalculations.h"

@interface EventsStats()

@property (nonatomic, strong) NSArray *events;
//@property (nonatomic, strong) NSNumber *chuSum;
//@property (nonatomic, strong) NSNumber *fpuSum;
//@property (nonatomic, strong) NSNumber *energySum;
@property (nonatomic, strong) NSNumber *shortBolusSum;
@property (nonatomic, strong) NSNumber *chuBolusSum;
@property (nonatomic, strong) NSNumber *fpuBolusSum;
@property (nonatomic, strong) NSNumber *basalDosisSum;
@property (nonatomic, strong) NSNumber *insulinSum;

@property (nonatomic) NSInteger bloodSugarMeasurementsCount;

@end

@implementation EventsStats

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
    self.lastDay = [self.events valueForKeyPath:@"@max.timeStamp"];
    
    self.bloodSugarMin = [self.events valueForKeyPath:@"@min.bloodSugar"];
    self.bloodSugarMax = [self.events valueForKeyPath:@"@max.bloodSugar"];
    
    self.shortBolusSum = [self.events valueForKeyPath:@"@sum.shortBolus"];
    self.chuBolusSum = [self.events valueForKeyPath:@"@sum.chuBolus"];
    self.fpuBolusSum = [self.events valueForKeyPath:@"@sum.fpuBolus"];
    self.basalDosisSum = [self.events valueForKeyPath:@"@sum.basalDosis"];
    self.insulinSum = [NSNumber numberWithFloat:[self.shortBolusSum floatValue] + [self.fpuBolusSum floatValue] + [self.basalDosisSum floatValue]];

    if (self.numberOfDays > 0) {
        self.shortBolusDailyAvg = [NSNumber numberWithFloat:[self.shortBolusSum floatValue] / (CGFloat)self.numberOfDays];
        self.chuBolusDailyAvg =   [NSNumber numberWithFloat:[self.chuBolusSum floatValue] / (CGFloat)self.numberOfDays];
        self.fpuBolusDailyAvg =   [NSNumber numberWithFloat:[self.fpuBolusSum floatValue] / (CGFloat)self.numberOfDays];
        self.basalDosisDailyAvg = [NSNumber numberWithFloat:[self.basalDosisSum floatValue] / (CGFloat)self.numberOfDays];
        self.insulinDailyAvg =    [NSNumber numberWithFloat:[self.insulinSum floatValue] / (CGFloat) self.numberOfDays];
    }
    return self;
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
    
    if (!_hba1c) {
        _hba1c = [NSNumber numberWithDouble: ([self.bloodSugarWeightedAvg doubleValue] + 86.0) / 33.3 ];
    }
    return _hba1c;
}

-(NSNumber *) bloodSugarWeightedAvg {
    if (!_bloodSugarWeightedAvg) {
        // Only use Events with blood sugar measurements
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bloodSugar > 0"];
        NSArray *eventsWithNonNilBloodSugar = [self.events filteredArrayUsingPredicate:predicate];

        // return nil, if no event found with blood sugar values
        if (!eventsWithNonNilBloodSugar.count) {
            return _bloodSugarWeightedAvg;
        }
        
        NSTimeInterval tDelta, tOverallDelta; // is double
        tOverallDelta = [[[eventsWithNonNilBloodSugar lastObject]  timeStamp] timeIntervalSince1970 ]
                      - [[[eventsWithNonNilBloodSugar firstObject] timeStamp] timeIntervalSince1970 ];
        
        // Loop over all Events (i.e. timeIntervalls)
        double bloodSugarWeightedAvg = 0.0;
        for (NSUInteger i=0; i < eventsWithNonNilBloodSugar.count - 1; i++) {
            // blood sugar weighted avg = sum of ( 1/2 * (  bloodSugar(i) + bloodSugar(i+1) ) * tDelta ) / sum (tDelta), where tDelta = t(i+1) - t(i)
//            NSLog(@"event bs and timeStamp: %@, %@", [[eventsWithNonNilBloodSugar objectAtIndex:i] bloodSugar], [[eventsWithNonNilBloodSugar objectAtIndex:i] timeStamp]);
            tDelta = [[[eventsWithNonNilBloodSugar objectAtIndex:i+1] timeStamp] timeIntervalSince1970 ]
                   - [[[eventsWithNonNilBloodSugar objectAtIndex:i]   timeStamp] timeIntervalSince1970 ];
//            NSLog(@"tDelta %f", tDelta);
            
            bloodSugarWeightedAvg += 0.5 * ( [[[eventsWithNonNilBloodSugar objectAtIndex:i]  bloodSugar] doubleValue] +
                                            [[[eventsWithNonNilBloodSugar objectAtIndex:i+1] bloodSugar] doubleValue] ) * (double) tDelta;
        }
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
-(NSNumber *) numberOfBloodSugarMeasurementsDailyAvg {
    if (!_numberOfBloodSugarMeasurementsDailyAvg && self.numberOfDays >= 1) {
        _numberOfBloodSugarMeasurementsDailyAvg = [NSNumber numberWithFloat:(CGFloat) self.bloodSugarMeasurementsCount / (CGFloat) self.numberOfDays];
    }
    return _numberOfBloodSugarMeasurementsDailyAvg;
}

-(NSInteger) numberOfDays {
    if (!_numberOfDays) {
        // Number of days (i.e. number of midnights between the two dates, thus one has to be added)
        
        if (self.firstDay && self.lastDay) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            _numberOfDays = [calendar daysWithinEraFromDate:self.firstDay toDate:self.lastDay] + 1;
        } else {
            _numberOfDays = 0;
        }
    }
    return _numberOfDays;
}
-(NSNumber *) chuDailyAvg {
    if (!_chuDailyAvg) {
        NSNumber *chuSum = [self.events valueForKeyPath:@"@sum.chu"];
        _chuDailyAvg = [NSNumber numberWithFloat:[chuSum floatValue]/ (CGFloat) self.numberOfDays];
    }
    return _chuDailyAvg;
}
-(NSNumber *) fpuDailyAvg {
    if (!_fpuDailyAvg) {
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
        NSNumber *energySum = [self.events valueForKeyPath:@"@sum.energy"];
        _energyDailyAvg = [NSNumber numberWithFloat:[energySum floatValue]/ (CGFloat) self.numberOfDays];
    }
    return _energyDailyAvg;
}


//-(NSNumber *) effectiveChuFactorAvg {
//    if (!_effectiveChuFactorAvg) {
//         {
//    }
//    return _effectiveChuFactorAvg;
//}


-(NSNumber *) bloodSugarAvg {
    if (!_bloodSugarAvg) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bloodSugar > 0"];
        NSArray *eventsWithNonNilBloodSugar = [self.events filteredArrayUsingPredicate:predicate];
        _bloodSugarAvg = [eventsWithNonNilBloodSugar valueForKeyPath:@"@avg.bloodSugar"];
    }
    return _bloodSugarAvg;
}



@end
