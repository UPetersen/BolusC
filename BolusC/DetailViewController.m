//
//  UPDetailViewController2.m
//  BolusCalc
//
//  Created by Uwe Petersen on 20.05.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//
// Bolus Calulation for Carbs, Fat and Protein
//
// ACHTUNG: Delegate Methods for text fields do only work, if the delegate is defined for each text field in the storyboard (control drag textfield to viewController at the bottom
#include <math.h>
#import "DetailViewController.h"
#import "TimeAndDateViewController.h"
#import "Event.h"
#import "NSNumber+UPNumberFormats.h"
#import "Event+Extensions.h"
#import "BSKeyboardControls.h" // for input accessory view above the keyboard (MIT-Licence)
#import "BolusC-Swift.h"

//#define VERBOSE

@interface DetailViewController ()

// Number formatters for label for shortBolus, e.g. "0,1 + 0,9 = 1 IE"
@property (strong, nonatomic) NSNumberFormatter *numberFormatterShortBolus;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter1Digits;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter2Digits;
@property (strong, nonatomic) NSNumberFormatter *numberFormatterBasal;

@property (strong, nonatomic) NSDateFormatter *dateFormatterForTime;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForDate;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

// BSKeyboardControls by Simon B. Stoevring, MIT-Licence for input accessory view above keyboard
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;


// Local NSManagedObjectContext
@property NSManagedObjectContext *managedObcectContect;

@property double energy;

@end


@implementation DetailViewController

# pragma mark - view controller stuff

- (void)awakeFromNib
{
    [super awakeFromNib];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // BSKeyboardControls to implement a keyboard input accessory view
    //Initialization stuff, i.e. the fields to be switched between and the order therefore
    NSArray *fields =@[self.textFieldBloodSugar, self.textFieldCorrectionDivisor, self.textFieldCorrectionBolus,
                       self.textFieldEnergy, self.textFieldCarb, self.textFieldProtein, self.textFieldFat,
                       self.textFieldChuFactor, self.textFieldChuBolus, self.textFieldFpuFactor,self.textFieldFpuBolus,
                       self.textViewComment, self.textFieldWeight, self.textFieldBasal];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
    //    [self setNumberFormatter:[NSNumberFormatter new]];
    
    // set a tap gesture recognizer to dismiss the keyboard (single tap anywhere aside the keyboard)
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tapRecognizer.cancelsTouchesInView = NO;        // taps are delivered to the view (otherwhise cells cannot be selected any more)
    [self.view addGestureRecognizer:tapRecognizer];
    
    // Button to save the data
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Override back button with "cancel"-button
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo   target:self action:@selector(cancelButtonPressed:)];
    //UIBarButtonSystemItemCancel
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Button to dismiss the keyboard, it is displayed while the keyboard is displayed
    dismissKeyboardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveButtonPressed:)];
}

-(void)viewWillAppear:(BOOL)animated {
    
    // A C H T U N G  Wird gebraucht für automatisches Scrollen wenn das Keyboard erscheint!!
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



# pragma mark - handle sliders and textfields for correctionBolus, chuBolus, fpuBolus

/*
 ***** Correction Bolus with logarithmic function for slider value (or 10^n if you look at it the other way round) ****** 
 */
- (IBAction)textFieldCorrectionDivisorChanged:(id)sender {
    // Slider uses value from 0 to -2 which correspond to Divisor values from  1/10^0 = 1/1 = 1 to 1/10^-3 = 1/0.001 = 1000
    // The slider value is thus a power of 10 (and then multiplied with minus 1 to reverse the direction)
    self.event.correctionDivisor = [self.numberFormatter numberFromString:self.textFieldCorrectionDivisor.text];  // textfield correctionDivisor     -> correctionDivisor
    
    [self.event setCorrectionBolusForCorrectionDivisorForBloodSugarForBloodSugarGoal];                // correctionDivisor, bloodSugar's -> correctionBolus
    [self displayCorrectionBolus];                                                                    // correctionBolus                 -> textfield for correctionBolus

    self.sliderCorrectionFactor.value = -log10(self.event.correctionDivisor.floatValue);              // correctionDivisor               -> slider for correctionDivisor
    
    [self.event setShortBolusForCorrectionBolusForChuBolus];                                          // correctionBolus, chuBolus       -> shortBolus
    [self displayShortBolus];                                                                         // shortBolus                      -> label for shortBolus
}
- (IBAction)textFieldCorrectionBolusChanged:(id)sender {

    // Slider uses value from 0 to -2 which correspond to Divisor values from  1/10^0 = 1/1 = 1 to 1/10^-3 = 1/0.001 = 1000
    // The slider value is thus a power of 10 (and then multiplied with minus 1 to reverse the direction)
    self.event.correctionBolus = [self.numberFormatter numberFromString:self.textFieldCorrectionBolus.text];      // textfield correctionBolus       -> correctionBolus
    
    [self.event setCorrectionDivisorForCorrectionBolusForBloodSugarForBloodSugarGoal];                // correctionBolus, bloodSugar's   -> correctionDivisor
    self.sliderCorrectionFactor.value = -log10(self.event.correctionDivisor.floatValue);              // correctionDivisor               -> slider for correctionDivisor
    
    [self displayCorrectionDivisor];                                                                  // correctionDivisor               -> textfield for correctionDivisor
    
    [self.event setShortBolusForCorrectionBolusForChuBolus];                                          // correctionBolus, chuBolus       -> shortBolus
    [self displayShortBolus];                                                                         // shortBolus                      -> label for shortBolus
}
- (IBAction)sliderCorrectionFactorChanged:(id)sender {
    
    // Slider uses value from 0 to -2 which correspond to Divisor values from  1/10^0 = 1/1 = 1 to 1/10^-3 = 1/0.001 = 1000
    // The slider value is thus a power of 10 (and then multiplied with minus 1 to reverse the direction)
    self.event.correctionDivisor = [[NSNumber alloc]
                                initWithFloat: pow(10., -self.sliderCorrectionFactor.value) ];        // slider correctionDivisor        -> correctionDivisor
    
    [self.event setCorrectionBolusForCorrectionDivisorForBloodSugarForBloodSugarGoal];                // correctionDivisor, bloodSugar's -> correctionBolus
    [self displayCorrectionBolus];                                                                    // correctionBolus                 -> textfield for correctionBolus

    [self displayCorrectionDivisor];                                                                  // correctionDivisor               -> textfield for correctionDivisor

    [self.event setShortBolusForCorrectionBolusForChuBolus];                                          // correctionBolus, chuBolus       -> shortBolus
    [self displayShortBolus];                                                                         // shortBolus                      -> label for shortBolus
}

/*
 ***** Bolus for carbs ********************************************************************************
 */

- (IBAction)textFieldChuFactorChanged:(id)sender {

    self.event.chuFactor = [self.numberFormatter numberFromString:self.textFieldChuFactor.text]; // textfield for chuFa ctor  -> chuFactor
    
    [self.event setChuBolusForChuFactorForChu];                                                  // chuFactor, chu            -> chuBolus
    [self displayChuBolus];                                                                      // chuBolus                  -> texfield for chuBolus
    
//    [self.event setChuFactorToChuFactorDefaultValueIfNil];                                     // chuFactor                 -> default value (after calculations) if set to nil
//    [self displayChuFactor];                                                                   // chuFactor                 -> textfield for chuFactor
    self.sliderChuFactor.value = self.event.chuFactor.floatValue;                                // chuFactor                 -> sliderValue
    [self setNewSliderRangeIfMaximumOrMinimumReached:[self sliderChuFactor]];                    // Extend (double) the range of the Slider if user reaches maximum value
    
    [self.event setShortBolusForCorrectionBolusForChuBolus];                                     // correctionBolus, chuBolus -> shortBolus
    [self displayShortBolus];                                                                    // shortBolus                -> label for shortBolus
}
- (IBAction)textFieldChuBolusChanged:(id)sender {
    
    self.event.chuBolus = [self.numberFormatter numberFromString:self.textFieldChuBolus.text];   // textfield for chuBolus    -> chuBolus
    
    [self.event setChuFactorForChuBolusForChu];                                                  // chuBolus, chu             -> chuFactor
//    [self.event setChuFactorToChuFactorDefaultValueIfNil];                                     // chuFactor                 -> default value (after calculations) if set to nil

    [self displayChuFactor];                                                                     // chuFactor                 -> textfield for chuFactor
    self.sliderChuFactor.value = self.event.chuFactor.floatValue;                                // chuFactor                 -> sliderValue

    [self.event setShortBolusForCorrectionBolusForChuBolus];                                     // correctionBolus, chuBolus -> shortBolus
    [self displayShortBolus];                                                                    // shortBolus                -> label for shortBolus
}
- (IBAction)sliderChuFactorChanged:(id)sender {

    self.event.chuFactor = [[NSNumber alloc] initWithFloat:self.sliderChuFactor.value];    // sliderValue for chuFactor -> chuFactor
    
    [self.event setChuBolusForChuFactorForChu];                                            // chuFactor, chu            -> chuBolus
    [self displayChuBolus];                                                                // chuBolus                  -> texfield for chuBolus
    
    [self displayChuFactor];                                                               // chuFactor                 -> textfield for chuFactor
    [self setNewSliderRangeIfMaximumOrMinimumReached:[self sliderChuFactor]];              // Extend (double) the range of the Slider if user reaches maximum value
    
    [self.event setShortBolusForCorrectionBolusForChuBolus];                               // correctionBolus, chuBolus -> shortBolus
    [self displayShortBolus];                                                              // shortBolus                -> label for shortBolus
}
/*
 ***** Bolus for fat and protein ***********************************************************************
 */
- (IBAction)textFieldFpuFactorChanged:(id)sender {

    self.event.fpuFactor = [self.numberFormatter numberFromString:self.textFieldFpuFactor.text];   // textField for fpuFactor   -> fpuFactor
    
    [self.event setFpuBolusForFpuFactorForFpu];                                                // fpuFactor, fpu            -> fpuBolus
    [self displayFpuBolus];                                                                // fpuBolus                  -> textfield for fpuBolus

//    [self.event setFpuFactorToFpuFactorDefaultValueIfNil];                                     // fpuFactor                 -> default value (after calculations) if set to nil
//    [self displayFpuFactor];                                                               // fpuFactor                 -> textfield for fpuFactor
    self.sliderFpuFactor.value = self.event.fpuFactor.floatValue;                                  // fpuFactor                 -> Move slider accordingly
}

- (IBAction)textFieldFpuBolusChanged:(id)sender {

    self.event.fpuBolus = [self.numberFormatter numberFromString:self.textFieldFpuBolus.text];     // textField for fpuBolus    -> fpuBolus
    
    [self.event setFpuFactorForFpuBolusForFpu];                                                // fpuBolus, fpu             -> fpuFactor
//    [self.event setFpuFactorToFpuFactorDefaultValueIfNil];                                     // fpuFactor                 -> default value (after calculations) if set to nil
    
    [self displayFpuFactor];                                                               // fpuFactor                 -> textfield for fpuFactor
    self.sliderFpuFactor.value = self.event.fpuFactor.floatValue;                                  // fpuFactor                 -> Move slider accordingly
    
    NSLog(@"In fpuBolusChanged, event: %@", self.event);
}

- (IBAction)sliderFpuFactorChanged:(id)sender {
    self.event.fpuFactor = [[NSNumber alloc] initWithFloat:self.sliderFpuFactor.value];        // Slidervalue for fpuFactor -> fpuFactor

    [self.event setFpuBolusForFpuFactorForFpu];                                                // fpuFactor, fpu            -> fpuBolus
    [self displayFpuBolus];                                                                // fpuBolus                  -> textfield for fpuBolus

//    [self.event setFpuFactorToFpuFactorDefaultValueIfNil];                                     // fpuFactor                 -> default value (after calculations) if set to nil
    [self displayFpuFactor];                                                               // fpuFactor                 -> textfield for fpuFactor
//    self.sliderFpuFactor.value = self.event.fpuFactor.floatValue;                                  // fpuFactor                 -> Move slider accordingly
    [self setNewSliderRangeIfMaximumOrMinimumReached:[self sliderFpuFactor]];              // Extend (double) the range of the Slider if user reaches maximum value
}

- (IBAction)textFieldBloodSugarChanged:(id)sender {
}
- (IBAction)textFieldEnergyChanged:(id)sender {
}
- (IBAction)textFieldCarbChanged:(id)sender {
}
- (IBAction)textFieldProteinChanged:(id)sender {
}
- (IBAction)textFieldFatChanged:(id)sender {
}
- (IBAction)textFieldBasalChanged:(id)sender {
}


// Method that is called, when another field is chosen, button is pressed or the key "enter"/"next"/"return"/"done" is pressed
// Method is used here to
//    a) assign values that where entered to object
//    b) call method that does all the calulations and display the result
- (BOOL)textFieldShouldEndEditing:(UITextField *)theTextField {
    
//    NSLog(@"Within method textFieldShouldEndEditing with %@", theTextField.description);
    
    if (theTextField == self.textFieldBloodSugar) {
        self.event.bloodSugar = [self.numberFormatter numberFromString:self.textFieldBloodSugar.text]; // textfield                       -> bloodsugar
        [self displayBloodSugarBloodSugarGoal];                                                        // bloodSugar's                    -> label for bloodSugar's
        
        [self.event setCorrectionBolusForCorrectionDivisorForBloodSugarForBloodSugarGoal];         // correctionDivisor, bloodSugar's -> correctionBolus
        [self displayCorrectionBolus];                                                             // correctionBolus                 -> textfield for correctionBolus
        
        [self.event setShortBolusForCorrectionBolusForChuBolus];                                   // correctionBolus, chuBolus       -> shortBolus
        [self displayShortBolus];                                                                  // shortBolus                      -> label for shortBolus
       
    }
    else if (theTextField == self.textFieldEnergy){
        self.event.energy = [self.numberFormatter numberFromString:self.textFieldEnergy.text];
    }
    else if (theTextField == self.textFieldCarb){
        self.event.carb = [self.numberFormatter numberFromString:self.textFieldCarb.text];    // textfield       -> carb
        [self.event setChuForCarb];                                                           // carb            -> chu
        [self displayChu];
        
        [self.event setChuBolusForChuFactorForChu];                                           // chu, chuFactor  -> chuBolus
        [self displayChuBolus];                                                               // chuBolus        -> textfield for chuBolus

        [self.event setShortBolusForCorrectionBolusForChuBolus];                                   // correctionBolus, chuBolus       -> shortBolus
        [self displayShortBolus];                                                                  // shortBolus                      -> label for shortBolus
    }
    else if (theTextField == self.textFieldProtein){
        self.event.protein = [self.numberFormatter numberFromString:self.textFieldProtein.text];  // textfield       -> protein
        [self.event setFpuForFatForProtein];                                                      // fat, protein    -> fpu
        [self displayFpu];

        [self.event setFpuBolusForFpuFactorForFpu];                                           // fpuFactor, fpu  -> fpuBolus
        [self displayFpuBolus];                                                               // fpuBolus        -> textfield for fpuBolus
    }
    else if (theTextField == self.textFieldFat){
        self.event.fat = [self.numberFormatter numberFromString:self.textFieldFat.text];      // textfield       -> fat
        [self.event setFpuForFatForProtein];                                                  // fat, protein    -> fpu
        [self displayFpu];
        
        [self.event setFpuBolusForFpuFactorForFpu];                                           // fpuFactor, fpu  -> fpuBolus
        [self displayFpuBolus];                                                               // fpuBolus        -> textfield for fpuBolus

    }
    else if (theTextField == self.textFieldChuFactor){
        return YES;
    }
    else if (theTextField == self.textFieldFpuFactor){
        return YES;
    }
    else if (theTextField == self.textFieldCorrectionDivisor){
        return YES;
    }
    else {
        return YES; // mandatory here, to prevent that calcAndDisplayResults is called before other necessary calculations are performed for other textfields
    }
    
//    [self calcAndDisplayResults]; // Do all the calculations and display results
    [self dismissKeyboard];
    
    return YES;
}

#pragma mark - Uwis Managing the detail item

// Warum wird der Setter des properties hier überschrieben? Damit die View-Inhalte aktualisiert werden, falls sich der Inhalt des managedObjects geändert hat

//- (void)setDetailItem:(id)newDetailItem
//{
//    if (_detailItem2 != newDetailItem) {
//        _detailItem2 = newDetailItem;
//        
//        // Update the view.
//        [self configureView];
//    }
//}

- (void)configureView
{
    // Update the user interface from the managedObject 
    if (self.event) {

        // Textfelder belegen -----------------------------------------------------------------------
        // Set initial values into the text fields from coredata managedObject
#ifdef VERBOSE
        NSLog(@"self.labelDate.description %@", self.labelDate.description);
        NSLog(@"self.labelTime.description %@", self.labelTime.description);
#endif
        self.labelTime.text = [self.dateFormatterForTime stringFromDate:self.event.timeStamp];
        self.labelDate.text = [self.dateFormatterForDate stringFromDate:self.event.timeStamp];
        
#ifdef VERBOSE
        NSLog(@"self.labelDate.text %@", self.labelDate.text);
        NSLog(@"self.labelDate.description %@", self.labelDate.description);
        NSLog(@"self.labelTime.description %@", self.labelTime.description);
#endif
        self.textFieldBloodSugar.text   = [self.event.bloodSugar    stringWithNumberStyle1maxDigits];
        self.textFieldEnergy.text       = [self.event.energy        stringWithNumberStyle1maxDigits];
        self.textFieldCarb.text         = [self.event.carb          stringWithNumberStyle1maxDigits];
        self.textFieldProtein.text      = [self.event.protein       stringWithNumberStyle1maxDigits];
        self.textFieldFat.text          = [self.event.fat           stringWithNumberStyle1maxDigits];
        self.textFieldBasal.text        = [self.event.basalDosis    stringWithNumberStyle1maxDigits];
        self.textViewComment.text       =  self.event.comment;
        self.textFieldWeight.text       = [self.event.weight        stringWithNumberStyle1maxDigits];
        
        // Set initial values for Textfields and Sliders from Settings (to be done after view has loaded, not available in awakeFromNib)
        self.sliderCorrectionFactor.value = -log10(self.event.correctionDivisor.floatValue);
        self.sliderChuFactor.value = self.event.chuFactor.doubleValue;
        self.sliderFpuFactor.value = self.event.fpuFactor.doubleValue;
        
        [self displayChu];
        [self displayChuFactor];
        [self displayChuBolus];

        [self displayBloodSugarBloodSugarGoal];
        [self displayCorrectionDivisor];
        [self displayCorrectionBolus];
        [self displayShortBolus];

        
        [self displayFpu];
        [self displayFpuFactor];
        [self displayFpuBolus];
        
        [self.tableView reloadData]; 
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
//-(UIView *)inputAccessoryView {
//    if (!inputAccessoryView) {
//        CGRect accessFrame = CGRectMake(0.0, 0.0, 768.0, 77.0);
//        inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
//        inputAccessoryView.backgroundColor = [UIColor blueColor];
//        UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        compButton.frame = CGRectMake(313.0, 20.0, 158.0, 37.0);
//        [compButton setTitle: @"Word Completions" forState:UIControlStateNormal];
//        [compButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [compButton addTarget:self action:@selector(completeCurrentWord:)
//             forControlEvents:UIControlEventTouchUpInside];
//        [inputAccessoryView addSubview:compButton];
//    }
//    return inputAccessoryView;
//}

# pragma mark -- Stuff to dismiss the keyboard

// Selector for gesture recognizer, called if a single tap is recognized to dismiss the keyboard
-(void)tap:(UIGestureRecognizer *)tapRecognizer
{
    [self.view endEditing:YES];
}

// Set keyboard and "Fertig"-Button for textView (the comment field)
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem = dismissKeyboardButton;
    textView.returnKeyType = UIReturnKeyDefault;
    
    [self.keyboardControls setActiveField:textView]; // For input accessory view above keyboard

}
// Set keyboard and "Fertig" button for textfields (all numbers, thus decimal pad), overrules settings in storyboard
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem = dismissKeyboardButton;
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    
    [self.keyboardControls setActiveField:textField]; // For input accessory view above keyboard

}
// Dismiss the keyboard and set regular save button when "Fertig" is pressed or the keyboard is resigned otherwhise
-(void)dismissKeyboard
{
    [self.view endEditing:YES];                             // dismiss the keyboard
    self.navigationItem.rightBarButtonItem = saveButton;    // display regular save button
}


#pragma mark - Table view data source


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
      { *detailViewController = [[ alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
#ifdef VERBOSE
    NSLog(@"didSelectRowAtIndexPath: wurde aufgerufen");
#endif
}


-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"IndexPath is %@", indexPath);
    if (indexPath.section == 3) {
        if (indexPath.row == 3) {
            [self authorizeHealthKit];
        } else if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
            // Get data from HealthKit
            [self syncNutrientsFromHealthKitForDate: self.event.timeStamp];
        }
    }
}



#pragma mark - HealthKit


- (IBAction)authorizeHealthKitSelected:(UIButton *)sender {
    [self authorizeHealthKit];
}
- (IBAction)syncWithHealthKitSelected:(UIButton *)sender {
    [self syncNutrientsFromHealthKitForDate:self.event.timeStamp];
}

-(void) syncNutrientsFromHealthKitForDate:(NSDate *)date {
    
//    NSLog(@"in syncNutrients...");
//
//    HealthManager *healthManager = [[HealthManager alloc] init];
//    [healthManager readNutrientData:date completion:^(HKCorrelation * foodCorrelation, NSError * error) {
//        NSLog(@"Bin drin ");
//        if (error != nil) {
//            NSLog(@"Error reading nutrient date from HealthKit store: %@", error);
//            return;
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            for (HKQuantitySample *object in foodCorrelation.objects) {
//                NSLog(@"Im Loop");
//                if ([object isKindOfClass:[HKQuantitySample class]]) {
//                    if (object.quantityType == [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed]) {
//                        double hugo = [object.quantity doubleValueForUnit:[HKUnit kilocalorieUnit]];
//                        NSLog(@"hugo: %f", hugo);
//                        self.event.energy = [NSNumber numberWithDouble:hugo];
//
//                    } else if (object.quantityType == [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates]) {
//                        self.event.carb = [NSNumber numberWithDouble: [object.quantity doubleValueForUnit:[HKUnit gramUnit]]];
//                        [self.event setChuForCarb];                                                           // carb            -> chu
//                        [self.event setChuBolusForChuFactorForChu];                                           // chu, chuFactor  -> chuBolus
//                        [self.event setShortBolusForCorrectionBolusForChuBolus];
//
//
//                    } else if (object.quantityType == [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein]) {
//                        self.event.protein = [NSNumber numberWithDouble: [object.quantity doubleValueForUnit:[HKUnit gramUnit]]];
//                        [self.event setFpuForFatForProtein];                                                      // fat, protein    -> fpu
//                        [self.event setFpuBolusForFpuFactorForFpu];                                           // fpuFactor, fpu  -> fpuBolus
//
//                    } else if (object.quantityType == [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal]) {
//                        self.event.fat = [NSNumber numberWithDouble: [object.quantity doubleValueForUnit:[HKUnit gramUnit]]];
//                        [self.event setFpuForFatForProtein];                                                  // fat, protein    -> fpu
//                        [self.event setFpuBolusForFpuFactorForFpu];                                           // fpuFactor, fpu  -> fpuBolus
//                    }
//                }
//            }
//            [self configureView];
//        });
//    }];
}

-(void)authorizeHealthKit {
    HealthManager *healthManager = [[HealthManager alloc] init];
    [healthManager authorizeHealthKitWithCompletion:^(BOOL authorized, NSError * error) {
        if (authorized) {
            NSLog(@"Healthkit authorization received");
        } else {
            NSLog(@"Healthkit authorization denied");
            if (error != nil) {
                NSLog(@"Error is %@", error);
            }
        }
    }];
}



//- (void)viewDidUnload {
//    [self setTextFieldBloodSugar:nil];
//    [self setTextFieldEnergy:nil];
//    [self setTextFieldCarb:nil];
//    [self setTextFieldProtein:nil];
//    [self setTextFieldFat:nil];
//    [self setCellTime:nil];
//    [self setTextFieldChuFactor:nil];
//    [self setSliderChuFactor:nil];
//    [self setCellFpuBolus:nil];
//    [self setTextFieldFpuFactor:nil];
//    [self setSliderFpuFactor:nil];
//    [self setTextFieldBasal:nil];
//    [self setCellNote:nil];
//    [self setLabelCorrectionBolus:nil];
//    [self setLabelChuBolus:nil];
//    [self setLabelShortBolus:nil];
//    [self setLabelChuBolus:nil];
//    [self setLabelFpuBolus:nil];
//    [self setLabelChu:nil];
//    [self setLabelFpu:nil];
//    [self setLabelTime:nil];
//    [self setTextFieldWeight:nil];
//    [self setTextFieldCorrectionBolus:nil];
//    [self setTextFieldCorrectionDivisor:nil];
//    [self setSliderCorrectionFactor:nil];
//    [self setTextFieldChuBolus:nil];
//    [self setTextFieldFpuBolus:nil];
//    [self setTextViewComment:nil];
//    [self setLabelDate:nil];
//    [self setKeyboardControls:nil];
//
//    [super viewDidUnload];
//}


# pragma mark - helper methods

-(void) displayShortBolus {

    self.labelShortBolus.text = [[NSString alloc] initWithFormat:@"%@ + %@ = %@",
                             [self.numberFormatterShortBolus stringForObjectValue:self.event.correctionBolus],
                             [self.numberFormatterShortBolus stringForObjectValue:self.event.chuBolus],
                             [self.numberFormatterShortBolus stringForObjectValue:self.event.shortBolus]];
}

-(void) displayBloodSugarBloodSugarGoal {
    self.labelCorrectionBolus.text = [[NSString alloc] initWithFormat:@"(%@ -%@) /",
                                  [self.numberFormatter stringForObjectValue:self.event.bloodSugar],
                                  [self.numberFormatter stringForObjectValue:self.event.bloodSugarGoal]];
}
-(void) displayCorrectionDivisor {
    self.textFieldCorrectionDivisor.text = [[NSString alloc] initWithFormat:@"%@", [self.numberFormatter stringForObjectValue:self.event.correctionDivisor]];
}
-(void) displayCorrectionBolus {
    self.textFieldCorrectionBolus.text = [self.event.correctionBolus stringWithNumberStyle1maxDigits];
}
-(void) displayChu {
    self.labelChu.text      = [[NSString alloc] initWithFormat: @"KHE: %@", [self.numberFormatter2Digits stringForObjectValue:self.event.chu] ];
    self.labelChuBolus.text = [[NSString alloc] initWithFormat: @"%@ KHE x",[self.numberFormatter2Digits stringForObjectValue:self.event.chu]];
}
-(void) displayChuBolus {
    self.textFieldChuBolus.text = [self.event.chuBolus stringWithNumberStyle1maxDigits];
}
-(void) displayChuFactor {
    self.textFieldChuFactor.text = [self.event.chuFactor stringWithNumberStyle2maxDigits];
}

-(void) displayFpu {
    // fpu -> Label for fpu (in meal area)
    self.labelFpu.text = [[NSString alloc] initWithFormat: @"FPE: %@", [self.numberFormatter2Digits stringForObjectValue:self.event.fpu] ];

    // fpu -> label for fpu in Bolus calculation area
    self.labelFpuBolus.text = [[NSString alloc] initWithFormat:@"%@ FPE x", [self.numberFormatter2Digits stringForObjectValue:self.event.fpu]];
}

-(void) displayFpuBolus {
    self.textFieldFpuBolus.text = [self.event.fpuBolus stringWithNumberStyle1maxDigits];
//    self.textFieldFpuBolus.text = [[NSString alloc] initWithFormat:@"%@", [self.numberFormatter stringForObjectValue:self.event.fpuBolus]];
}
-(void) displayFpuFactor {
    self.textFieldFpuFactor.text = [self.event.fpuFactor stringWithNumberStyle2maxDigits];
//    self.textFieldFpuFactor.text = [[NSString alloc] initWithFormat:@"%@", [self.numberFormatter2Digits stringForObjectValue:self.event.fpuFactor]];
}


// If a slider was moved to its maximum value by the user, this changes the maximum value of the slider (double the range of the slider),
// If the slider was moved to the lower end (i.e. zero), the maximum value is reset to 2.0
-(void)setNewSliderRangeIfMaximumOrMinimumReached:(UISlider *)slider {
    
    [slider setContinuous:YES];                     // Continously adjust all calculations (done all the time)
    
    double maxVal = [slider maximumValue];           // Current maximum value of slider
    if ([slider value] >= maxVal) {                 // check if current value reaches maximum value
        [slider setContinuous:NO];                  // Wait for new value update until slider was released by user (done once, if maximum reached)
        // this is needed to prevent from continously extending the maximum value (repeating this here)
        [slider setMaximumValue:maxVal * 2.0];      // set new maximum value, slider is moved to actual value (i.e. to middle of the new range)
    }
    else if ([slider value] <= 0 ){
        [slider setMaximumValue:2.0];               // set new maximum value to 2.0
        [slider setContinuous:NO];                  // Wait for new value update until slider was released by user (done once, if maximum reached)
    }
}
-(void)cancelButtonPressed:(id)sender {
#ifdef VERBOSE
    NSLog(@"in cancelButtonPressed");
#endif
    
    NSManagedObjectContext *context =[self.event managedObjectContext]; // Get the managedObjectContext of the object
    [context.undoManager endUndoGrouping];                          // end collection undo information
    [context.undoManager undo];                                     // undo changes that have been made so far

    // Jump to parent controller
    [self.navigationController popViewControllerAnimated:YES];
}

// Called whenn the save button was pressed
// TODO: Meanwhile this is called programmatically and the IBAction may be changed to void and disconnected in storyboard
- (IBAction)saveButtonPressed:(id)sender {
    
    // If appropriate, configure the new managed object.
#ifdef VERBOSE
    NSLog(@"in saveButtonPressed-Method");
#endif
    
    // TODO: Nochmal überlegen, ob das mit den Berechnungsketten der richtige Weg ist, da es dann keine Setter-Möglichkeiten gibt, was hier manchmal besser wäre
    
    self.event.basalDosis       = [self.numberFormatterBasal numberFromString:self.textFieldBasal.text];
    self.event.comment          = self.textViewComment.text;
    self.event.weight           = [self.numberFormatterBasal numberFromString:self.textFieldWeight.text];

    NSManagedObjectContext *context =[self.event managedObjectContext]; // Get the managedObjectContext of the object

    // Reset the undo manager (aka don't undo anything)
    [context.undoManager endUndoGrouping];                          // end collection undo information
    [context.undoManager removeAllActions];                         // clear the undo stack and re-enable the receiver
    
    // Save the context (aka all changes made in this view)
    NSError * error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    // Jump backwards, when save was pressed
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@" identifier des segues ist %@",segue.identifier.description);
    if ([[segue identifier] isEqualToString:@"segueSetTimeAndDate"]) {
        NSLog(@"Segue segueSetDateAndTime");
        
        
        // TODO: Dritter Versuch, nun mit Object selbst. Das muss noch vereinfacht werden. Das muss ohne das komplette ManagedObject gehen
//        [[segue destinationViewController] setTheObject:self.detailItem2];
        [[segue destinationViewController] setTheObject:self.event];
    }
}

#pragma mark - Keyboard Controls Delegate

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    // Move content such that the selected field is viewable
    UIView *view = keyboardControls.activeField.superview.superview.superview;
    [self.tableView scrollRectToVisible:view.frame animated:YES];
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
}

#pragma mark - Number Formatters

-(NSNumberFormatter *) numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [NSNumberFormatter new];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.maximumFractionDigits = 1;
        _numberFormatter.roundingMode = NSNumberFormatterRoundHalfUp;
        _numberFormatter.zeroSymbol = @"0";
    }
    return _numberFormatter;
}
-(NSNumberFormatter *) numberFormatter2Digits {
    if (!_numberFormatter2Digits) {
        _numberFormatter2Digits = [NSNumberFormatter new];
        _numberFormatter2Digits.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter2Digits.maximumFractionDigits = 2;
        _numberFormatter2Digits.roundingMode = NSNumberFormatterRoundHalfUp;
        _numberFormatter2Digits.zeroSymbol = @"0";
    }
    return _numberFormatter2Digits;
}
-(NSNumberFormatter *) numberFormatterShortBolus {
    if(!_numberFormatterShortBolus) {
        _numberFormatterShortBolus = [NSNumberFormatter new];
        _numberFormatterShortBolus.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatterShortBolus.maximumFractionDigits = 1;
        _numberFormatterShortBolus.roundingMode = NSNumberFormatterRoundHalfUp;
        _numberFormatterShortBolus.zeroSymbol = @"0";
        _numberFormatterShortBolus.nilSymbol = @"0";
    }
    return _numberFormatterShortBolus;
}
-(NSNumberFormatter * ) numberFormatterBasal {
    if (!_numberFormatterBasal) {
        _numberFormatterBasal = [[NSNumberFormatter alloc] init];
        _numberFormatterBasal.numberStyle = NSNumberFormatterNoStyle;
        _numberFormatterBasal.maximumFractionDigits = 1;
        _numberFormatterBasal.roundingMode = NSNumberFormatterRoundHalfUp;
        _numberFormatterBasal.zeroSymbol = @"0";
        _numberFormatterBasal.nilSymbol = @"";
        _numberFormatterBasal.notANumberSymbol = @"-";
    }
    return _numberFormatterBasal;
}


-(NSDateFormatter *) dateFormatterForDate {
    if (!_dateFormatterForDate) {
        _dateFormatterForDate = [[NSDateFormatter alloc] init];  // Initialize Date Formatter
        _dateFormatterForDate.dateFormat = @"HH:mm";                          // Specify the date format
    }
    return _dateFormatterForDate;
}
-(NSDateFormatter *) dateFormatterForTime {
    if (!_dateFormatterForTime) {
        _dateFormatterForTime = [[NSDateFormatter alloc] init];  // Initialize Date Formatter
        _dateFormatterForTime.dateFormat = @"dd. MMMM yyyy";                   // Specify the date format
    }
    return _dateFormatterForTime;
}
//-(NSDateFormatter *)dateFormatter {
//    if (!_dateFormatter) {
//        _dateFormatter = [[NSDateFormatter alloc] init];
//        _dateFormatter.dateFormat = @"HH:MM Uhr, dd. MMM yyyy";
//    }
//    return _dateFormatter;
//}


//// Method that is called, when key "enter"/"next"/"return"/"done" is pressed in the textField that is currently edited
//// Method is used here to
////    a) move cursor between text fields,
////    b) resign keyboard (after entering Protein or FPU-Factor)
////    c) assign values that where entered to object
////    d) call method that does all the calulations and display the result
//- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
//
//    NSLog(@"Within method textFieldShouldReturn");
//
//    if (theTextField == self.textFieldEnergy){
//        [self.textFieldCarb becomeFirstResponder];        // move keyoard cursor to next textfield
//    }
//    else if (theTextField == self.textFieldCarb){
//        [self.textFieldProtein becomeFirstResponder];     // move keyboard cursor to next textfield
//    }
//    else if (theTextField == self.textFieldProtein){
//        [self.textFieldFat becomeFirstResponder];         // move keyboard cursor to next textfield
//    }
//    else if (theTextField == self.textFieldChuFactor){
//        [self.textFieldFpuFactor becomeFirstResponder];   // move keyboard cursor to next textfield
//    }
//    else {
//        [theTextField resignFirstResponder];              // resign keyboard for any other textfield
//    }
//
//    [self dismissKeyboard];
//    return YES;
//}


@end
