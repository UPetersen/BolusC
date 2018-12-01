//
//  UPTimeAndDateViewController.m
//  BolusCalc
//
//  Created by Uwe Petersen on 02.06.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import "TimeAndDateViewController.h"
//#define VERBOSE

@interface TimeAndDateViewController ()

@end

@implementation TimeAndDateViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Add-Button ("+"-Button oben rechts) wird hier hinzugefügt und verweist auf Methode insertNewObject
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                               target:self
                                                                               action:@selector(saveTimeAndDate:)];
    self.navigationItem.rightBarButtonItem = saveButton;
#ifdef VERBOSE
    NSLog(@"In UPTimeAndDateViewController in viewDidLoad");
#endif
//    _pickerDateAndTime.date = _currentDateAndTime;  // hat funktioniert 
    
    
    // Get date from theObject
    _pickerDateAndTime.date = [self.theObject valueForKey:@"timeStamp"];
#ifdef VERBOSE
    NSLog(@"_pickerDateAndTime %@", _pickerDateAndTime.date);
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveTimeAndDate:(id) sender {
    
#ifdef VERBOSE
    NSLog(@"_pickerDateAndTime %@", _pickerDateAndTime.date);
#endif
    
    [self.theObject setValue:_pickerDateAndTime.date forKey:@"timeStamp"];

    // Save the context
    NSError * error = nil;
    NSManagedObjectContext *context =[self.theObject managedObjectContext]; // Get the managedObjectContext of the object
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Jump backwards, when save was pressed
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)pickerValueChanged:(id)sender {
}

//- (void)viewDidUnload {
//    [self setPickerDateAndTime:nil];
//    [super viewDidUnload];
//}
@end
