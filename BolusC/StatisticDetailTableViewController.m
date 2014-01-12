//
//  StatisticDetailTableViewController.m
//  BolusC
//
//  Created by Uwe Petersen on 12.01.14.
//  Copyright (c) 2014 Uwe Petersen. All rights reserved.
//

#import "StatisticDetailTableViewController.h"
#import "Event.h"
#import "Event+Extensions.h"
#import "EventsStatistic.h"

@interface StatisticDetailTableViewController ()

@property (nonatomic, strong) NSArray *arrayWithEventsStatForEventsInTimeInterval;

@end

@implementation StatisticDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // Statistical calulations shall only be done once, i.e. here (and not in cellForRowAtIndexPath)
    if (!self.eventsStatInTimeIntervals) {
        self.eventsStatInTimeIntervals = [[NSMutableArray alloc] init];
        for (NSArray *eventsInTimeIntervall in self.arrayWithArrayOfEventsInTimeIntervals) {
            
            // Loop delivers arrays of events. From these calculate statistics and put them in to the corresponding property
            [self.eventsStatInTimeIntervals addObject:[[EventsStatistic alloc] initWithArrayOfEvents:eventsInTimeIntervall]];
        }
    }
//    self.eventsStatForEventsInTimeInterval = [[EventsStatistic alloc] initWithArrayOfEvents:[self.arrayWithArrayOfEventsInTimeIntervals objectAtIndex:indexPath.row]];

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
    NSLog(@"number of sections: %lu", (long) self.eventsStatInTimeIntervals.count);
    return self.eventsStatInTimeIntervals.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"number of rows in section no %ld: %lu", (long) section, (unsigned long)[[self.arrayWithArrayOfEventsInTimeIntervals objectAtIndex:section ] count]);
    return 15;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return 20.0;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    EventsStatistic *eventsStatForEventsInTimeInterval = [self.eventsStatInTimeIntervals objectAtIndex:section];
    return [NSString stringWithFormat:@"%@ (%ld Tage)", eventsStatForEventsInTimeInterval.firstDay.description, (long) eventsStatForEventsInTimeInterval.numberOfDays];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Statistic detail cell" forIndexPath:indexPath];
    
    // Configure the cell...
//    EventsStatistic *eventsStatForEventsInTimeInterval = [[EventsStatistic alloc] initWithArrayOfEvents:[self.arrayWithArrayOfEventsInTimeIntervals objectAtIndex:indexPath.row]];
//    
    EventsStatistic *eventsStatForEventsInTimeInterval = [self.eventsStatInTimeIntervals objectAtIndex:indexPath.section];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Blutzucker";
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@-%@) mg/dl",
                                         eventsStatForEventsInTimeInterval.bloodSugarWeightedAvg,
                                         eventsStatForEventsInTimeInterval.bloodSugarMin,
                                         eventsStatForEventsInTimeInterval.bloodSugarMax];
            break;
        case 1:
            cell.textLabel.text = @"HBA1C";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                         eventsStatForEventsInTimeInterval.hba1c];
            break;
        case 2:
            cell.textLabel.text = @"Kohlehydrate";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ KHE",
                                         eventsStatForEventsInTimeInterval.chuDailyAvg];
            break;
        case 3:
            cell.textLabel.text = @"KHE-Faktor";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE/KHE",
                                         eventsStatForEventsInTimeInterval.chuFactorAvg];
            break;
        case 4:
            cell.textLabel.text = @"Fett/Eiweiß";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ FPE",
                                         eventsStatForEventsInTimeInterval.fpuDailyAvg];
            break;
        case 5:
            cell.textLabel.text = @"FPU-Faktor";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                         eventsStatForEventsInTimeInterval.fpuFactorAvg];
            break;
        case 6:
            cell.textLabel.text = @"Kalorien";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ kcal",
                                         eventsStatForEventsInTimeInterval.energyDailyAvg];
            break;
        case 7:
            cell.textLabel.text = @"Insulin";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE",
                                         eventsStatForEventsInTimeInterval.insulinDailyAvg];
            break;
        case 8:
            cell.textLabel.text = @"Korrektur/Kohlehydrate";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE",
                                         eventsStatForEventsInTimeInterval.shortBolusDailyAvg];
            break;
        case 9:
            cell.textLabel.text = @"Fett/Protein";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE",
                                         eventsStatForEventsInTimeInterval.fpuBolusDailyAvg];
            break;
            break;
        case 10:
            cell.textLabel.text = @"Basal";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE",
                                         eventsStatForEventsInTimeInterval.basalDosisDailyAvg];
            break;
        case 11:
            cell.textLabel.text = @"von";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                         eventsStatForEventsInTimeInterval.firstDay];
            break;
        case 12:
            cell.textLabel.text = @"bis";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                         eventsStatForEventsInTimeInterval.lastDay];
            break;
        case 13:
            cell.textLabel.text = @"Anzahl Tage";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",
                                         (long) eventsStatForEventsInTimeInterval.numberOfDays];
            break;
        case 14:
            cell.textLabel.text = @"Tagebucheinträge";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",
                                         (long) eventsStatForEventsInTimeInterval.numberOfEntries];
            break;
           

        default:
            cell.textLabel.text = @"Error in Case";
            cell.detailTextLabel.text = @"Uwe, you gotta check this";
            break;
    }
    
    
    return cell;
}




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

@end
