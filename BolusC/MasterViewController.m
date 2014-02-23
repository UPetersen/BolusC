//
//  UPMasterViewController.m
//  BolusCalc
//
//  Created by Uwe Petersen on 20.05.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//
//  Merken CoreData:
//     id und Tabellen. Es gibt keine id wie bei einer Datenbank. Es können über den fetch Tabellenzeilen ausgewählt werden und in einem Tableview dargestellt werden. Über eine entsprechende Selektion einer Tableview-Zeile hat man dann die gesuchte gewünschte Zeile der Coredata-Datenbank ohne jemals eine id zu benötigen. Auch die Darstellung wird nicht über ID's sortiert sondern über die fetch-Abfrage mit Sortier-Kriterium (wahrscheinlich wird das ohne Kriterium aber dann auch nach der Einfüge-Reihenfolge sortiert.
//     Segue: Mit dem Segue können Pointer auf Objekte übergeben werden. Hiermit kann auch der Pointer auf eine "Zeile" des Core-Data-Datensatzes mit übergeben werden und dann im aufgerufenen ViewController manipuliert werden. Dazu muss im untergeordenten ViewController eine Property mit "id" definiert sein, dass vom MasterviewController dann einfach mit diesem Pointer gesetzt wird. Wird dann vom DetailviewController wieder zurück zum MasterviewController geschaltet, sind die Daten entsprechend geändert.
//  Beim Rücksprung muss dann irgendwie noch der Context gesaved werden. Wie das funktioniert weiss ich noch nicht.

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NSNumber+UPNumberFormats.h"
#import "TVCell.h"
#import "DiaryTableViewCell.h"
#import "AppDelegate.h"

//#define VERBOSE

@interface MasterViewController ()

// Number and date formatters for text output in the cells
@property (strong,nonatomic) NSNumberFormatter *numberFormatter1Digit;
@property (strong,nonatomic) NSNumberFormatter *numberFormatter2SigDigits;
@property (strong,nonatomic) NSNumberFormatter *numberFormatter3SigDigits;
@property (strong,nonatomic) NSDateFormatter *dateTimeFormatter;
@property (strong,nonatomic) NSIndexPath *cellAtIndexPathRecentlyChanged; // nil, if none was recently changed

@property (strong, nonatomic) NSDateFormatter *dateFormatterForComparison;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForAnyDayInThePast;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForTheDayBeforeYesterday;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForYesterday;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForToday;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForTomorrow;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForTheDayAfterTomorrow;
@property (strong, nonatomic) NSDateFormatter *dateFormatterForAnyDayInTheFuture;


- (void)configureCell:(TVCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell2:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell3:(DiaryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)saveContext:(NSManagedObjectContext *)context;
- (UIColor *)colorForTimeOfDayFromDate:(NSDate *)theDate;


@end


@implementation MasterViewController


@synthesize managedObjectContext = _managedObjectContext;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Edit-Button to the left
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    // Add-Button to the right, ("+"-Button) wird hier hinzugefügt und verweist auf Methode insertNewObject
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
#ifdef VERBOSE
    // Test: alle Zeilen der Tabelle ausgeben, funktioniert nur im Simulator und nicht auf dem iPod, warum auch immer
    NSLog(@"MasterViewController (viewDidLoad): Test-output of all elements of the database:");
    for (Event *event in self.fetchedResultsController.fetchedObjects) {
        NSLog(@"Entity: %@", event.description);
    }
    
    // Test, um zu sehen, was hier ausgegeben wird.
    NSLog(@"NSManagedObjectContext-Info:%@", [self.fetchedResultsController.managedObjectContext   userInfo]);
    
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        // Path to save dictionary
        NSString  *dictPath = [[paths objectAtIndex:0]
                               stringByAppendingPathComponent:@"DictionaryContents.text"];
        NSString *dummyString = [[NSString alloc] initWithFormat:@"Hallo Uwi"];
        
        NSError *error = nil;
        [dummyString writeToFile:dictPath atomically:YES encoding:NSUTF8StringEncoding error:&error ];
        NSLog(@"dummyString: %@", dummyString);
        NSLog(@"dictPath: %@", dictPath);
    }
#endif
    
    // Aus Internet kopiert, für Backup der gesamten Datenbank:
//     [[NSFileManager defaultManager] copyItemAtPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"\db.sqlite\"] toPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"\db_backup.sqlite\"] error:nil];
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

//    [self.tableView reloadData];  // Some cells did cut of content (i.e. ended with "..."), trying to avoid this by reloading
    
//    if(self.cellAtIndexPathRecentlyChanged) {
//        [self.tableView endUpdates];
//        [self configureCell:[self.tableView cellForRowAtIndexPath:self.cellAtIndexPathRecentlyChanged]
//                atIndexPath:self.cellAtIndexPathRecentlyChanged];
//        self.cellAtIndexPathRecentlyChanged = nil;
    
//    }
    

    

    
    
/*
    // ACHTUNG: Erster eigener Fetch auf die Datenbank. Hat funktioniert mit dem kompletten Core Data aufrufen aus dem appDelegate hier integriert. Sonst tut's nicht so.
    // Test mit eigenem Fetch (alle Blutzuckerwerte über 200, (siehe "core data programming guide", S. 34) Fetch definieren und dem model zuordnen
    //
    NSFetchRequest *requestTemplate = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [[self.managedObjectModel entitiesByName] objectForKey:@"Event"];
    [requestTemplate setEntity:entityDesc];
    NSLog(@"entityDesc %@", entityDesc);
    NSLog(@"requestTemplate %@",requestTemplate);
    
    NSPredicate *predicateTemplate = [ NSPredicate predicateWithFormat:@"(bloodSugar > $BLOOD_SUGAR)"]; // Vergleichsregel mit Platzhalter (das SELECT)
    [requestTemplate setPredicate:predicateTemplate];                                                   // Mit aufnehmen in request
    NSLog(@"requestTemplate %@",requestTemplate);
    
    [self.managedObjectModel setFetchRequestTemplate:requestTemplate forName:@"BloodSugarOver200"];     // Dem request einen Namen geben für späteren Aufruf
    NSLog(@"managedObjectModel %@", self.managedObjectModel);
    
    // Test mit eigenem Fetch: fetch ausführen
    NSError *error = nil;
    NSDictionary *substitutionDictionary = [NSDictionary dictionaryWithObjectsAndKeys: @200, @"BLOOD_SUGAR", nil]; // Der eigentliche Vergleich (also Befüllung obiger Platzhalter mit 200)
    // Fetch erzeugen im Model mit allen vorherigen Informationen
    NSFetchRequest *fetchRequest = [self.managedObjectModel fetchRequestFromTemplateWithName:@"BloodSugarOver200" substitutionVariables:substitutionDictionary];
    
    NSLog(@"fetchRequest %@", fetchRequest);
    
    // Fetch ausführen. Das funktioniert so wie hier
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"result ist %@", results.description);
    
    // Nachfolgender Versuch mit einem eigenem MangedObjectContext funktioniert nicht
    

    UPAppDelegate *appDelegate = (UPAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =  appDelegate.managedObjectContext;
    NSArray *results3 = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"result3 ist %@", results3.description);
    
  
    
    NSManagedObjectContext *theContext = [[NSManagedObjectContext alloc] init];
    [theContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    NSArray *results2 = [theContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"result2 ist %@", results2.description);
*/
}

-(void) viewDidAppear:(BOOL)animated {
#ifdef VERBOSE
    NSLog(@"1 self %@", self.description);
    NSLog(@"2 self.navigationController %@", self.navigationController.description);
    NSLog(@"3 self.navigationController.topViewController %@", self.navigationController.topViewController);
    NSLog(@"4 isUndoRegistrationEnabled %d", self.fetchedResultsController.managedObjectContext.undoManager.isUndoRegistrationEnabled);
#endif
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View


// Gibt zurück, wieviele Sections die Tabelle anzeigen soll. Hängt hier direkt vom Ergebnis der Abfrage ab.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}


// Meldet zurück, wieviele Zeilen die Tabelle in einer bestimmten Section anzeigen soll. Hängt hier direkt vom Ergebnis der Abfrage ab.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Die erste Klammer rechts gibt ein Array zurück und die [section] ist der index auf das Array, also [0], [1], ... (neue Syntax statt dem indexAt..., seit kurzem erlaubt in objective-c)
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

// Gibt für eine Tabellenzeile (und weil dies hier für jede einzelne aufgerufen wird) vor, wie der Inhalt auszusehen hat. Ist also die Verbindung zwischend den Daten und der Tabellenanzeige. 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

#define TABLE_VIEW_CELL_STYLE 2
    
    if (TABLE_VIEW_CELL_STYLE == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        [self configureCell2:cell atIndexPath:indexPath];
        return cell;
    } else if (TABLE_VIEW_CELL_STYLE == 1){
        // TODO: Use custom cells, later to be put specified in more detail
        //UITableViewCell *cellWithComment = [tableView dequeueReusableCellWithIdentifier:@"Cell with comment" forIndexPath:indexPath];
        
        TVCell *cell = (TVCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell with comment" forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    } else {
#ifdef VERBOSE
        NSLog(@"IndexPath %@", indexPath.description);
#endif
        DiaryTableViewCell *cell = (DiaryTableViewCell* )[tableView dequeueReusableCellWithIdentifier:@"Diary Table View Cell" forIndexPath:indexPath];
#ifdef VERBOSE
        NSLog(@"in cellForRowAtIndexPath...");
#endif
        [self configureCell3:cell atIndexPath:indexPath];
        
        // Inset mit Lazy Getter in Property auslagern
        UIEdgeInsets e = UIEdgeInsetsMake(0, 30, 0, 30);
        cell.separatorInset = e;
        return cell;
    }
}

-(void) configureCell3:(DiaryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.event = event;
    [cell redisplay];
}

- (void)configureCell:(TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (event.timeStamp) {
        cell.timeLabel.text = [self.dateTimeFormatter stringFromDate: event.timeStamp];
        cell.timeTextLabel.text = @"Uhr";

        cell.timeLabel.hidden = NO;
        cell.timeTextLabel.hidden = NO;
    } else {
        cell.timeLabel.hidden = YES;
        cell.timeTextLabel.hidden = YES;
    }
    
    
    if (event.bloodSugar > 0) {
        cell.bloodSugarLabel.text = [self.numberFormatter1Digit stringForObjectValue:event.bloodSugar];
        cell.bloodSugarUnitLabel.text = @"mg/dl";
        cell.bloodSugarLabel.hidden = NO;
        cell.bloodSugarUnitLabel.hidden = NO;
    } else {
        cell.bloodSugarLabel.hidden = YES;
        cell.bloodSugarUnitLabel.hidden = YES;
    }
    
    // Strings for shortBolus
    if (event.shortBolus.doubleValue != 0) {
        cell.shortBolusLabel.text = [self.numberFormatter1Digit stringForObjectValue:event.shortBolus];
        cell.shortBolusTextLabel.text = @"Korr. und Kohlehydrate";
        cell.shortBolusUnitLabel.text = @"IE";
        
        cell.shortBolusLabel.hidden = NO;
        cell.shortBolusTextLabel.hidden = NO;
        cell.shortBolusUnitLabel.hidden = NO;
    } else {
        cell.shortBolusLabel.hidden = YES;
        cell.shortBolusTextLabel.hidden = YES;
        cell.shortBolusUnitLabel.hidden = YES;
    }
    
    // String for shortBolusCalculation (e.g. "1 IE + 1,1 IE/KHE * 2,3 KHE")
    if (event.chuBolus.doubleValue != 0) {
        // chuBolus (e.g. "1 IE + 1,1 IE/KHE * 2,3 KHE")
        cell.shortBolusCalculationLabel.text = [[NSString alloc] initWithFormat:@"%@ + %@ * %@",
                                                [self.numberFormatter2SigDigits stringForObjectValue:event.correctionBolus],
                                                [self.numberFormatter2SigDigits stringForObjectValue:event.chuFactor],
                                                [self.numberFormatter2SigDigits stringForObjectValue:event.chu] ];
        cell.shortBolusCalculationUnitLabel.text = @"IE  IE/KHE  KHE";
        
        cell.shortBolusCalculationLabel.hidden = NO;
        cell.shortBolusCalculationUnitLabel.hidden = NO;
        
    } else if (event.chu.doubleValue > 0) {
        // chu only (e.g. "2,3 KHE")
        cell.shortBolusCalculationLabel.text = [[NSString alloc] initWithFormat:@"%@", [self.numberFormatter2SigDigits stringForObjectValue:event.chu] ];
        cell.shortBolusCalculationUnitLabel.text = @"KHE";
        
        cell.shortBolusCalculationLabel.hidden = NO;
        cell.shortBolusCalculationUnitLabel.hidden = NO;
        
    } else if (event.correctionBolus.doubleValue != 0) {
        // Only Correction Bolus and chuBolus (e.g. "1 IE Korrektur")
        cell.shortBolusCalculationLabel.text = [[NSString alloc] initWithFormat:@"%@ Korrektur",
                                                [self.numberFormatter1Digit stringForObjectValue:event.correctionBolus]];
        cell.shortBolusCalculationUnitLabel.text = @"  IE";
        cell.shortBolusCalculationUnitLabel.textAlignment = NSTextAlignmentLeft;
        
        cell.shortBolusCalculationLabel.hidden = NO;
        cell.shortBolusCalculationUnitLabel.hidden = NO;
        
    } else {
        cell.shortBolusCalculationLabel.hidden = YES;
        cell.shortBolusCalculationUnitLabel.hidden = YES;
    }

    
    if (event.basalDosis >0) {
        cell.basalDosisLabel.text = [self.numberFormatter1Digit stringForObjectValue:event.basalDosis];
        cell.basalDosisTextLabel.text = @"Basal";
        cell.basalDosisUnitLabel.text = @"IE";
        cell.basalDosisLabel.hidden = NO;
        cell.basalDosisTextLabel.hidden = NO;
        cell.basalDosisUnitLabel.hidden = NO;
    } else {
        cell.basalDosisLabel.hidden = YES;
        cell.basalDosisTextLabel.hidden = YES;
        cell.basalDosisUnitLabel.hidden = YES;
    }
    
    // Strings for FPU
    if (event.fpuBolus.doubleValue > 0) {
        // e.g. "1,3 IE/FPE * 5 FPE"
        cell.fpuBolusLabel.text = [self.numberFormatter2SigDigits stringForObjectValue:event.fpuBolus ];
        cell.fpuBolusCalculationLabel.text = [[NSString alloc] initWithFormat:@"%@ * %@",
                                                         [self.numberFormatter2SigDigits stringForObjectValue:event.fpuFactor],
                                                         [self.numberFormatter2SigDigits stringForObjectValue:event.fpu]];
        cell.fpuBolusTextLabel.text = @"Fett und Protein";
        cell.fpuBolusUnitLabel.text = @"IE";
        cell.fpuBolusCalculationUnitLabel.text = @"IE/FPE  FPE";

        cell.fpuBolusLabel.hidden = NO;
        cell.fpuBolusCalculationLabel.hidden = NO;
        cell.fpuBolusTextLabel.hidden = NO;
        cell.fpuBolusUnitLabel.hidden = NO;
        cell.fpuBolusCalculationUnitLabel.hidden = NO;
    } else if (event.fpu.doubleValue > 0) {
        // e.g. "5 FPE"
        cell.fpuBolusCalculationLabel.text = [[NSString alloc] initWithFormat:@"%@", [self.numberFormatter2SigDigits stringForObjectValue:event.fpu]];
        cell.fpuBolusTextLabel.text = @"Fett und Protein";
        cell.fpuBolusCalculationUnitLabel.text = @"FPE";
        
        cell.fpuBolusLabel.hidden = YES;
        cell.fpuBolusCalculationLabel.hidden = NO;
        cell.fpuBolusTextLabel.hidden = NO;
        cell.fpuBolusUnitLabel.hidden = YES;
        cell.fpuBolusCalculationUnitLabel.hidden = NO;
    } else {
        cell.fpuBolusLabel.hidden = YES;
        cell.fpuBolusCalculationLabel.hidden = YES;
        cell.fpuBolusTextLabel.hidden = YES;
        cell.fpuBolusUnitLabel.hidden = YES;
        cell.fpuBolusCalculationUnitLabel.hidden = YES;
    }
    
    cell.commentLabel.text = event.comment;
    
    // And now the background color for the cell
    cell.contentView.backgroundColor = [self colorForTimeOfDayFromDate:event.timeStamp];
    
    // Die einzelnen View-Kästchen sollen auch die gleiche Farbe haben, so dass man die Boxen erst mal nicht sieht
    cell.shortBolusLabel.superview.backgroundColor = cell.contentView.backgroundColor;
    cell.basalDosisLabel.superview.backgroundColor = cell.contentView.backgroundColor;
    cell.fpuBolusLabel.superview.backgroundColor = cell.contentView.backgroundColor;
    
//    cell.shortBolusLabel.superview.layer.borderWidth = 1;
//    cell.fpuBolusLabel.superview.layer.borderWidth = 1;
//    cell.basalDosisLabel.superview.layer.borderWidth = 1;
    
    cell.layer.borderWidth = 0.5;

    
//    return cell;
}


// Damit kann für eine Tabellenzeile (oder alle) zurückgegeben werden, ob sie editierbar sein soll, oder nicht.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
//
// section title: this is the date (i.e. just days)
//

//TODO: hier geht viel zeit verloren in den date formattern, bzw. deren Anwendung. Überarbeiten könnte sich lohnen.
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> theSection = [self.fetchedResultsController sections][section];
    
    // Setion information derives from an event's daystring (transient propertiy in the core data base), which is a string representing the number year * 10000 + month * 100 + day.
    
    // section date (just the day), therefore convert section name, which is a string (such as "20130609") to a NSDate object
    NSDate *sectionDayDate = [[NSDate alloc] init];
    sectionDayDate = [self.dateFormatterForComparison dateFromString:[theSection name]];      // section date as NSDate object containing just days (derived from section name string, such as "2013-06-08")
    
    NSString *todayString = [self.dateFormatterForComparison stringFromDate:[NSDate date]];   // Current date as string with days only (such as "2013-06-09")
    NSDate *todayDayDate = [NSDate new];
    todayDayDate = [self.dateFormatterForComparison dateFromString:todayString];               // Current date as NSDate object with days only (derived from the string)

    // Time intervall between section date and current date (i.e. today)
    NSTimeInterval time = [sectionDayDate timeIntervalSinceDate:todayDayDate];  // time intervall as NSTimeIntervall (which is a double)
    int days = time / 86400;                                                    // time intervall in days
    
    // create String for each section
    NSString *titleString = [[NSString alloc] init];
    if (days < -2)       { titleString = [self.dateFormatterForAnyDayInThePast       stringFromDate:sectionDayDate]; // any day in the past (before the day before yesterday)
    } else if (days <-1) { titleString = [self.dateFormatterForTheDayBeforeYesterday stringFromDate:sectionDayDate]; // day before yesterday
    } else if (days < 0) { titleString = [self.dateFormatterForYesterday             stringFromDate:sectionDayDate]; // yesterday
    } else if (days < 1) { titleString = [self.dateFormatterForToday                 stringFromDate:sectionDayDate]; // today
    } else if (days < 2) { titleString = [self.dateFormatterForTomorrow              stringFromDate:sectionDayDate]; // tomorrow
    } else if (days < 3) { titleString = [self.dateFormatterForTheDayAfterTomorrow   stringFromDate:sectionDayDate]; // day after tomorrow
    } else               { titleString = [self.dateFormatterForAnyDayInTheFuture     stringFromDate:sectionDayDate]; // any day thereafter in the future
    }
    
    return titleString;
}


// Wird aufgerufen, wenn der User einen Tabellenzeile gelöscht hat (roten Delete-Knopf gedrückt und dann bestätigt). Danach wird diese Methode vom Tableview aufgerufen. Hier muss nun CoreData mitgeteilt werden, welche Zeile gelöscht werden soll. Dann muss die Löschung hier auch auf die "Core Data"-Daten angewandt werden. Das geschieht im context.
// Standard, hier wird nur auf Löschen eingegangen, weil das Insert über den Plus-Button abgehandelt wird (und nicht über einen grünen Button, den wohl der Tableview noch irgendwie anbieten kann)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];  // Objekt des Context
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];      // Zeile löschen
        
        [self saveContext:context];
    }
}

// Damit wird für eine Tabellenzeile (oder alle) zurückgegeben, ob sie verschiebbar sein soll, oder nicht
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}


// Wichtige Routine, die an die Daten anzupassen ist. Hier wird ein neues Datenelement (also eine Zeile) den "Core Data"-Daten hinzugefügt.
// wird vom segue aufgerufen, der wiederum aufgeruffen wurde, wenn der Add-Button gedrückt wurde (siehe viewDidLoad).
// Hier gibt es keine Tabellen- oder Zeilen-Information, es wird einfach eine neues Datenbank-Objekt erzeugt
//- (void)insertNewObject:(id)sender // So ursprünglich vom Template. Richtig, wenn im gleichen View geblieben wird
- (Event *)insertNewObject  // So für sofortigen Sprung über den Segue in den DetailViewController
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];  // Erzeugt ein Object context, das mit dem property managedObjectContext belegt wird
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];     // Erzeugt ein EntityDescription
    
    // Create an undo manager for the current context (the object created later carries the context information as a property, and thus also the undo manager)
    [context setUndoManager:[[NSUndoManager alloc] init]];
    [context.undoManager beginUndoGrouping];
    
    // Create a new object in the database (will be really saved to the database, when the managedObjectContext is saved)
    Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    return newEvent;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue itentifier is %@", segue.identifier);
    if ([[segue identifier] isEqualToString:@"segueAddEvent"]) {
        
        Event *newEvent = [self insertNewObject];                       // Neues Objekt erzeugen über Methode insertNewObject
        [segue.destinationViewController setEvent:newEvent];            // Property der Klasse Event in DetailViewController setzen
        NSLog(@"newEvent %@", newEvent.description);
    }
    else if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];   // Index der selektierten Zeile der Tabelle
        
        
        // Property des Ziel-Kontrollers des segue setzen. Die Controller scheinen schon irgendwie vom System instanziiert zu sein.
        Event *event = [[self fetchedResultsController] objectAtIndexPath:indexPath]; // Objekt zur Zeile, aber vom Klassentyp Event
        
        // Create an undo manager for the current context (the object carries the context information as a property, and thus also the undo manager it can then be used in the next view controller)
        NSManagedObjectContext *context = [event managedObjectContext];  // Get the managedObjectContext for the object
        [context setUndoManager:[[NSUndoManager alloc] init]];           // Create a new undo manager
        [context.undoManager beginUndoGrouping];                         // start collection undo information (undo can be done to this point)


//        // Test mit eigenem, lokal erzeugtem managed object context (siehe core data code snippets)
//        NSEntityDescription *edc = [event entity];
//        NSPersistentStoreCoordinator *psc = [context persistentStoreCoordinator];
//        NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
//        [newContext setPersistentStoreCoordinator:psc];
//        
//        Event *theEvent = [[Event alloc] initWithEntity:edc insertIntoManagedObjectContext:newContext];
//        
//        NSLog(@"event %@",event.description);
//        NSLog(@"theEvent %@", theEvent.description);
//        [segue.destinationViewController setEvent:theEvent];         // Property der Klasse Event
        
        [segue.destinationViewController setEvent:event];         // Property der Klasse Event
    }
}

#pragma mark - Fetched results controller

// Controller für den fetch, d.h. die Suchanfrage
// Nachfolgende Operationen erstellen eine Abfrage auf die Daten, samt zugehöriger Sortierung und Verweis auf diesen Controller, der aufgerufen wird, wenn sich die Daten ändern. Dies muss genau einmal gemacht werden und wird dann wohl immer aufgerufen, wenn Daten hinzugefügt, geändert oder gelöscht werden.
// Dickes Buch S. 487: ... Core Data stellt Ihnen die Klasse NSFechtedResultsController zur Verfügung, die Ihnen diese Verbindung zwischen Suchanfragen und Tableviews vereinfacht. [Hilft also, wenn ich das richtig verstanden habe, die Tabelle gleich mit zu aktualisieren, wenn die Daten sich geändert haben] Außerdem unterstützt sie auch die Unterteilung der Daten in Abschnitte [also sections] anhand eines Attributs
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;    // Wenn dies schon mal durchlaufen wurde, ist nichts mehr zu tun.
    }
    
    // Request ist die eigentliche Abfrage
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate. (Entity ist in etwas die Tabelle der Datenbank, Tabelle wäre hier die Tabelle Event)
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity]; // Zurordnung der Abfrage zu Tabelle (oder umgekehrt)
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];  // Holt immer nur eine bestimmte Datenmenge (Menge an Zeilen)
    
    // Edit the sort key as appropriate. // Sortiert die spätere Datenabfrage nach der "Spalte" timeStamp
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors]; //Zuordnung des Sortierkriteriums zur Abfrage
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    // A C H T U N G: Im Cache werden die transient Properties persistent gespeichert. Wenn der Cache gelöscht wird, muss alles neue erstellt werden. Das ist bei Änderungen der Sections erforderlich
    [NSFetchedResultsController deleteCacheWithName:@"Master"];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest          // die Abfrage
                                                             managedObjectContext:self.managedObjectContext  // der Object Context (sozusagen das Memory, in dem die Daten zwischengespeichert werden, bis zum späteren save
                                                             sectionNameKeyPath:@"dayString"                // Irgendwas mit dem Namen der Section
                                                             cacheName:@"Master"];                      // Lokales Datenfile "Master"
    
    // Zurodnung des Abfrage-Controllers zu diesem MasterviewController selbst. Damit wird selbiger (also die Instanz) aufgerufen, wenn sich Abfrageergebnisse ändern
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
#ifdef VERBOSE
    // List all the Events that where fetched from the core data base
    NSArray *theArray = [NSArray new];
    int i = 0;
    theArray = [_fetchedResultsController fetchedObjects];
    
    for (id object in theArray) {
        NSLog(@"object #%d, %@", i, object);
        i++;
    }
#endif

    return _fetchedResultsController;
}    

// Wird aufgerufen bevor der fetched results controller Änderungen verarbeitet (aufgrund von add, remove, move oder update von Elementen)
// Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}


// Wird aufgerufen, wenn sie eine Änderung ergeben hat, mit Hinweis auf zugehörige Section, Index auf Element in der Section und Art der Änderung (Insert, delete, move oder update). In diesem Fall werden wohl nur ganze sections behandelt, die entweder eingefügt oder gelöscht werden, je nachdem, was die Abfrage des fechtedResultsController ergeben hat.
// Das hier ist Standard und es müssen keine Änderungen an den Daten gemacht werden.
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

// Wird aufgerufen, wenn sich Objekte (der Tabelle) geändert haben, konkreter das Ergebnis der Abfrage geändert hat aufgrund von insert, delete, move oder update. Zuvor erfolgt aber der obige Aufruf dass sich die Section geändert hat (falls so implementiert)
// Hier muss damit nun der Tableview aktualisiert werden, d.h. die entsprechende Zeile eingefügt, gelöscht, geändert oder verschoben werden.
// Dazu werden die entsprechenden Tableview-Methoden aufgerufen (also die zum Löschen etc.). Danach wird dann wohl bei Bedarf die obige Methode aufgerufen, die für jede angefragte Tabellenzeile die Werte aus dem Array (oder core data, d.h. wohl dem fetchedResultsController) zurückgibt.
//Somit ist das hier nur Standard und es müssen keine Anpassungen an die Daten gemacht werden.
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:                                      // Fügt eine Zeile ein
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:                                      // Löscht eine Zeile
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:                                      // Ändert eine Zeile

            // 2013-02-23: copied the following two lines from a template which works perfectly and avoids an update of the table view cell on each entry of a value in the detail table view controller (and that was a real problem because it was very very time consuming). Wow, this speeded up value entry in the detail view controller very very much. I don't know why I used that confusing code further below anyways.
//            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            // TODO (Written on 2013-02-23 and to be performed on some later date): Delete the following code lines, that are already commented out, from HERE
//            // configureCell:atIndexPath: became somewhat slow with new styling of cells (as of Dec 2013). Thus configureCell:atIndexPath: should only be called when necessary (up till to date it was called, whenever a single value of the event entity was changed in the detail view controller. To avoid this, the property cellAtIntexPathRecentlyChanged stores wether changes to event have been made in the detail view controller. This ist done right here. When changes in the detail view controller are finished and the app switches back to this master view controller, configureCell:atIndexPath: is finally called (which is handled in viewWillAppear)
////            if (TABLE_VIEW_CELL_STYLE_IS_OLD) {
////                [self configureCell2:[tableView cellForRowAtIndexPath:indexPath]
////                         atIndexPath:indexPath];
////            } else {
////                [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
////                         atIndexPath:indexPath];
////                
////            }
//            self.cellAtIndexPathRecentlyChanged = [[NSIndexPath alloc] init];
//            self.cellAtIndexPathRecentlyChanged = indexPath;
//
//            // Test: nur ausführen, wenn dieser ViewController auch gerade angezeigt wird, das klappt aber nicht
////            if (self == self.navigationController.topViewController) {
//            if (TABLE_VIEW_CELL_STYLE==0) {
//                [self configureCell2:[tableView cellForRowAtIndexPath:indexPath]
//                        atIndexPath:indexPath];
//            } else if (TABLE_VIEW_CELL_STYLE == 1){
//                [self configureCell: (TVCell *)[tableView cellForRowAtIndexPath:indexPath]
//                        atIndexPath:indexPath];
//            } else {
//                [self configureCell3: (DiaryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]
//                        atIndexPath:indexPath];
//            }
////            }
//            
//            
//            
//            break;
            // to HERE
            
            
        case NSFetchedResultsChangeMove:                                        // Verschiebt eine Zeile
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

// Wird aufgerufen, wenn die Änderungen vorgenommen wurden sind
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // TODO: Achtung (2013-11-14): Großes Experiment hier. Diese Methode wird jedes mal aufgerufen, wenn sich eine Änderung im Managed Object Context ergibt. Das passiert also auch jedes mal, wenn nur der "Cursor" im DetailViewController bewegt wird, oder dort ein Wert eingetragen wird, weil dies direkt in Core Data umgesetzt wird. Das führte zu erheblichen(!) Performanceproblemen im DetailViewController. Mit nachfolgendem if-statement konnte dies behoben werden. Und die Daten werden im TableView trotzdem richtig aktualisiert (selbst, wenn man das hier auskommentiert)
    // Vielleicht könnte das auch mit einem lokalen ManagedObjectContext für den DetailViewController erreicht werden, der dann nach dem save gemerged wird (siehe auch stackoverflow dazu: http://stackoverflow.com/questions/7842768/controllerdidchangecontent-called-every-time-i-create-a-managedobject-in-core-d )
    // Hiermit also das if, damit dies nur abgearbeitet wird, wenn dieser TableViewController auch gerade angezeigt wird.
//    if (self == self.navigationController.topViewController) {
        [self.tableView endUpdates];
//   }

    
    //    [self.tableView reloadData];
}


/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


// Speziell für diese Tabelle erstellte Methode, die die Konfiguration einer einzelnen Tabellenzeile beschreibt und auch festlegt, welche Daten wo eingetragen werden.
// Das hier ist nicht Standard sondern muss angepasst werden.
- (void)configureCell2:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Gibt praktisch die Tabellenzeile der Abfrage zurück. Damit stehen die Daten zur Verfügung um die darzustellende Zeile auszugestalten.
    // In NS-Sprech: fetchedResultsController enthält die Tabelle mit den Objekten der Abfrage (und Sortierung etc.) und mit nachfolgendem Aufruf wird ein bestimmtes Objekt (also eine Tabellenzeile) zurückgegeben.
    //    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Event   *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    // Jetzt kann die Zelle ausgestaltet werden, d.h. die Datenelemente des Objekts an die richtige Stelle geschrieben werden.
    
    NSDateFormatter *dateDateFormatter = [[NSDateFormatter alloc]init];  // Initialize Date Formatter
    [dateDateFormatter setDateFormat:@"dd.MM.YYYY"];                     // Specify the date format
    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc]init];  // Initialize Date Formatter
    [dateTimeFormatter setDateFormat:@"HH:mm"];                          // Specify the date format
    
    if (event.bloodSugar.doubleValue > 0) {
        cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@ Uhr             BZ %3.0f",[dateTimeFormatter stringFromDate: event.timeStamp],
                           event.bloodSugar.doubleValue];
    } else {
        cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@ Uhr             ",[dateTimeFormatter stringFromDate: event.timeStamp]];
    }
        
    // String for meal data
    NSMutableString *mealString = [NSMutableString new];
    if (event.chu.doubleValue > 0 || event.fpu.doubleValue > 0) {
        [mealString appendString:[[NSMutableString alloc] initWithFormat:@"%@ kcal, %@ g KH, %@ g Eiweiß, %@ g Fett",
                                        [self.numberFormatter3SigDigits stringForObjectValue: event.energy],
                                        [self.numberFormatter2SigDigits stringForObjectValue: event.carb],
                                        [self.numberFormatter2SigDigits stringForObjectValue: event.protein],
                                        [self.numberFormatter2SigDigits stringForObjectValue: event.fat]]];
    }
    
    // String for (short) Bolus data
    NSMutableString *shortBolusString = [NSMutableString new];
    if (event.chuBolus.doubleValue > 0 && event.correctionBolus.doubleValue !=0) {                        // Correction- and CHU-Bolus
        [shortBolusString appendString: [[NSString alloc] initWithFormat:@"%@ Korrektur +  %@ x %@ KHE  =  %@ IE",
                                      [self.numberFormatter1Digit stringForObjectValue: event.correctionBolus ],
                                      [self.numberFormatter2SigDigits stringForObjectValue: event.chuFactor ],
                                      [self.numberFormatter2SigDigits stringForObjectValue: event.chu],
                                      [self.numberFormatter1Digit stringForObjectValue: event.shortBolus ]]];
    } else if (event.correctionBolus.doubleValue != 0) {                                                      // only Correction-Bolus
        [shortBolusString appendString: [[NSString alloc] initWithFormat:@"%@ IE Korrektur",
                                         [self.numberFormatter1Digit stringForObjectValue: event.correctionBolus ]]];
    } else if (event.chuBolus.doubleValue >0) {                                                                                                // only CHU-Bolus
        [shortBolusString appendString: [[NSString alloc] initWithFormat:@"%@ * %@ KHE  =  %@ IE",
                                         [self.numberFormatter2SigDigits stringForObjectValue: event.chuFactor ],
                                         [self.numberFormatter2SigDigits stringForObjectValue: event.chu],
                                         [self.numberFormatter1Digit stringForObjectValue: event.shortBolus ]]];
    }
    
    // String for fat and protein insulin
    NSMutableString *fpuBolusString = [NSMutableString new];
    if (event.fpuBolus.doubleValue > 0) {
        [fpuBolusString appendString: [[NSString alloc] initWithFormat:@"%@ x %@ FPE  =  %@ IE",
                                    [self.numberFormatter2SigDigits stringForObjectValue: event.fpuFactor ],
                                    [self.numberFormatter2SigDigits stringForObjectValue: event.fpu ],
                                    [self.numberFormatter2SigDigits stringForObjectValue: event.fpuBolus ]]];
    }
    
    // String for basal insulin
    NSMutableString *basalString = [NSMutableString new];
    if (event.basalDosis.doubleValue > 0) {
        [basalString appendString:[[NSString alloc] initWithFormat:@"%@ IE Basal", [self.numberFormatter2SigDigits stringForObjectValue:event.basalDosis]]];
//    } else {
//        basalString = nil;
    }

    // String for comment
    NSMutableString * commentString = [NSMutableString new];
    if (event.comment.length > 1) {
        [commentString appendString:event.comment];
    }
    
    // Combine these strings to one string
    cell.detailTextLabel.text = @""; // clear the string from "subtitle"
    BOOL firstLine = YES;
    NSArray *theArray = [[NSArray alloc] initWithObjects: mealString, shortBolusString, fpuBolusString, basalString, commentString, nil];
    for (NSString *theString in theArray) {
        if (theString.length > 0) {
            if (firstLine) {
                cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:theString];
                firstLine = NO;
            } else {
                cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:@"\n"];        // newline for second and following lines
                cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:theString];
            }
        }
    }
//    cell.detailTextLabel.text = theDetailString;
    
    // And now the background color for the cell
    cell.contentView.backgroundColor = [self colorForTimeOfDayFromDate:event.timeStamp];
//    NSLog(@"Cell-size %f,%f ",cell.frame.size.height, cell.frame.size.width);

}



# pragma mark -- helper methods

-(UIColor *)colorForTimeOfDayFromDate:(NSDate *)theDate {
    
    // And now the background color for the cell. Works only for the normal text area.
    // TODO Look in stackoverflow for a solution to paint the disclosure indicator
    
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:theDate];
//    NSInteger hourOfDay = [components hour];
    
    CGFloat hourOfDay = (CGFloat)[components hour] + (CGFloat)[components minute] /60.0;

#define HUE_00 10.0
#define HUE_12 40.0
#define SAT_00 0.3
#define SAT_12 0.1
#define BRIGHT_00 1.0
#define BRIGHT_12 1.0
    
    // 12 hour scheme wandering through the hue-space from HUE_00 (at zero hours) to HUE_12 (at twelve hours) and back to HUE_00 (at 24 hours)
    CGFloat hue, sat, bright;
    if (hourOfDay < 12) {
        // From zero to twelve hours
        hue =    ( HUE_00    + (HUE_12    - HUE_00)    * hourOfDay / 12.0 ) / 360.0;
        sat =    ( SAT_00    + (SAT_12    - SAT_00)    * hourOfDay / 12.0 );
        bright = ( BRIGHT_00 + (BRIGHT_12 - BRIGHT_00) * hourOfDay / 12.0 );
    } else {
        // From twelve hours backwards to 24 hours (i.e. zero)
        hue =    ( HUE_00    + (HUE_12    - HUE_00)    * (24.0 - hourOfDay) / 12.0 ) / 360.0;
        sat =    ( SAT_00    + (SAT_12    - SAT_00)    * (24.0 - hourOfDay) / 12.0 );
        bright = ( BRIGHT_00 + (BRIGHT_12 - BRIGHT_00) * (24.0 - hourOfDay) / 12.0 );
    }
//    NSLog(@" hour = %f, hue = %f, sat = %f, bright = %f", hourOfDay, hue, sat, bright);
    return [UIColor colorWithHue:hue saturation:sat brightness:.90 alpha:1.0];
}

// Saving is done at various points (i.e. methods) in this file. Thus concentrate in this method
-(void) saveContext:(NSManagedObjectContext *)context {
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
-(NSNumberFormatter *)numberFormatter1Digit {
    if (!_numberFormatter1Digit) {
        _numberFormatter1Digit = [[NSNumberFormatter alloc] init];
        _numberFormatter1Digit.maximumFractionDigits = 1;
        _numberFormatter1Digit.minimumIntegerDigits = 1;
        _numberFormatter1Digit.roundingMode = NSNumberFormatterRoundHalfUp;
        _numberFormatter1Digit.zeroSymbol = @"0";
        _numberFormatter1Digit.nilSymbol = @"0";
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
        _numberFormatter2SigDigits.nilSymbol = @"0";
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
        _numberFormatter3SigDigits.nilSymbol = @"0";
        _numberFormatter3SigDigits.notANumberSymbol = @"-";
    }
    return _numberFormatter3SigDigits;
}

-(NSDateFormatter *)dateTimeFormatter {

    if (!_dateTimeFormatter) {
        _dateTimeFormatter = [[NSDateFormatter alloc] init];  // Initialize Date Formatter
        [_dateTimeFormatter setDateFormat:@"HH:mm"];                           // Specify the date format (i.e. time format)
    }
    return _dateTimeFormatter;
}

# pragma mark -- date formatters for section headers

-(NSDateFormatter *)dateFormatterForComparison {
    if (!_dateFormatterForComparison) {
        _dateFormatterForComparison = [[NSDateFormatter alloc] init];
        _dateFormatterForComparison.dateFormat = @"yyyyMMdd";
    }
    return _dateFormatterForComparison;
}

-(NSDateFormatter *)dateFormatterForAnyDayInThePast {
    if (!_dateFormatterForAnyDayInThePast) {
        _dateFormatterForAnyDayInThePast = [[NSDateFormatter alloc] init];
        _dateFormatterForAnyDayInThePast.dateFormat = @"EEEE, d. LLLL yyyy";
    }
    return _dateFormatterForAnyDayInThePast;
}
-(NSDateFormatter *)dateFormatterForTheDayBeforeYesterday {
    if (!_dateFormatterForTheDayBeforeYesterday) {
        _dateFormatterForTheDayBeforeYesterday = [[NSDateFormatter alloc] init];
        _dateFormatterForTheDayBeforeYesterday.dateFormat = @"'Vorgestern', EEEE, d. LLLL yyyy";
    }
    return _dateFormatterForTheDayBeforeYesterday;
}

-(NSDateFormatter *)dateFormatterForYesterday{
    if (!_dateFormatterForYesterday) {
        _dateFormatterForYesterday = [[NSDateFormatter alloc] init];
        _dateFormatterForYesterday.dateFormat = @"'Gestern', EEEE, d. LLLL yyyy";
    }
    return _dateFormatterForYesterday;
}

-(NSDateFormatter *)dateFormatterForToday {
    if (!_dateFormatterForToday) {
        _dateFormatterForToday = [[NSDateFormatter alloc] init];
        _dateFormatterForToday.dateFormat = @"'Heute', EEEE, d. LLLL yyyy";
    }
    return _dateFormatterForToday;
}

-(NSDateFormatter *)dateFormatterForTomorrow {
    if (!_dateFormatterForTomorrow) {
        _dateFormatterForTomorrow = [[NSDateFormatter alloc] init];
        _dateFormatterForTomorrow.dateFormat = @"'Morgen', EEEE, d. LLLL yyyy";
    }
    return _dateFormatterForTomorrow;
}

-(NSDateFormatter *)dateFormatterForTheDayAfterTomorrow {
    if (!_dateFormatterForTheDayAfterTomorrow) {
        _dateFormatterForTheDayAfterTomorrow = [[NSDateFormatter alloc] init];
        _dateFormatterForTheDayAfterTomorrow.dateFormat = @"'Übermorgen', EEEE, d. LLLL yyyy";
    }
    return _dateFormatterForTheDayAfterTomorrow;
}

-(NSDateFormatter *)dateFormatterForAnyDayInTheFuture {
    if (!_dateFormatterForAnyDayInTheFuture) {
        _dateFormatterForAnyDayInTheFuture = [[NSDateFormatter alloc] init];
        _dateFormatterForAnyDayInTheFuture.dateFormat = @"EEEE, d. LLLL yyyy";
    }
    return _dateFormatterForAnyDayInTheFuture;
}

//@property (strong, nonatomic) NSDateFormatter *dateFormatterForAnyPastDay;
//@property (strong, nonatomic) NSDateFormatter *dateFormatterForTheDayBeforeYesterday;
//@property (strong, nonatomic) NSDateFormatter *dateFormatterForYesterday;
//@property (strong, nonatomic) NSDateFormatter *dateFormatterForToday;
//@property (strong, nonatomic) NSDateFormatter *dateFormatterForTomorrow;
//@property (strong, nonatomic) NSDateFormatter *dateFormatterForTheDayAfterTomorrow;
//@property (strong, nonatomic) NSDateFormatter *dateFormatterForAnyDayInTheFuture;

//if (days < -2)       { [dateFormatter setDateFormat:@"EEEE, d. LLLL yyyy"];                 // any day in the past (before the day before yesterday)
//} else if (days <-1) { [dateFormatter setDateFormat:@"'Vorgestern', EEEE, d. LLLL yyyy"];   // day before yesterday
//} else if (days < 0) { [dateFormatter setDateFormat:@"'Gestern', EEEE, d. LLLL yyyy"];      // yesterday
//} else if (days < 1) { [dateFormatter setDateFormat:@"'Heute', EEEE, d. LLLL yyyy"];        // today
//} else if (days < 2) { [dateFormatter setDateFormat:@"'Morgen', EEEE, d. LLLL yyyy"];       // tomorrow
//} else if (days < 3) { [dateFormatter setDateFormat:@"'Übermorgen', EEEE, d. LLLL yyyy"];   // day after tomorrow
//} else               { [dateFormatter setDateFormat:@"EEEE, d. LLLL yyyy"];                 // any day thereafter in the future



# pragma mark -- Sachen zu Core Data aus AppDelegate


// Speicher die Daten in "Core Data", wenn Änderungen an den Daten (im managedObjectContext) vorgenommen wurden
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


//// Lazy getter for managedObjectContext, which is received from the UPAppDelegate
//-(NSManagedObjectContext *)managedObjectContext {
//    if (!_managedObjectContext) {
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        _managedObjectContext = appDelegate.managedObjectContext;
//    }
//    return _managedObjectContext;
//}






#pragma mark - Core Data stack

// Wohl Standard, schätze, dass hier nichts gemacht werden muss

//// Returns the managed object context for the application.
//// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//- (NSManagedObjectContext *)managedObjectContext
//{
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    return _managedObjectContext;
//}
//
//// Returns the managed object model for the application.
//// If the model doesn't already exist, it is created from the application's model.
//- (NSManagedObjectModel *)managedObjectModel
//{
//    if (_managedObjectModel != nil) {
//        return _managedObjectModel;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BolusCalc" withExtension:@"momd"];
//    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//   
//    return _managedObjectModel;
//}
//
//// Returns the persistent store coordinator for the application.
//// If the coordinator doesn't already exist, it is created and the application's store added to it.
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BolusCalc.sqlite"];
//    
//    // Delete the store
//    //    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
//    //    NSLog(@"Hopefully deleted the store");
//    
//    
//    NSError *error = nil;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    
//    // Code for lightweight migration from raywenderlich.com
//    NSDictionary *options = @{
//                              NSMigratePersistentStoresAutomaticallyOption : @YES,
//                              NSInferMappingModelAutomaticallyOption : @YES
//                              };
//    
//    //if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
//        /*
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//         
//         Typical reasons for an error here include:
//         * The persistent store is not accessible;
//         * The schema for the persistent store is incompatible with current managed object model.
//         Check the error message to determine what the actual problem was.
//         
//         
//         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
//         */
//        //If you encounter schema incompatibility errors during development, you can reduce their frequency by:
//        //* Simply deleting the existing store:
//        //        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
//        //        NSLog(@"Hopefully deleted the store");
//        
//        //* Performing automatic lightweight migration by passing the following dictionary as the options parameter:
//        //@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
//        
//        //Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
//        
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return _persistentStoreCoordinator;
//}
//
//#pragma mark - Application's Documents directory
//
//// Returns the URL to the application's Documents directory.
//- (NSURL *)applicationDocumentsDirectory
//{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}
//



@end
