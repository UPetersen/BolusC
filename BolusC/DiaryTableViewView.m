//
//  DiaryTableViewCellView.m
//  BolusC
//
//  Created by Uwe Petersen on 26.12.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import "DiaryTableViewView.h"
#import "Event+Extensions.h"

@interface DiaryTableViewView ()
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) CGFloat upperRowTopForSecondaryFont;

@property (nonatomic, strong) UIFont *mainFont;
@property (nonatomic, strong) UIFont *secondaryFont;
@property (nonatomic, strong) UIFont *tertiaryFont;

@property (nonatomic, strong) NSDictionary *mainTextAttributes;
@property (nonatomic, strong) NSDictionary *secondaryTextAttributes;
@property (nonatomic, strong) NSDictionary *tertiaryTextAttributes;

@property (nonatomic) CGFloat yPosDeltaForSecondaryFont;
@property (nonatomic) CGFloat yPosDeltaForTertiaryFont;

@property (nonatomic, strong) UIColor *noValueColor;
@property (nonatomic, strong) UIColor *chuColor;
@property (nonatomic, strong) UIColor *shortBolusColor;
@property (nonatomic, strong) UIColor *fpuColor;
@property (nonatomic, strong) UIColor *fpuBolusColor;
@property (nonatomic, strong) UIColor *basalDosisColor;

@property (strong, nonatomic) NSNumberFormatter *numberFormatter1Digit;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter2SigDigits;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter3SigDigits;


@end

@implementation DiaryTableViewView


#define STYLE 2


#define BLOOD_SUGAR_BOX_XPOS 10
#define TIMESTAMP_BOX_XPOS_FROM_RIGHT 10

#define BLOOD_SUGAR_BOX_XPOS_FROM_RIGHT 10
#define TIMESTAP_BOX_XPOS 10

#define BOX_HEIGHT 50
#define BOX_OUTSET 2

#define CHU_BOX_XPOS 10
#define CHU_BOX_WIDTH 70

#define SHORT_BOLUS_BOX_XPOS 83 // 83 /155
#define SHORT_BOLUS_BOX_WIDTH 72

#define FPU_BOX_XPOS 203 // 83 // 160
#define FPU_BOX_WIDTH 69

#define FPU_BOLUS_BOX_XPOS 275 // 230
#define FPU_BOLUS_BOX_WIDTH 42

#define BASAL_BOX_XPOS 158 // 275
#define BASAL_BOX_WIDTH 42

#define COMMENT_BOX_XPOS 10

#define YPOS_FIRST_ROW 3
#define YPOS_SECOND_ROW_UPPER_TEXT 32
#define YPOS_SECOND_ROW_MAIN_TEXT 44
#define YPOS_SECOND_ROW_LOWER_TEXT 68
#define YPOS_THIRD_ROW 85

#define MAIN_FONT_SIZE 20.0
#define SECONDARY_FONT_SIZE 13.0
#define TERTIARY_FONT_SIZE 9




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - draw rect methods

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(STYLE==1) {
        [self drawRectWithStyleOne:rect];
    } else {
        [self drawRectWithStyleTwo:rect];
    }
}

-(void)drawRectWithStyleTwo:(CGRect)rect {
    
    // ------------------------------------------------------------------------------------------------------------------------------------------
    // First Row with blood sugar and timestamp
    // ------------------------------------------------------------------------------------------------------------------------------------------

    CGPoint point;

    // Left column: blood sugar and blood sugar unit, e.g. "98 mg/dl"
    if (self.event.bloodSugar) {
        
        // Blood Sugar Unit, e.g. "mg/dl"
        NSAttributedString *bloodSugarUnitString = [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@" mg/dl"] attributes:self.tertiaryTextAttributes];
        point =CGPointMake(self.bounds.size.width - BLOOD_SUGAR_BOX_XPOS_FROM_RIGHT - bloodSugarUnitString.size.width, YPOS_FIRST_ROW + self.yPosDeltaForTertiaryFont);
        [bloodSugarUnitString drawAtPoint:point];

        // Blood sugar, e.g. "84"
        NSAttributedString *bloodSugarString = [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%@",self.event.bloodSugar] attributes:self.mainTextAttributes];
        point = CGPointMake(self.bounds.size.width - BLOOD_SUGAR_BOX_XPOS_FROM_RIGHT - bloodSugarString.size.width - bloodSugarUnitString.size.width, YPOS_FIRST_ROW);
        [bloodSugarString drawAtPoint:point];
    }

    // Right column: from the right: time label and time label, e.g. "9:28 Uhr"

    // The time itself, e.g. "12:53"
    NSAttributedString *timeString = [[NSAttributedString alloc] initWithString:[[NSString alloc]initWithFormat:@"%@", [self.dateFormatter stringFromDate:self.event.timeStamp]] attributes:self.mainTextAttributes];
    point = CGPointMake(TIMESTAP_BOX_XPOS, YPOS_FIRST_ROW);
    [timeString drawAtPoint:point];

    
    // Time label, e.g. "Uhr" (constant could be placed in a separate method with lazy instantiation)
    NSAttributedString *timeStringLabel = [[NSAttributedString alloc] initWithString:[[NSString alloc]initWithFormat:@" Uhr"] attributes:self.tertiaryTextAttributes];
//    point = CGPointMake(self.bounds.size.width - TIMESTAMP_BOX_XPOS_FROM_RIGHT - timeStringLabel.size.width, YPOS_FIRST_ROW + self.yPosDeltaForTertiaryFont);
    point =CGPointMake(TIMESTAP_BOX_XPOS + timeString.size.width, YPOS_FIRST_ROW + self.yPosDeltaForTertiaryFont);
    [timeStringLabel drawAtPoint:point];
    
    
    
    
    // ------------------------------------------------------------------------------------------------------------------------------------------
    // Second Row with the boxes for food and insulin
    // ------------------------------------------------------------------------------------------------------------------------------------------
    
        [self drawBoxWithLabelString:@"Kohlehydrate"
                         valueString:[NSString stringWithFormat:@"%@",[self.numberFormatter1Digit stringForObjectValue:self.event.chu]]
                          unitString:@"KHE"
                 appendedValueString:[NSString stringWithFormat:@"%@",[self.numberFormatter2SigDigits stringForObjectValue:self.event.chuFactor]]
                  appendedUnitString:@"IE/KHE"
                  mainTextAttributes:self.mainTextAttributes
             secondaryTextAttributes:self.secondaryTextAttributes
              tertiaryTextAttributes:self.tertiaryTextAttributes
                        xPosLabelRow:CHU_BOX_XPOS
                        yPosLabelRow:YPOS_SECOND_ROW_UPPER_TEXT
                        yPosValueRow:YPOS_SECOND_ROW_MAIN_TEXT
                         yPosUnitRow:YPOS_SECOND_ROW_LOWER_TEXT
     yPosDeltaForAppendedValueString:self.yPosDeltaForSecondaryFont
                               width:CHU_BOX_WIDTH height:BOX_HEIGHT boxOutset:BOX_OUTSET color:self.chuColor];
    
        [self drawBoxWithLabelString:@"Bolus (Korr.)"
                         valueString:[NSString stringWithFormat:@"%@",[self.numberFormatter1Digit stringForObjectValue:self.event.shortBolus]]
                          unitString:@"IE"
                 appendedValueString:[NSString stringWithFormat:@"(%@)",[self.numberFormatter1Digit stringForObjectValue:self.event.correctionBolus]]
                  appendedUnitString:nil
                  mainTextAttributes:self.mainTextAttributes
             secondaryTextAttributes:self.secondaryTextAttributes
              tertiaryTextAttributes:self.tertiaryTextAttributes
                        xPosLabelRow:SHORT_BOLUS_BOX_XPOS
                        yPosLabelRow:YPOS_SECOND_ROW_UPPER_TEXT
                        yPosValueRow:YPOS_SECOND_ROW_MAIN_TEXT
                         yPosUnitRow:YPOS_SECOND_ROW_LOWER_TEXT
     yPosDeltaForAppendedValueString:self.yPosDeltaForSecondaryFont
                               width:SHORT_BOLUS_BOX_WIDTH height:BOX_HEIGHT boxOutset:BOX_OUTSET color:self.shortBolusColor];

    [self drawBoxWithLabelString:@"Fett/Protein"
                         valueString:[NSString stringWithFormat:@"%@",[self.numberFormatter1Digit stringForObjectValue:self.event.fpu]]
                          unitString:@"FPE"
                 appendedValueString:[NSString stringWithFormat:@"%@",[self.numberFormatter2SigDigits stringForObjectValue:self.event.fpuFactor]]
                  appendedUnitString:@"IE/FPE"
                  mainTextAttributes:self.mainTextAttributes
             secondaryTextAttributes:self.secondaryTextAttributes
              tertiaryTextAttributes:self.tertiaryTextAttributes
                        xPosLabelRow:FPU_BOX_XPOS
                        yPosLabelRow:YPOS_SECOND_ROW_UPPER_TEXT
                        yPosValueRow:YPOS_SECOND_ROW_MAIN_TEXT
                         yPosUnitRow:YPOS_SECOND_ROW_LOWER_TEXT
     yPosDeltaForAppendedValueString:self.yPosDeltaForSecondaryFont
                               width:FPU_BOX_WIDTH height:BOX_HEIGHT boxOutset:BOX_OUTSET color:self.fpuColor];

    [self drawBoxWithLabelString:@"NPH-Ins."
                         valueString:[NSString stringWithFormat:@"%@",[self.numberFormatter1Digit stringForObjectValue:self.event.fpuBolus]]
                          unitString:@"IE"
                 appendedValueString:nil
                  appendedUnitString:nil
                  mainTextAttributes:self.mainTextAttributes
             secondaryTextAttributes:self.secondaryTextAttributes
              tertiaryTextAttributes:self.tertiaryTextAttributes
                        xPosLabelRow:FPU_BOLUS_BOX_XPOS
                        yPosLabelRow:YPOS_SECOND_ROW_UPPER_TEXT
                        yPosValueRow:YPOS_SECOND_ROW_MAIN_TEXT
                         yPosUnitRow:YPOS_SECOND_ROW_LOWER_TEXT
     yPosDeltaForAppendedValueString:self.yPosDeltaForSecondaryFont
                               width:FPU_BOLUS_BOX_WIDTH height:BOX_HEIGHT boxOutset:BOX_OUTSET color:self.fpuBolusColor];

    [self drawBoxWithLabelString:@"Basal"
                         valueString:[NSString stringWithFormat:@"%@",[self.numberFormatter1Digit stringForObjectValue:self.event.basalDosis]]
                          unitString:@"IE"
                 appendedValueString:nil
                  appendedUnitString:nil
                  mainTextAttributes:self.mainTextAttributes
             secondaryTextAttributes:self.secondaryTextAttributes
              tertiaryTextAttributes:self.tertiaryTextAttributes
                        xPosLabelRow:BASAL_BOX_XPOS
                        yPosLabelRow:YPOS_SECOND_ROW_UPPER_TEXT
                        yPosValueRow:YPOS_SECOND_ROW_MAIN_TEXT
                         yPosUnitRow:YPOS_SECOND_ROW_LOWER_TEXT
     yPosDeltaForAppendedValueString:self.yPosDeltaForSecondaryFont
                               width:BASAL_BOX_WIDTH height:BOX_HEIGHT boxOutset:BOX_OUTSET color:self.basalDosisColor];
    
    
    
    // ------------------------------------------------------------------------------------------------------------------------------------------
    // Third Row with the comment text
    // ------------------------------------------------------------------------------------------------------------------------------------------

    if (self.event.comment) {
        NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:self.event.comment attributes:self.secondaryTextAttributes];
        point = CGPointMake(COMMENT_BOX_XPOS, YPOS_THIRD_ROW);
        [commentString drawAtPoint:point];
    }
    
}

-(void)drawRectWithStyleOne:(CGRect) rect{
    
#define LEFT_COLUMN_OFFSET 10.
#define MIDDLE_COLUMN_OFFSET 160.
#define RIGHT_COLUMN_OFFSET_FROM_RIGHT 10.
    
#define UPPER_ROW_Y_POS 5.  // Y-Position of a upper text line (i.e. the upper border of the text with respect to the upper border of the view bound)
#define LOWER_ROW_Y_POS 44.  // ...
    
#define SECOND_ROW_UPPER_TEXT_Y_POS 32.
#define SECOND_ROW_MIDDLE_TEXT_Y_POS 42.
#define SECOND_ROW_LOWER_TEXT_Y_POS 66.
    
#define THIRD_ROW_Y_POS 82.
    
    
    CGPoint point;
    
    /*
     =======================================================================================================
     First line: blood sugar at the left, and time at the right
     =======================================================================================================
     */
    
    // -----------------------------------------------------------------------------------------------------
    // Left column: blood sugar and blood sugar unit, e.g. "98 mg/dl"
    // -----------------------------------------------------------------------------------------------------
    if (self.event.bloodSugar) {
        // Blood sugar, e.g. "84"
        NSAttributedString *bloodSugarString = [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%@",self.event.bloodSugar] attributes:self.mainTextAttributes];
        point = CGPointMake(LEFT_COLUMN_OFFSET, UPPER_ROW_Y_POS);
        [bloodSugarString drawAtPoint:point];
        
        // Blood Sugar Unit, e.g. "mg/dl"
        NSAttributedString *bloodSugarUnitString = [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@" mg/dl"] attributes:self.secondaryTextAttributes];
        point =CGPointMake(LEFT_COLUMN_OFFSET + bloodSugarString.size.width, self.upperRowTopForSecondaryFont);
        [bloodSugarUnitString drawAtPoint:point];
    }
    // -----------------------------------------------------------------------------------------------------
    // Right column: from the right: time label and time, e.g. "9:28 Uhr"
    // -----------------------------------------------------------------------------------------------------
    
    // Time label, e.g. "Uhr" (constant could be placed in a separate method with lazy instantiation)
    NSAttributedString *timeStringLabel = [[NSAttributedString alloc] initWithString:[[NSString alloc]initWithFormat:@" Uhr"] attributes:self.secondaryTextAttributes];
    point = CGPointMake(self.bounds.size.width - RIGHT_COLUMN_OFFSET_FROM_RIGHT - timeStringLabel.size.width, self.upperRowTopForSecondaryFont);
    [timeStringLabel drawAtPoint:point];
    

    // The time itself, e.g. "12:53"
    NSAttributedString *timeString = [[NSAttributedString alloc] initWithString:[[NSString alloc]initWithFormat:@"%@", [self.dateFormatter stringFromDate:self.event.timeStamp]] attributes:self.mainTextAttributes];
    point = CGPointMake(self.bounds.size.width - RIGHT_COLUMN_OFFSET_FROM_RIGHT - timeStringLabel.size.width - timeString.size.width, UPPER_ROW_Y_POS);
    [timeString drawAtPoint:point];

    /*
     =======================================================================================================
     Second group of lines: left block with all the data for short bolus
     =======================================================================================================
     */
    if (self.event.shortBolus || self.event.chu) {
        
        // Header text, e.g. "Korrektur und Kohlehydrate"
        NSAttributedString *headerString = [[NSAttributedString alloc] initWithString:[[NSString alloc]initWithFormat:@"Korr. und Kohleydrate"]attributes:self.secondaryTextAttributes];
        point = CGPointMake(LEFT_COLUMN_OFFSET, SECOND_ROW_UPPER_TEXT_Y_POS);
        [headerString drawAtPoint:point];
        
        NSAttributedString *shortBolusString, *shortBolusUnit;
        if (self.event.shortBolus) {
            // Text with the Bolus, e.g. "10,5"
            shortBolusString = [[NSAttributedString alloc] initWithString:[self.numberFormatter1Digit stringForObjectValue:self.event.shortBolus]
                                                                                   attributes:self.mainTextAttributes];
            point = CGPointMake(LEFT_COLUMN_OFFSET, SECOND_ROW_MIDDLE_TEXT_Y_POS);
            [shortBolusString drawAtPoint:point];
            
            // lower text, e.g. "IE"
            shortBolusUnit = [[NSAttributedString alloc] initWithString:@"IE" attributes:self.secondaryTextAttributes];
            point = CGPointMake(LEFT_COLUMN_OFFSET, SECOND_ROW_LOWER_TEXT_Y_POS);
            [shortBolusUnit drawAtPoint:point];
        }

        // The detailled calculation of the short Bolus
        NSString *shortBolusCalculationString, *shortBolusCalculationUnit;
        if (self.event.chuBolus.doubleValue != 0) {    // chuBolus (e.g. "1 IE + 1,1 IE/KHE * 2,3 KHE")
            shortBolusCalculationString = [[NSString alloc] initWithFormat:@" %@ + %@ x %@",
                                           [self.numberFormatter2SigDigits stringForObjectValue:self.event.correctionBolus],
                                           [self.numberFormatter2SigDigits stringForObjectValue:self.event.chuFactor],
                                           [self.numberFormatter2SigDigits stringForObjectValue:self.event.chu] ];
            shortBolusCalculationUnit = @" IE + IE/KHE x KHE";
        } else if (self.event.chu.doubleValue > 0) {
            // chu only (e.g. "2,3 KHE")
            shortBolusCalculationString = [[NSString alloc] initWithFormat:@" %@", [self.numberFormatter2SigDigits stringForObjectValue:self.event.chu] ];
            shortBolusCalculationUnit = @" KHE";
        } else if (self.event.correctionBolus.doubleValue != 0) {
            // Only Correction Bolus and chuBolus (e.g. "1 IE Korrektur")
            shortBolusCalculationString = [[NSString alloc] initWithFormat:@" %@ Korrektur",
                                                    [self.numberFormatter1Digit stringForObjectValue:self.event.correctionBolus]];
            shortBolusCalculationUnit = @" IE";
        } else {
            shortBolusCalculationString = @"This should not happen";
            shortBolusCalculationUnit = @"This neither";
        }

        
        NSAttributedString *shortBolusCalculationAttrString = [[NSAttributedString alloc] initWithString:shortBolusCalculationString attributes:self.secondaryTextAttributes];
        point = CGPointMake(LEFT_COLUMN_OFFSET + shortBolusString.size.width,
                            SECOND_ROW_MIDDLE_TEXT_Y_POS + self.mainFont.lineHeight + self.mainFont.descender - self.secondaryFont.lineHeight - self.secondaryFont.descender);
        [shortBolusCalculationAttrString drawAtPoint:point];
        
        NSAttributedString *shortBolusCalculationAttrUnit = [[NSAttributedString alloc] initWithString:shortBolusCalculationUnit attributes:self.secondaryTextAttributes];
        point = CGPointMake(LEFT_COLUMN_OFFSET + shortBolusString.size.width,  SECOND_ROW_LOWER_TEXT_Y_POS);
        [shortBolusCalculationAttrUnit drawAtPoint:point];
    }
    

    if (self.event.basalDosis) {
        NSAttributedString *headerString = [[NSAttributedString alloc] initWithString:[[NSString alloc]initWithFormat:@"Basal"]attributes:self.secondaryTextAttributes];
        point = CGPointMake(MIDDLE_COLUMN_OFFSET, SECOND_ROW_UPPER_TEXT_Y_POS);
        [headerString drawAtPoint:point];

        // Text with the basal dosis, e.g. "4,5"
        NSAttributedString *basalDosisString = [[NSAttributedString alloc] initWithString:[self.numberFormatter1Digit stringForObjectValue:self.event.basalDosis] attributes:self.mainTextAttributes];
        point = CGPointMake(MIDDLE_COLUMN_OFFSET, SECOND_ROW_MIDDLE_TEXT_Y_POS);
        [basalDosisString drawAtPoint:point];

        // lower text, e.g. "IE"
        NSAttributedString *basalDosisUnit = [[NSAttributedString alloc] initWithString:@"IE" attributes:self.secondaryTextAttributes];
        point = CGPointMake(MIDDLE_COLUMN_OFFSET, SECOND_ROW_LOWER_TEXT_Y_POS);
        [basalDosisUnit drawAtPoint:point];
    
    }
    
    
    // All the stuff on fat and protein
    if (self.event.fpuBolus || self.event.fpu) {

        // Header text, e.g. "Fett und Protein"
        NSAttributedString *headerString = [[NSAttributedString alloc] initWithString:[[NSString alloc]initWithFormat:@"Fett und Protein"]attributes:self.secondaryTextAttributes];
        point = CGPointMake(self.bounds.size.width - RIGHT_COLUMN_OFFSET_FROM_RIGHT - headerString.size.width, SECOND_ROW_UPPER_TEXT_Y_POS);
        [headerString drawAtPoint:point];
        

        NSString *fpuBolusCalculationString, *fpuBolusCalculationUnit;
        if (self.event.fpuBolus.doubleValue > 0) {
            fpuBolusCalculationString = [[NSString alloc] initWithFormat:@" %@ x %@",
                                         [self.numberFormatter2SigDigits stringForObjectValue:self.event.fpuFactor],
                                         [self.numberFormatter2SigDigits stringForObjectValue:self.event.fpu]];
            fpuBolusCalculationUnit = [[NSString alloc] initWithFormat:@" IE/FPE x FPE"];
        }  else if (self.event.fpu.doubleValue > 0) {
            // e.g. "5 FPE"
            fpuBolusCalculationString = [[NSString alloc] initWithFormat:@" %@", [self.numberFormatter2SigDigits stringForObjectValue:self.event.fpu]];
            fpuBolusCalculationUnit = @" FPE";
        }
        
        // lower text, e.g. "0,75 x 12"
        NSAttributedString *fpuBolusCalculationAttrString = [[NSAttributedString alloc] initWithString:fpuBolusCalculationString
                                                                                            attributes:self.secondaryTextAttributes];
        point = CGPointMake(self.bounds.size.width - RIGHT_COLUMN_OFFSET_FROM_RIGHT - fpuBolusCalculationAttrString.size.width,
                            SECOND_ROW_MIDDLE_TEXT_Y_POS + self.mainFont.lineHeight + self.mainFont.descender - self.secondaryFont.lineHeight - self.secondaryFont.descender);
        [fpuBolusCalculationAttrString drawAtPoint:point];
        
        // lower text unit, e.g. "IE/FPE X FPE"
        NSAttributedString *fpuBolusCalculationAttrUnit= [[NSAttributedString alloc] initWithString:fpuBolusCalculationUnit
                                                                                            attributes:self.secondaryTextAttributes];
        point = CGPointMake(self.bounds.size.width - RIGHT_COLUMN_OFFSET_FROM_RIGHT - fpuBolusCalculationAttrUnit.size.width, SECOND_ROW_LOWER_TEXT_Y_POS);
        [fpuBolusCalculationAttrUnit drawAtPoint:point];
        
        if (self.event.fpuBolus ) {
            // Text with the Bolus, e.g. "10,5"
            NSAttributedString *fpuBolusString = [[NSAttributedString alloc] initWithString:[self.numberFormatter1Digit stringForObjectValue:self.event.fpuBolus] attributes:self.mainTextAttributes];
            point = CGPointMake(self.bounds.size.width - RIGHT_COLUMN_OFFSET_FROM_RIGHT - fpuBolusString.size.width - fpuBolusCalculationAttrString.size.width, SECOND_ROW_MIDDLE_TEXT_Y_POS);
            [fpuBolusString drawAtPoint:point];
            
            //        // Text with the Bolus, e.g. "10,5"
            //        NSAttributedString *fpuBolusCalculationAttrString = [[NSAttributedString alloc] initWithString:[self.numberFormatter1Digit stringForObjectValue:self.event.fpuBolus] attributes:self.mainTextAttributes];
            //        point = CGPointMake(self.bounds.size.width - RIGHT_COLUMN_OFFSET_FROM_RIGHT - fpuBolusString.size.width, SECOND_ROW_MIDDLE_TEXT_Y_POS);
            //        [fpuBolusCalculationAttrString drawAtPoint:point];
            
            // lower text, e.g. "IE"
            NSAttributedString *fpuBolusUnit = [[NSAttributedString alloc] initWithString:@"IE" attributes:self.secondaryTextAttributes];
            point = CGPointMake(self.bounds.size.width - RIGHT_COLUMN_OFFSET_FROM_RIGHT - fpuBolusString.size.width - fpuBolusCalculationAttrUnit.size.width, SECOND_ROW_LOWER_TEXT_Y_POS);
            [fpuBolusUnit drawAtPoint:point];
        }
    }
    
    
    if (self.event.comment) {
        NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:self.event.comment attributes:self.secondaryTextAttributes];
        point = CGPointMake(LEFT_COLUMN_OFFSET, THIRD_ROW_Y_POS);
        [commentString drawAtPoint:point];
    }
}

-(CGFloat) upperRowTopForSecondaryFont{
    // Y-Position is the distance from the upper border of the view to the upper border of the text and thus must be calculated for the secondary font in order to
    // draw it on the same baseline as the text with the main font
    if (!_upperRowTopForSecondaryFont) {
        _upperRowTopForSecondaryFont = UPPER_ROW_Y_POS + self.mainFont.lineHeight + self.mainFont.descender - self.secondaryFont.lineHeight - self.secondaryFont.descender;
    }
    return _upperRowTopForSecondaryFont;
}


# pragma mark - String and Box Drawing

-(NSAttributedString *) drawString: (NSString *)string
                    withAttributes:(NSDictionary *)attributes
                            atXPos:(CGFloat) xPos
                            atYPos:(CGFloat) yPos
{
    if (string) {
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
        [attributedString drawAtPoint:CGPointMake(xPos, yPos)];
        return attributedString;
    } else {
        return nil;
    }
}

-(void)       drawBoxWithLabelString:(NSString *) labelString
                         valueString:(NSString *) valueString
                          unitString:(NSString *) unitString
                 appendedValueString:(NSString *) appendedValueString
                  appendedUnitString:(NSString *) appendedUnitString
                  mainTextAttributes:(NSDictionary *) mainTextAttributes
             secondaryTextAttributes:(NSDictionary *) secondaryTextAttributes
              tertiaryTextAttributes:(NSDictionary *) tertiaryTextAttributes
                        xPosLabelRow:(CGFloat) xPos
                        yPosLabelRow:(CGFloat) yPosLabelRow
                        yPosValueRow:(CGFloat) yPosValueRow
                         yPosUnitRow:(CGFloat) yPosUnitRow
     yPosDeltaForAppendedValueString:(CGFloat) yPosDeltaForAppendedValue
{
    [self drawString:labelString withAttributes:tertiaryTextAttributes atXPos:xPos atYPos:yPosLabelRow ];
    NSAttributedString *localValueString = [self drawString:valueString withAttributes:mainTextAttributes     atXPos:xPos atYPos:yPosValueRow];
    [self drawString:unitString withAttributes:tertiaryTextAttributes  atXPos:xPos atYPos:yPosUnitRow];
    
    if (appendedValueString) {
        [self drawString:appendedValueString withAttributes:secondaryTextAttributes
                  atXPos:xPos + localValueString.size.width
                  atYPos:yPosValueRow + yPosDeltaForAppendedValue];
        [self drawString:appendedUnitString withAttributes:tertiaryTextAttributes
                  atXPos:xPos + localValueString.size.width -5
                  atYPos:yPosUnitRow];
    }
}

-(void)       drawBoxWithLabelString:(NSString *) labelString
                         valueString:(NSString *) valueString
                          unitString:(NSString *) unitString
                 appendedValueString:(NSString *) appendedValueString
                  appendedUnitString:(NSString *) appendedUnitString
                  mainTextAttributes:(NSDictionary *) mainTextAttributes
             secondaryTextAttributes:(NSDictionary *) secondaryTextAttributes
              tertiaryTextAttributes:(NSDictionary *) tertiaryTextAttributes
                        xPosLabelRow:(CGFloat) xPos
                        yPosLabelRow:(CGFloat) yPosLabelRow
                        yPosValueRow:(CGFloat) yPosValueRow
                         yPosUnitRow:(CGFloat) yPosUnitRow
     yPosDeltaForAppendedValueString:(CGFloat) yPosDeltaForAppendedValue
                               width:(CGFloat) width
                              height:(CGFloat) height
                           boxOutset:(CGFloat) boxOutset
                               color:(UIColor*) color
{
    
    // Rect for colored box
    UIBezierPath *chuRect = [UIBezierPath bezierPathWithRect:CGRectMake(xPos - boxOutset, yPosLabelRow - boxOutset, width, height)];
    
    // All the strings
    if (valueString.length) {
        [color setFill]; // Direkte Angabe der Farbe rot im HSV-Farbraum für blasse Farben (erlaubt alpha=1)
        [chuRect fill];                                                    // Rechteck farbig malen
        
        [self drawString:labelString withAttributes:tertiaryTextAttributes atXPos:xPos atYPos:yPosLabelRow ];
        NSAttributedString *localValueString = [self drawString:valueString withAttributes:mainTextAttributes     atXPos:xPos atYPos:yPosValueRow];
        [self drawString:unitString withAttributes:tertiaryTextAttributes  atXPos:xPos atYPos:yPosUnitRow];
        
        if (appendedValueString) {
            [self drawString:appendedValueString withAttributes:secondaryTextAttributes
                      atXPos:xPos + localValueString.size.width
                      atYPos:yPosValueRow + yPosDeltaForAppendedValue];
            [self drawString:appendedUnitString withAttributes:tertiaryTextAttributes
                      atXPos:xPos + localValueString.size.width -5
                      atYPos:yPosUnitRow];
        }
    } else {
        // Draw gray rect
        [self.noValueColor setFill]; // Direkte Angabe der Farbe rot im HSV-Farbraum für blasse Farben (erlaubt alpha=1)
        [chuRect fill];              // Rechteck farbig malen
        
    }
}

#pragma mark - box positioning


-(CGFloat) yPosDeltaForSecondaryFont {
    if (!_yPosDeltaForSecondaryFont) {
        _yPosDeltaForSecondaryFont = self.mainFont.lineHeight + self.mainFont.descender - self.secondaryFont.lineHeight - self.secondaryFont.descender;
    }
    return _yPosDeltaForSecondaryFont;
}
-(CGFloat) yPosDeltaForTertiaryFont {
    if (!_yPosDeltaForTertiaryFont) {
        _yPosDeltaForTertiaryFont = self.mainFont.lineHeight + self.mainFont.descender - self.tertiaryFont.lineHeight - self.tertiaryFont.descender;
    }
    return _yPosDeltaForTertiaryFont;
}



#pragma mark - colors

-(UIColor *)noValueColor {
    if (!_noValueColor) {
        _noValueColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    }
    return _noValueColor;
}
-(UIColor *)chuColor {
    if (!_chuColor) {
        _chuColor = [UIColor colorWithHue:38./360. saturation:.15 brightness:1 alpha:1];
    }
    return _chuColor;
}

-(UIColor *)shortBolusColor {
    if (!_shortBolusColor) {
        _shortBolusColor = [UIColor colorWithHue:38./360. saturation:0.3 brightness:1 alpha:1];
    }
    return _shortBolusColor;
}
-(UIColor *)fpuColor {
    if (!_fpuColor) {
        _fpuColor = [UIColor colorWithHue:54./360. saturation:0.17 brightness:.9 alpha:1];
    }
    return _fpuColor;
}
-(UIColor *)fpuBolusColor {
    if (!_fpuBolusColor) {
        _fpuBolusColor = [UIColor colorWithHue:54./360. saturation:0.17 brightness:.8 alpha:1];
    }
    return _fpuBolusColor;
}
-(UIColor *)basalDosisColor {
    if (!_basalDosisColor) {
        _basalDosisColor = [UIColor colorWithHue:240./360. saturation:0.17 brightness:.9 alpha:1];
    }
    return _basalDosisColor;
}

#pragma mark - fonts and text attributes

-(UIFont *)mainFont {
    if (!_mainFont) {
        //        _mainFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    }
    return _mainFont;
}

-(UIFont *)secondaryFont {
    if (!_secondaryFont) {
        //        _secondaryFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        _secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
    }
    return _secondaryFont;
}

-(UIFont *)tertiaryFont {
    if (!_tertiaryFont) {
        //        _secondaryFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        _tertiaryFont = [UIFont systemFontOfSize:TERTIARY_FONT_SIZE];
    }
    return _tertiaryFont;
}

/*
 Font attributes for the main text items. For iOS 7 and later, use text styles instead of system fonts.
 */
-(NSDictionary *) mainTextAttributes {
    if (!_mainTextAttributes) {
        UIColor *mainTextColor = [UIColor blackColor];
        _mainTextAttributes = @{NSFontAttributeName : self.mainFont, NSForegroundColorAttributeName : mainTextColor};
    }
    return _mainTextAttributes;
}
/*
 Font attributes for the secondary text items.
 */
-(NSDictionary *) secondaryTextAttributes {
    if (!_secondaryTextAttributes) {
        UIColor *secondaryTextColor = [UIColor darkGrayColor];
        _secondaryTextAttributes = @{NSFontAttributeName : self.secondaryFont, NSForegroundColorAttributeName : secondaryTextColor};
    }
    return _secondaryTextAttributes;
}

-(NSDictionary *) tertiaryTextAttributes {
    if (!_tertiaryTextAttributes) {
        UIColor *tertiaryTextColor = [UIColor grayColor];
        _tertiaryTextAttributes = @{NSFontAttributeName : self.tertiaryFont, NSForegroundColorAttributeName : tertiaryTextColor};
    }
    return _tertiaryTextAttributes;
}




#pragma mark - formatters


-(NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"H:mm" options:0 locale:[NSLocale currentLocale]];
        [_dateFormatter setDateFormat:dateFormat];
    }
    return _dateFormatter;
}

-(NSNumberFormatter *)numberFormatter1Digit {
    if (!_numberFormatter1Digit) {
        _numberFormatter1Digit = [[NSNumberFormatter alloc] init];
        _numberFormatter1Digit.maximumFractionDigits = 1;
        _numberFormatter1Digit.minimumIntegerDigits = 1;
        _numberFormatter1Digit.roundingMode = NSNumberFormatterRoundHalfUp;
        _numberFormatter1Digit.zeroSymbol = @"0";
//        _numberFormatter1Digit.nilSymbol = @"0";
        _numberFormatter1Digit.nilSymbol = @"";
        _numberFormatter1Digit.notANumberSymbol = @"-";
    }
    return _numberFormatter1Digit;
}

-(NSNumberFormatter *)numberFormatter2SigDigits {
    if (!_numberFormatter2SigDigits) {
        _numberFormatter2SigDigits = [[NSNumberFormatter alloc] init];
        _numberFormatter2SigDigits.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter2SigDigits.maximumFractionDigits = 1;
        _numberFormatter2SigDigits.usesSignificantDigits = YES;
        _numberFormatter2SigDigits.maximumSignificantDigits = 2;
        _numberFormatter2SigDigits.minimumSignificantDigits = 1;
        _numberFormatter2SigDigits.roundingMode = NSNumberFormatterRoundHalfUp;
        _numberFormatter2SigDigits.zeroSymbol = @"0";
//        _numberFormatter2SigDigits.nilSymbol = @"0";
        _numberFormatter2SigDigits.nilSymbol = @"";
        _numberFormatter2SigDigits.notANumberSymbol = @"-";
    }
    return _numberFormatter2SigDigits;
}

-(NSNumberFormatter* )numberFormatter3SigDigits {
    if (!_numberFormatter3SigDigits) {
        _numberFormatter3SigDigits = [[NSNumberFormatter alloc] init];
        _numberFormatter3SigDigits.numberStyle = NSNumberFormatterNoStyle;
        _numberFormatter3SigDigits.usesSignificantDigits = YES;
        _numberFormatter3SigDigits.maximumSignificantDigits = 3;
        _numberFormatter3SigDigits.roundingMode = NSNumberFormatterRoundHalfUp;
        _numberFormatter3SigDigits.zeroSymbol = @"0";
//        _numberFormatter3SigDigits.nilSymbol = @"0";
        _numberFormatter3SigDigits.nilSymbol = @"";
        _numberFormatter3SigDigits.notANumberSymbol = @"-";
    }
    return _numberFormatter3SigDigits;
}


@end
