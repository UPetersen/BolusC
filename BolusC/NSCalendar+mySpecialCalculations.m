//
//  NSCalendar+mySpecialCalculations.m
//  BolusC
//
//  Created by Uwe Petersen on 06.01.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

#import "NSCalendar+mySpecialCalculations.h"

@implementation NSCalendar (mySpecialCalculations)


// From Apple's "Date and Time Programming Guide" (Listing 13):
// Returns the number of days (in the sense of the number of mdinights between the two dates)
-(NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate
{
    NSInteger startDay = [self ordinalityOfUnit:NSDayCalendarUnit inUnit: NSEraCalendarUnit forDate:startDate];
    NSInteger endDay   = [self ordinalityOfUnit:NSDayCalendarUnit inUnit: NSEraCalendarUnit forDate:endDate];
    return endDay-startDay;
}

@end
