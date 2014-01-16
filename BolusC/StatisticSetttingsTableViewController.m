//
//  StatisticSetttingsTableViewController.m
//  BolusC
//
//  Created by Uwe Petersen on 11.01.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

#import "StatisticSetttingsTableViewController.h"
#import "Event.h"
#import "Event+Extensions.h"
#import "EventsStatistic.h"
#import "StatisticDetailTableViewController.h"


@interface StatisticSetttingsTableViewController ()

enum statsDateRangeValues {
    oneWeek = 1,
    twoWeeks = 2,
    threeWeeks = 3,
    fourWeeks = 4,
    oneMonth = 5,
    twoMonts = 6,
    threeMonths = 7,
    sixMonts = 8,
    oneYear = 9,
    twoYears = 10,
    noDateRangeSet = 11
};

@property enum statsDateRangeValues statsDateRange;
@property (nonatomic, strong) NSArray *eventsStatistics;
@property (nonatomic) BOOL groupByTime;

@end



@implementation StatisticSetttingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(BOOL) groupByTime {
//    if (_groupByTime == nil) {
//        _groupByTime = YES;
//    }
//    return _groupByTime;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"MOC %@", self.managedObjectContext);
    
    self.taskCategories = @[@7,@14,@21,@28];
    
    
    self.statsDateRange = noDateRangeSet;
    
    
    // Set field where grouping by time is checked (checkmark)
    self.groupByTime = YES;
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated {

    // set checkmark in section where group by time or group by data is selected
    if (self.groupByTime == YES) {
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
//    NSLog(@"in numberOfSectionsInTableView");
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"in numberOfRowsInSection in tableview %@", tableView);
    
    if (section == 0) {
        return  (NSInteger) 8;
    } else if (section == 1) {
        return (NSInteger) 2;
    }
    return 0;
    
}
//-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Statistic Settings Cell" forIndexPath:indexPath];
//}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"segue itentifier is %@", segue.identifier);
    if ([[segue identifier] isEqualToString:@"Segue statistic details"]) {
        

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];   // Index der selektierten Zeile der Tabelle
        
        NSInteger numberOfDays = 28;
        switch (indexPath.row) {
            case 0:
                numberOfDays = 1;
                break;
            case 1:
                numberOfDays = 2;
                break;
            case 2:
                numberOfDays = 7;
                break;
            case 3:
                numberOfDays = 14;
                break;
            case 4:
                numberOfDays = 28;
                break;
            case 5:
                numberOfDays = 42;
                break;
            case 6:
                numberOfDays = 91;
                break;
            case 7:
                numberOfDays = 182;
                break;
            default:
                break;
        }
        
        
        if (self.fetchedResultsController.fetchedObjects) {
            
            // This is an array with all events in the database that were fetched (all events so far, can be limited some later date)
            NSArray *events = [NSArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
            
            // Create object with statistical data for the array of events
            EventsStatistic *eventsStatForAllEvents = [[EventsStatistic alloc] initWithArrayOfEvents:events] ;
            
            // Retreive an array with arrays of events for time intervals of n days from the set of statistical data
            NSArray *arrayWithArrayOfEventsInTimeIntervals = [eventsStatForAllEvents arrayOfEventsForNumberOfConsecutiveDays:numberOfDays];
            
            
            
            // Loop over the time intervalls
//            for (NSArray *eventsInTimeInterval in arrayWithArrayOfEventsInTimeIntervals) {
//                
//                EventsStatistic *eventsStatForEventsInTimeInterval = [[EventsStatistic alloc] initWithArrayOfEvents:eventsInTimeInterval];
//                
//                NSLog(@"   Stats for the week from %@ to %@", eventsStatForEventsInTimeInterval.firstDay, eventsStatForEventsInTimeInterval.lastDay);
//                NSLog(@"   number of days: %lu", (unsigned long) eventsStatForEventsInTimeInterval.numberOfDays);
//                NSLog(@"   week from %@ to %@ BZ %@", eventsStatForEventsInTimeInterval.firstDay, eventsStatForEventsInTimeInterval.lastDay, eventsStatForEventsInTimeInterval.bloodSugarWeightedAvg);
//                NSLog(@"   Anzahl Tagebucheinträge: %lu", (unsigned long) eventsStatForEventsInTimeInterval.numberOfEntries);
//                NSLog(@"   blood sugar avg (min-max); %@ (%@-%@)", eventsStatForEventsInTimeInterval.bloodSugarAvg, eventsStatForEventsInTimeInterval.bloodSugarMin, eventsStatForEventsInTimeInterval.bloodSugarMax);
//                NSLog(@"   first day: %@, last day: %@, number of days: %ld", eventsStatForEventsInTimeInterval.firstDay, eventsStatForEventsInTimeInterval.lastDay, (long)eventsStatForEventsInTimeInterval.numberOfDays);
//                NSLog(@"   chu daily avg: %@ and chuFactor %@", eventsStatForEventsInTimeInterval.chuDailyAvg, eventsStatForEventsInTimeInterval.chuFactorAvg);
//                NSLog(@"   fpu daily avg: %@ and fpuFactor %@", eventsStatForEventsInTimeInterval.fpuDailyAvg, eventsStatForEventsInTimeInterval.fpuFactorAvg);
//                
//                NSLog(@"   Durchschnitte von Insulin, Bolus, NPH und Basal): %@ (%@ + %@ + %@ ",eventsStatForEventsInTimeInterval.insulinDailyAvg, eventsStatForEventsInTimeInterval.shortBolusDailyAvg, eventsStatForEventsInTimeInterval.fpuBolusDailyAvg, eventsStatForEventsInTimeInterval.basalDosisDailyAvg);
//                
//                NSLog(@"   Mittlerer gewichtet Blutzucker und mittlerer Blutzucker: %@ (%@)", eventsStatForEventsInTimeInterval.bloodSugarWeightedAvg, eventsStatForEventsInTimeInterval.bloodSugarAvg);
//                NSLog(@"   HBA1C: %@", eventsStatForEventsInTimeInterval.hba1c);
//                NSLog(@"   Nahrungsdurchschn: %@ kcal",eventsStatForEventsInTimeInterval.energyDailyAvg);
//            }
            
            [segue.destinationViewController setArrayWithArrayOfEventsInTimeIntervals:arrayWithArrayOfEventsInTimeIntervals];
            [segue.destinationViewController setGroupByTime:self.groupByTime];
        }

        
        
//        [segue.destinationViewController setArrayWithArrayOfEventsInTimeIntervals:arr];            // Property der Klasse Event in DetailViewController setzen
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // Second group with settings for grouping the data
    if (indexPath.section == 1) {

        if (indexPath.row == 0) {
            
            // first row selected: group by time
            self.groupByTime = YES;
            // First row selected: set data property accordingly and set checkmark
            UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            // Delete checkmark in the other cell
            UITableViewCell *otherCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
            otherCell.accessoryType = UITableViewCellAccessoryNone;
            
        } else if (indexPath.row == 1) {
            
            // second row selected: group by data
            self.groupByTime = NO;
            // First row selected: set data property accordingly and set checkmark
            UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            // Delete checkmark in the other cell
            UITableViewCell *otherCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
            otherCell.accessoryType = UITableViewCellAccessoryNone;
        }

        
    }
    
    return;
    
//    TODO: Das hier ist gut und funktioniert, ggf. wieder nutzen
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    if (cell.accessoryType == UITableViewCellAccessoryNone) {
//        
//        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.oldIndexPath];
//        if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
//            oldCell.accessoryType = UITableViewCellAccessoryNone;
//        }
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        
//        self.oldIndexPath = indexPath;
//        
//    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
//        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.oldIndexPath];
//        if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
//            oldCell.accessoryType = UITableViewCellAccessoryNone;
//        }
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        
//        self.oldIndexPath = indexPath;
//    }//cell acctype

    
    return;
    
    
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    NSInteger catIndex = [self.taskCategories indexOfObject:self.currentCategory];
//    if (catIndex == indexPath.row) {
//        return; }
//    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:catIndex inSection:0];
//    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
//    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
//        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
//        self.currentCategory = [self.taskCategories objectAtIndex:indexPath.row];
//    }
//    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
//    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
//        oldCell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    
//    return;
    
//    NSLog(@"Here I am");
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Statistic Settings Cell" forIndexPath:indexPath];
//    
//    if (cell.accessoryType == UITableViewCellAccessoryNone) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    NSLog(@"cell.textlabel.text: %@ in indexPath %@", cell.textLabel.text, indexPath);
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [NSString stringWithFormat:@"Betrachtungsintervalle"];
    } else if (section == 1) {
        return [NSString stringWithFormat:@"Darstellung"];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    // Configure the cell...
    if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"Statistic Settings Cell" forIndexPath:indexPath];

        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"1 Tage";
                break;
            case 1:
                cell.textLabel.text = @"2 Tage";
                break;
            case 2:
                cell.textLabel.text = @"7 Tage";
                break;
            case 3:
                cell.textLabel.text = @"14 Tage";
                break;
            case 4:
                cell.textLabel.text = @"28 Tage";
                break;
            case 5:
                cell.textLabel.text = @"42 Tage";
                break;
            case 6:
                cell.textLabel.text = @"91 Tage";
                break;
            case 7:
                cell.textLabel.text = @"182 Tage";
                break;
            default:
                break;
        }
        
        
    } else if (indexPath.section == 1) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"Statistic Display Options Cell" forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Gruppiert nach Zeit";
                break;
            case 1:
                cell.textLabel.text = @"Gruppiert nach Kennwerten";
                
            default:
                break;
        }
    }    
    return cell;
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



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
