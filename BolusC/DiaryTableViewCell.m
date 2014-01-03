//
//  DiaryTableViewCell.m
//  BolusC
//
//  Created by Uwe Petersen on 26.12.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import "DiaryTableViewCell.h"
#import "DiaryTableViewView.h"

@interface DiaryTableViewCell ()
@property (weak, nonatomic) IBOutlet DiaryTableViewView *tableViewCellview;
@property (weak, nonatomic) NSString *title;
@end

@implementation DiaryTableViewCell

// Called, when a cell is created
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        // Initialization code
//        [self.tableViewCellview setEvent:self.event];
//        [self.tableViewCellview setNeedsDisplay];
//    }
//    return self;
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}


// Called, when a cell is reused
-(void) prepareForReuse {
    [super prepareForReuse];
    
}


- (void)redisplay {
    [self.tableViewCellview setEvent:self.event];
	[self.tableViewCellview setNeedsDisplay];
}




@end
