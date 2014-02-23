//
//  BloodSugarGraphViewController
//
//  Created by Uwe Petersen on 22.10.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//

#import "BSGViewController.h"
#import "BloodSugarGraphView.h"
#import "Event.h"
#import "Event+Extensions.h"
#import "EventsStatistic.h"
#import "AppDelegate.h"

@interface BSGViewController ()

@property (weak, nonatomic) IBOutlet BloodSugarGraphView *bloodSugarGraphView;

@end

@implementation BSGViewController


// Core Data stuff
@synthesize managedObjectContext = _managedObjectContext;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Redraw the view, when the device is rotated
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.bloodSugarGraphView setNeedsDisplay];
}

-(void)viewWillAppear:(BOOL)animated {
    [self saveContext:self.managedObjectContext];
    
    // Hand over the data to be plotted to the view
    if (self.fetchedResultsController.fetchedObjects) {
        self.bloodSugarGraphView.Events = [NSArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
    } else {
        self.bloodSugarGraphView.Events = nil;
    }
    
    [self.bloodSugarGraphView setNeedsDisplay];
}

-(void)setBloodSugarGraphView:(BloodSugarGraphView *)bloodSugarGraphView
{
    _bloodSugarGraphView = bloodSugarGraphView;
    
    // Pinch gesture-Sache hier programmatisch gemacht. Definiert in der View, in der die gesture erkannt wird und hier registriert (könnte auch in der view selbst gemacht werdenim initWithFrame?)
    [bloodSugarGraphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:bloodSugarGraphView action:@selector(pinch:)]];
    
    // Pan recognizer for paning with one or two fingers
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:bloodSugarGraphView action:@selector(pan:)];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [bloodSugarGraphView addGestureRecognizer: panGestureRecognizer];
}


// Wird aufgerufen, wenn die Änderungen beendet sind
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
}

# pragma mark -- Sachen zu Core Data aus AppDelegate


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


//// Lazy getter for managedObjectContext, which is received from the UPAppDelegate
//-(NSManagedObjectContext *)managedObjectContext {
//    if (!_managedObjectContext) {
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        _managedObjectContext = appDelegate.managedObjectContext;
//    }
//    return _managedObjectContext;
//}
//


//
//
//
//#pragma mark - Fetched results controller
//
//// Controller für den fetch, d.h. die Suchanfrage
//// Nachfolgende Operationen erstellen eine Abfrage auf die Daten, samt zugehöriger Sortierung und Verweis auf diesen Controller, der aufgerufen wird, wenn sich die Daten ändern. Dies muss genau einmal gemacht werden und wird dann wohl immer aufgerufen, wenn Daten hinzugefügt, geändert oder gelöscht werden.
//// Dickes Buch S. 487: ... Core Data stellt Ihnen die Klasse NSFechtedResultsController zur Verfügung, die Ihnen diese Verbindung zwischen Suchanfragen und Tableviews vereinfacht. [Hilft also, wenn ich das richtig verstanden habe, die Tabelle gleich mit zu aktualisieren, wenn die Daten sich geändert haben] Außerdem unterstützt sie auch die Unterteilung der Daten in Abschnitte [also sections] anhand eines Attributs
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
    //    // List all the Events that where fetched from the core data base
    //    NSArray *theArray = [NSArray new];
    //    int i = 0;
    //    theArray = [_fetchedResultsController fetchedObjects];
    //
    //    for (id object in theArray) {
    //        NSLog(@"object #%d, %@", i, object);
    //        i++;
    //    }
#endif
    
    return _fetchedResultsController;
}


@end
