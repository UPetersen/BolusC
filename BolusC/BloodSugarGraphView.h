//
//  PlayingCardView.h
//  Super Card
//
//  Created by Uwe Petersen on 22.10.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BloodSugarGraphView : UIView <NSFetchedResultsControllerDelegate>

// View soll unabhängig vom Model sein, deshalb hier Wiederholung, Sonst nicht allgemeine Kartendarstellung
@property (nonatomic) NSUInteger rank;
@property (strong, nonatomic) NSString *suit;

@property (nonatomic) BOOL faceUp;

// Öffentliche Methode für pinch gesture recognizer, wird vom viewController als selector angegeben
-(void)pinch:(UIPinchGestureRecognizer *)gesture;
-(void)pan:(UIPanGestureRecognizer *)gesture;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;


@end
