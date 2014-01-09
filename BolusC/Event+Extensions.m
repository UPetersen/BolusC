//
//  Event+Extensions.m
//  BolusCalc
//
//  Created by Uwe Petersen on 01.07.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import "Event+Extensions.h"

#define MAX_CORRECTION_DIVISOR 1000.0
#define CHU_FACTOR_DEFAULT_VALUE 1.3
#define FPU_FACTOR_DEFAULT_VALUE 1.5

//#define VERBOSE


@implementation Event (Extensions)

@dynamic primitiveTimeStamp;
@dynamic primitiveDayString;


#pragma mark - Calculations for the data model


/*
 *************** meal stuff *********************************************************
 */
// Calc Bread Units or Carbohydrate units from Carbs
//-(NSNumber *) chu {
//    if (self.carb) {
//        if (self.useBreadUnits) {
//            return [[NSNumber alloc] initWithDouble: ( self.carb.doubleValue / 12.0)];
//        } else {
//            return [[NSNumber alloc] initWithDouble: ( self.carb.doubleValue / 10.0)];
//        }
//    }
//    return nil;
//}

//// Calc Fat-Protein-Units from Fat and Protein
//-(NSNumber *) fpu {
//    if (self.fat && self.protein) {
//        return [[NSNumber alloc] initWithDouble: ( (9.0 * self.fat.doubleValue + 4.0 * self.protein.doubleValue) / 100.0 )];
//    }
//    return nil;
//}



/*
 *************** correction bolus ***************************************************
 */
// Calc Correction Bolus
//-(NSNumber *)correctionBolus {
//    if (self.bloodSugar && self.correctionDivisor.doubleValue < MAX_CORRECTION_DIVISOR  &&  self.bloodSugarGoal) {
//        return [[NSNumber alloc] initWithDouble: ( (self.bloodSugar.doubleValue - self.bloodSugarGoal.doubleValue) / self.correctionDivisor.doubleValue ) ];
//    }
//    return nil;
//}


//-(void) setCorrectionDivisorForChuBolus:(NSNumber *) correctionBolus {
//    if(correctionBolus && self.bloodSugar && self.bloodSugarGoal && correctionBolus !=0) {
//        self.correctionDivisor = [[NSNumber alloc] initWithDouble: ( (self.bloodSugar.doubleValue - self.bloodSugarGoal.doubleValue) / correctionBolus.doubleValue ) ];
//    } else {
//        self.correctionDivisor = @1000;  // large number, resulting in 0 for the correction bolus
//    }
//}



/*
 *************** combined bolus of short acting insulin (correction + carb) *********
 */
// Calc Bolus for short acting insulin, which is correction Bolus plus Bolus for carb
//-(NSNumber *) shortBolus {
//    if (self.correctionBolus && self.chuBolus) {
//        return [[NSNumber alloc] initWithDouble: ( self.correctionBolus.doubleValue + self.chuBolus.doubleValue )];
//    } else if (self.correctionBolus) {
//        return self.correctionBolus;
//    } else if (self.chuBolus) {
//        return self.chuBolus;
//    }
//    return nil;
//}

/*
 *************** bolus for fat and protein (medium fast acting insulin) *************
 */
// Calc fpuFactor that matches a given fpuBolus (when the user enters the bolus directly)
//-(void) setFpuFactorForFpuBolus:(NSNumber *) fpuBolus {
//    if(self.fpu && fpuBolus && self.fpu!=0) {
//        self.fpuFactor = [[NSNumber alloc] initWithDouble: ( 2.0 * fpuBolus.doubleValue / self.fpu.doubleValue )];
//    } else {
//        self.fpuFactor = nil;
//    }
//}

//// Calc Bolus for fat and protein
//-(NSNumber *) fpuBolus {
//    if ([self fpuFactor] && [self fpu]) {
//        return [[NSNumber alloc] initWithDouble: ( self.fpuFactor.doubleValue * self.fpu.doubleValue / 2.0 )];
//    }
//    return nil;
//}

//Calc Bolus for fat and protein, Alternative calculation method that uses Energy and Carb
//-(NSNumber *) fpuBolusFromEnergyAndCarb {
//    if ([self fpuFactor] && [self energy] && [self carb]) {
//        return [[NSNumber alloc] initWithDouble: ( self.fpuFactor.doubleValue * ( self.energy.doubleValue - 4.0 * self.carb.doubleValue ) / 100.0 )];
//    }
//    return nil;
//}


//-(void) setFpuForEnergyForCarb {
//    if(self.energy && self.carb) {
//        self.fpu =[[NSNumber alloc] initWithDouble: ( self.energy.doubleValue - 4.0 * self.carb.doubleValue ) / 100.0 ];
//    }
//    else {
//        self.fpu = nil;
//    }
//}


//----- initialization, called once ---------------------------------------------------------------------------------------

-(void) awakeFromInsert {
    [super awakeFromInsert];
    
    // Initial values, later to be handled in some kind of settings
    self.timeStamp = [NSDate date];
    self.bloodSugarGoal = @84.0;  // zur Erinnerung an andere Syntax: newEvent.bloodSugarGoal = [[NSNumber alloc] initWithDouble:84.0];
    self.correctionDivisor = @40;
    self.chuFactor = @1.0;
    self.fpuFactor = @0.75;
    self.useBreadUnits = [[NSNumber alloc] initWithBool:NO];
}

//----- shortBolus -------------------------------------------------------------------------------------------------------

// TODO: prüfen, ob die Additon auch mit nil-Werten funktionier
-(void) setShortBolusForCorrectionBolusForChuBolus {
    if (self.correctionBolus || self.chuBolus) {
        self.shortBolus = [[NSNumber alloc] initWithDouble:( self.correctionBolus.doubleValue + self.chuBolus.doubleValue )];
    } else {
        self.shortBolus = nil;
    }
}

//----- correctionBolus --------------------------------------------------------------------------------------------------

-(void) setCorrectionBolusForCorrectionDivisorForBloodSugarForBloodSugarGoal {
    if (self.correctionDivisor && self.bloodSugar && self.bloodSugarGoal && (fabs(self.correctionDivisor.doubleValue) > 0.0001)) {
        self.correctionBolus = [[NSNumber alloc] initWithDouble:
                                ( (self.bloodSugar.doubleValue - self.bloodSugarGoal.doubleValue) / self.correctionDivisor.doubleValue ) ];
    } else {
        self.correctionBolus = nil;
    }
}

-(void) setCorrectionDivisorForCorrectionBolusForBloodSugarForBloodSugarGoal {
    if(self.correctionBolus && self.bloodSugar && self.bloodSugarGoal && (fabs(self.correctionBolus.doubleValue) > 0.0001)) {
        self.correctionDivisor = [[NSNumber alloc] initWithDouble:
                                  ( (self.bloodSugar.doubleValue - self.bloodSugarGoal.doubleValue) / self.correctionBolus.doubleValue ) ];
    }
    else {
        self.correctionDivisor = nil;
    }
}

//----- fat and protein --------------------------------------------------------------------------------------------------

-(void) setChuForCarb {
    if (self.carb) {
        if (self.useBreadUnits.integerValue == 1) {
            self.chu = [[NSNumber alloc] initWithDouble: ( self.carb.doubleValue / 12.0 ) ];
#ifdef VERBOSE
            NSLog(@"BreadUnits, teile durch 12");
#endif
        } else {
            self.chu = [[NSNumber alloc] initWithDouble: ( self.carb.doubleValue / 10.0 ) ];
#ifdef VERBOSE
            NSLog(@"Keine BreadUnits, teile durch 10");
#endif
        }
    }
    else {
        self.chu = nil;
    }
}

-(void) setChuBolusForChuFactorForChu {
    if (self.chu && self.chuFactor ) {
        self.chuBolus = [[NSNumber alloc] initWithDouble:
                         ( self.chu.doubleValue * self.chuFactor.doubleValue)];
    } else {
        self.chuBolus = nil;
    }
}

-(void) setChuFactorForChuBolusForChu {
    if (self.chu && self.chuBolus && (fabs(self.chu.doubleValue) > 0.0001)) {
        self.chuFactor =[[NSNumber alloc] initWithDouble:
                         (self.chuBolus.doubleValue / self.chu.doubleValue)];
    } else {
        self.chuFactor = nil;
    }
}


-(void) setChuFactorToChuFactorDefaultValueIfNil{
    if (!self.chuFactor) {
        self.chuFactor = [[NSNumber alloc] initWithDouble: CHU_FACTOR_DEFAULT_VALUE];
    }
}



//----- fat and protein --------------------------------------------------------------------------------------------------

-(void) setFpuForFatForProtein {
    if (self.fat || self.protein) {
        self.fpu =[[NSNumber alloc] initWithDouble:
                   (( 9.0 * self.fat.doubleValue + 4.0 * self.protein.doubleValue ) / 100.0) ];
    }
    else {
        self.fpu = nil;
    }
}


-(void) setFpuBolusForFpuFactorForFpu {
    if(self.fpu && self.fpuFactor) {
#ifdef VERBOSE
        NSLog(@"fpu und fpuFactor local: %@; %@", self.fpu, self.fpuFactor);
#endif
        self.fpuBolus = [[NSNumber alloc] initWithDouble: ( self.fpu.doubleValue * self.fpuFactor.doubleValue  )];
    } else {
        self.fpuBolus = nil;
    }
}


-(void) setFpuFactorForFpuBolusForFpu {
    if (self.fpu && self.fpuBolus && (fabs(self.fpu.doubleValue) > 0.0001)) {
        self.fpuFactor = [[NSNumber alloc] initWithDouble: ( self.fpuBolus.doubleValue / self.fpu.doubleValue )];
    } else {
        self.fpuFactor = nil;
    }
}

-(void) setFpuFactorToFpuFactorDefaultValueIfNil {
    if (!self.fpuFactor) {
        self.fpuFactor = [[NSNumber alloc] initWithDouble: FPU_FACTOR_DEFAULT_VALUE];
    }
}


//-(CGFloat) hourOfDay
//{
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.timeStamp];
//    NSInteger hour = [components hour];
//    NSInteger minute = [components minute];
//    return (CGFloat) (hour + ((CGFloat) minute )/ 60.0);
//}
-(NSNumber *) hourOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.timeStamp];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    return [NSNumber numberWithFloat:(CGFloat) (hour + ((CGFloat) minute )/ 60.0)];
}

-(NSInteger) roundedHourOfDay {
//    return [[NSNumber alloc] initWithInt:floor([self.hourOfDay doubleValue])];
    return (NSInteger) floor([self.hourOfDay doubleValue]);
}
-(NSInteger) yearForWeekOfYear {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearForWeekOfYearCalendarUnit fromDate:self.timeStamp];
    
    return [components yearForWeekOfYear];
}
-(NSInteger) weekOfYear {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSWeekOfYearCalendarUnit fromDate:self.timeStamp];
    
    return [components weekOfYear];
}

///*
// *************** other stuff *********************************************************
// */
//// Calc Energy from Carb, fat and protein for later comparison to energy entered by user
//-(double) energyFromCarbFatProtein {
//    if ([self carb] && [self fat] && [self protein]) {
//        return 4.0 * [self carb] + 9.0 * [self fat] + 4.0 * [self protein];
//    }
//    return 0.0;
//}
//




// This code can be used, if the storage of the properties primitiveTimeStamp and primitiveDayString doesn't work.
// Normally storage should not work in a category, but fortunately it does work anyway. Hope this persists...
//
//-(void)setMember:(MyObject *)someObject
//{
//    NSMuteableDictionary *dict = [MySingleton sharedRegistry];
//    [dict setObject:someObject forKey:self];
//}
//
//-(MyObject *)member
//{
//    NSMuteableDictionary *dict = [MySingleton sharedRegistry];
//    return [dict objectforKey:self];
//}


#pragma mark Transient properties used for calculation and population the section titles

- (NSString *)dayString {
    
    // Create and cache the section identifier on demand.
    
    [self willAccessValueForKey:@"dayString"];
    NSString *tmp = [self primitiveDayString];
    [self didAccessValueForKey:@"dayString"];
    
    if (!tmp) {
        /*
         Sections are organized by month and year and day. Create the section identifier as a string representing the number (year * 10000) + month * 100 + day; this way they will be correctly ordered chronologically regardless of the actual name of the month.
         */
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                   fromDate:[self timeStamp]];
        tmp = [NSString stringWithFormat:@"%ld", (long)([components year] * 10000) + ([components month]) * 100 + components.day];
#ifdef VERBOSE
        NSLog(@"tmp = %@", tmp);
#endif
        [self setPrimitiveDayString:tmp];
    }
    return tmp;
}


#pragma mark -
#pragma mark Time stamp setter

- (void)setTimeStamp:(NSDate *)newDate {
    
    // If the time stamp changes, the section identifier dayString becomes invalid.
    [self willChangeValueForKey:@"timeStamp"];
    [self setPrimitiveTimeStamp:newDate];
    [self didChangeValueForKey:@"timeStamp"];
    
    [self setPrimitiveDayString:nil];
}


#pragma mark -
#pragma mark Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingDayString {
    // If the value of timeStamp changes, the section identifier may change as well.
    return [NSSet setWithObject:@"timeStamp"];
}





@end
