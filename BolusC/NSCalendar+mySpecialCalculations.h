//
//  NSCalendar+mySpecialCalculations.h
//  BolusC
//
//  Created by Uwe Petersen on 06.01.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (mySpecialCalculations)

-(NSInteger)daysWithinEraFromDate:(NSDate *) startDate toDate:(NSDate *) endDate;

@end
