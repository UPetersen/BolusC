//
//  UPDetailViewController2.h
//  BolusCalc
//
//  Created by Uwe Petersen on 20.05.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import <UIKit/UIKit.h>
@import HealthKit;
#import "Event.h"
#import "Event+Extensions.h"  
#import "BSKeyboardControls.h" // for input accessory view above the keyboard (MIT-Licence)

@interface DetailViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, BSKeyboardControlsDelegate>

// Number formatters for text output in the cells
//@property (strong,nonatomic) NSNumberFormatter *numberFormatterForInput;


// Managed Object to be passed from MasterViewController
@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) id detailItem2;

// Section 0: Time (and date) and bloodSugar
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTime;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UITextField *textFieldBloodSugar;

// Section 1: Food/nutrient data
@property (weak, nonatomic) IBOutlet UITextField *textFieldEnergy;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCarb;
@property (weak, nonatomic) IBOutlet UITextField *textFieldProtein;
@property (weak, nonatomic) IBOutlet UITextField *textFieldFat;
@property (weak, nonatomic) IBOutlet UILabel *labelChu;
@property (weak, nonatomic) IBOutlet UILabel *labelFpu;


// Section 2: Correction and bolus for carbs
@property (weak, nonatomic) IBOutlet UILabel *labelShortBolus;

// Neue Section für Bolus-Insulin
@property (weak, nonatomic) IBOutlet UILabel *labelCorrectionBolus; // old
@property (weak, nonatomic) IBOutlet UITextField *textFieldCorrectionDivisor;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCorrectionBolus;
@property (weak, nonatomic) IBOutlet UISlider *sliderCorrectionFactor;

@property (weak, nonatomic) IBOutlet UILabel *labelChuBolus;        // old
@property (weak, nonatomic) IBOutlet UITextField *textFieldChuFactor;
@property (weak, nonatomic) IBOutlet UITextField *textFieldChuBolus;
@property (weak, nonatomic) IBOutlet UISlider *sliderChuFactor;


// Section 3: Bolus for fat and protein
@property (weak, nonatomic) IBOutlet UITableViewCell *cellFpuBolus; // old

@property (weak, nonatomic) IBOutlet UILabel *labelFpuBolus;       
@property (weak, nonatomic) IBOutlet UITextField *textFieldFpuFactor;
@property (weak, nonatomic) IBOutlet UITextField *textFieldFpuBolus;
@property (weak, nonatomic) IBOutlet UISlider *sliderFpuFactor;

// Section 4: Basal insulin
@property (weak, nonatomic) IBOutlet UITextField *textFieldBasal;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellNote;

// Section 5: Further input
@property (weak, nonatomic) IBOutlet UITextField *textFieldWeight;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;


// Methods 
//-(BOOL)calcAndDisplayResults;
-(void)setNewSliderRangeIfMaximumOrMinimumReached:(UISlider *)slider;


@end

// For the button used to dismiss keyboard in the detailview
UIBarButtonItem *dismissKeyboardButton; // "Fertig"-Button
UIBarButtonItem *saveButton;            // "Sichern"-Button
UIBarButtonItem *cancelButton;          // "Cancel"-Button

