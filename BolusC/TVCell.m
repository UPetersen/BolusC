//
//  UPCellType1.m
//  BolusCalcTest
//
//  Created by Uwe Petersen on 03.12.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import "TVCell.h"

@implementation TVCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.bloodSugarLabel.text = [NSString stringWithFormat:@"BZ is 108"];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
