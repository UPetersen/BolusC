//
//  UPCellType1.h
//  BolusCalcTest
//
//  Created by Uwe Petersen on 03.12.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTextLabel;

@property (weak, nonatomic) IBOutlet UILabel *bloodSugarLabel;
@property (weak, nonatomic) IBOutlet UILabel *bloodSugarUnitLabel;

@property (weak, nonatomic) IBOutlet UILabel *shortBolusTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortBolusLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortBolusCalculationLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortBolusUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortBolusCalculationUnitLabel;

@property (weak, nonatomic) IBOutlet UILabel *basalDosisTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *basalDosisLabel;
@property (weak, nonatomic) IBOutlet UILabel *basalDosisUnitLabel;

@property (weak, nonatomic) IBOutlet UILabel *fpuBolusTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpuBolusLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpuBolusCalculationLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpuBolusUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpuBolusCalculationUnitLabel;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@end
