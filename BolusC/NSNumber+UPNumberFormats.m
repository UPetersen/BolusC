//
//  NSNumber+UPNumberFormats.m
//  BolusCalc
//
//  Created by Uwe Petersen on 02.07.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//
//  Category for NumberFormatters, zur Erweiterung um häufig gebrauchte Formate
//

#import "NSNumber+UPNumberFormats.h"
//#define VERBOSE


NSNumberFormatter *sharedNumberFormatter1MaxDigits = nil;
NSNumberFormatter *sharedNumberFormatter2MaxDigits = nil;

// Lock for each numberFormatter to avoid problems, if the code is called by two threads quasi simultaneously
static NSString *kSharedNumberFormatter1MaxDigits = @"kSharedNumberFormatter1MaxDigits";
static NSString *kSharedNumberFormatter2MaxDigits = @"kSharedNumberFormatter2MaxDigits";


@implementation NSNumber (UPNumberFormats)

- (NSString *)stringWithNumberStyle1:(NSNumberFormatterStyle)style
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = style;
    NSString *string = [formatter stringFromNumber:self];
    return string;
}

-(NSString *)stringWithNumberStyle2SigDigits {

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];

    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 1;
    formatter.usesSignificantDigits = YES;
    formatter.maximumSignificantDigits = 2;
    formatter.minimumSignificantDigits = 1;
    formatter.roundingMode = NSNumberFormatterRoundHalfUp;
    formatter.zeroSymbol = @"0";
    formatter.nilSymbol = @"0";
    formatter.notANumberSymbol = @"-";
    
    NSString *string = [formatter stringFromNumber:self];
    return string;
}

-(NSString *)stringWithNumberStyle3SigDigits {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    formatter.numberStyle = NSNumberFormatterNoStyle;
    formatter.usesSignificantDigits = YES;
    formatter.maximumSignificantDigits = 3;
    formatter.roundingMode = NSNumberFormatterRoundHalfUp;
    formatter.zeroSymbol = @"0";
    formatter.nilSymbol = @"0";
    formatter.notANumberSymbol = @"-";
    
    NSString *string = [formatter stringFromNumber:self];
    return string;
}


-(NSString *)stringWithNumberStyle1maxDigits {
    if(sharedNumberFormatter1MaxDigits) {
        return [sharedNumberFormatter1MaxDigits stringForObjectValue:self];
    }
    @synchronized(kSharedNumberFormatter1MaxDigits) {
        if (sharedNumberFormatter1MaxDigits == nil) {
            
            sharedNumberFormatter1MaxDigits = [NSNumberFormatter new];
            
            //            sharedNumberFormatter1MaxDigits.numberStyle = NSNumberFormatterNoStyle;
            sharedNumberFormatter1MaxDigits.numberStyle = NSNumberFormatterDecimalStyle;
            sharedNumberFormatter1MaxDigits.maximumFractionDigits = 1;
            sharedNumberFormatter1MaxDigits.roundingMode = NSNumberFormatterRoundHalfUp;
            sharedNumberFormatter1MaxDigits.zeroSymbol = @"0";
//            sharedNumberFormatter1MaxDigits.nilSymbol  = @"";
//            sharedNumberFormatter1MaxDigits.notANumberSymbol = @"";
        }
    }
    return [sharedNumberFormatter1MaxDigits stringForObjectValue:self];
}
-(NSString *)stringWithNumberStyle2maxDigits {
    if(sharedNumberFormatter2MaxDigits) {
        return [sharedNumberFormatter2MaxDigits stringForObjectValue:self];
    }
    @synchronized(kSharedNumberFormatter2MaxDigits) {
        if (sharedNumberFormatter2MaxDigits == nil) {
            
            sharedNumberFormatter2MaxDigits = [NSNumberFormatter new];
            
            //            sharedNumberFormatter2MaxDigits.numberStyle = NSNumberFormatterNoStyle;
            sharedNumberFormatter2MaxDigits.numberStyle = NSNumberFormatterDecimalStyle;
            sharedNumberFormatter2MaxDigits.maximumFractionDigits = 2;
            sharedNumberFormatter2MaxDigits.roundingMode = NSNumberFormatterRoundHalfUp;
            sharedNumberFormatter2MaxDigits.zeroSymbol = @"0";
//            sharedNumberFormatter2MaxDigits.nilSymbol  = @"";
//            sharedNumberFormatter2MaxDigits.notANumberSymbol = @"";
        }
    }
//    return [sharedNumberFormatter2MaxDigits stringFromNumber:self];
    return [sharedNumberFormatter2MaxDigits stringForObjectValue:self];
}

@end

