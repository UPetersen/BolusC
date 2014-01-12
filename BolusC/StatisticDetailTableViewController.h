//
//  StatisticDetailTableViewController.h
//  BolusC
//
//  Created by Uwe Petersen on 12.01.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticDetailTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *arrayWithArrayOfEventsInTimeIntervals; // to be handed over by master view controller
@property (nonatomic, strong) NSMutableArray *eventsStatInTimeIntervals;             // derived here in viewDidLoad

@end
