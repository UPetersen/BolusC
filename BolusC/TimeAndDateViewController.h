//
//  UPTimeAndDateViewController.h
//  BolusCalc
//
//  Created by Uwe Petersen on 02.06.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeAndDateViewController : UIViewController

//@property(strong, nonatomic) id currentDateAndTime;
@property(strong, nonatomic) id theObject;

@property (weak, nonatomic) IBOutlet UIDatePicker *pickerDateAndTime;

@end
