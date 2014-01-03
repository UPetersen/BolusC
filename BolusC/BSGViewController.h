//
//  SuperCardViewController.h
//  Super Card
//
//  Created by Uwe Petersen on 22.10.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSGViewController : UIViewController <NSFetchedResultsControllerDelegate>



//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;


@end
