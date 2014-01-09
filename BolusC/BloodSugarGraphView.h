//
//  PlayingCardView.h
//  Super Card
//
//  Created by Uwe Petersen on 22.10.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BloodSugarGraphView : UIView <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSArray *Events;

// Öffentliche Methode für pinch gesture recognizer, wird vom viewController als selector angegeben
-(void)pinch:(UIPinchGestureRecognizer *)gesture;
-(void)pan:(UIPanGestureRecognizer *)gesture;


@end
