//
//  UPMasterViewController.h
//  BolusCalc
//
//  Created by Uwe Petersen on 20.05.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
//#import "UPEvent.h"


//@interface UPMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;


@end
