//
//  NSNumber+UPNumberFormats.h
//  BolusCalc
//
//  Created by Uwe Petersen on 02.07.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (UPNumberFormats)

-(NSString *)stringWithNumberStyle1:(NSNumberFormatterStyle)style;
-(NSString *)stringWithNumberStyle3SigDigits;
-(NSString *)stringWithNumberStyle2SigDigits;

-(NSString *)stringWithNumberStyle0maxDigits;
-(NSString *)stringWithNumberStyle1maxDigits;
-(NSString *)stringWithNumberStyle2maxDigits;

@end
