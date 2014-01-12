//
//  StatisticSetttingsTableViewController.h
//  BolusC
//
//  Created by Uwe Petersen on 11.01.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticSetttingsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign) NSInteger *currentCategory;
@property (retain) NSArray  *taskCategories;

@property (nonatomic,retain) NSIndexPath *oldIndexPath;


@end
