//
//  DiaryTableViewCell.h
//  BolusC
//
//  Created by Uwe Petersen on 26.12.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event+Extensions.h"

@interface DiaryTableViewCell : UITableViewCell

@property (nonatomic, strong) Event *event;

-(void) redisplay;

@end
