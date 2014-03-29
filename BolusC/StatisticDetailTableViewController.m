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
#import "NSNumber+UPNumberFormats.h"

@interface StatisticDetailTableViewController ()

@property (nonatomic, strong) NSArray *arrayWithEventsStatForEventsInTimeInterval;
@property (nonatomic, strong) NSDateFormatter *dateFormatterForDate;
@property (nonatomic, strong) NSDateFormatter *dateFormatterForShortDate;
@property (nonatomic, strong) NSDateFormatter *dateFormatterForDateWithWeekDay;

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
    if (self.groupByTime == YES) {
        NSLog(@"number of sections: %lu", (long) self.eventsStatInTimeIntervals.count);
        return self.eventsStatInTimeIntervals.count;
    } else {
        return 15;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"number of rows in section no %ld: %lu", (long) section, (unsigned long)[[self.arrayWithArrayOfEventsInTimeIntervals objectAtIndex:section ] count]);
    if (self.groupByTime == YES) {
        return 21;
    } else {
        return self.eventsStatInTimeIntervals.count;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return 20.0;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if (self.groupByTime == YES) {
        EventsStatistic *eventsStatForEventsInTimeInterval = [self.eventsStatInTimeIntervals objectAtIndex:section];
        return [NSString stringWithFormat:@"%@ (%ld Tage)", [self.dateFormatterForDateWithWeekDay stringFromDate:eventsStatForEventsInTimeInterval.firstDay], (long) eventsStatForEventsInTimeInterval.numberOfDays];
    } else {
        EventsStatistic *eventsStatForEventsInTimeInterval = [self.eventsStatInTimeIntervals objectAtIndex:0];
        NSString *sectionString = [[NSString alloc] init];
        switch (section) {
            case 0:
                sectionString =  @"Blutzucker";
                break;
            case 1:
                sectionString =  @"HbA1c";
                break;
            case 2:
                sectionString =  @"Kohlehydrate";
                break;
            case 3:
                sectionString =  @"KHE-Faktor";
                break;
            case 4:
                sectionString =  @"Fett/Eiweiß";
                break;
            case 5:
                sectionString =  @"FPU-Faktor";
                break;
            case 6:
                sectionString =  @"Kalorien";
                break;
            case 7:
                sectionString =  @"Insulinsumme";
                break;
            case 8:
                sectionString =  @"Bolusinsulin";
                break;
            case 9:
                sectionString =  @"NPH-Insulin";
                break;
            case 10:
                sectionString =  @"Basalinsulin";
                break;
            case 11:
                sectionString =  @"von";
                break;
            case 12:
                sectionString =  @"bis";
                break;
            case 13:
                sectionString =  @"Tage";
                break;
            case 14:
                sectionString =  @"Einträge";
                break;
                
            default:
                sectionString =  @"Error in Case";
                break;
        }
        sectionString = [NSString stringWithFormat:@"%@ (je %ld Tage)", sectionString, (long) eventsStatForEventsInTimeInterval.numberOfDays];
        return sectionString;
    }
    
//    EventsStatistic *eventsStatForEventsInTimeInterval = [self.eventsStatInTimeIntervals objectAtIndex:section];
//    return [NSString stringWithFormat:@"%@ (%ld Tage)", [self.dateFormatterForDateWithWeekDay stringFromDate:eventsStatForEventsInTimeInterval.firstDay], (long) eventsStatForEventsInTimeInterval.numberOfDays];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Statistic detail cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (self.groupByTime == YES) {

        EventsStatistic *eventsStatForEventsInTimeInterval = [self.eventsStatInTimeIntervals objectAtIndex:indexPath.section];
        CGFloat sum = 0.0;
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Blutzucker";
                
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@-%@) mg/dl",
                                             [eventsStatForEventsInTimeInterval.bloodSugarWeightedAvg stringWithNumberStyle0maxDigits],
                                             eventsStatForEventsInTimeInterval.bloodSugarMin,
                                             eventsStatForEventsInTimeInterval.bloodSugarMax];
                break;
            case 1:
                cell.textLabel.text = @"HbA1c";
                cell.detailTextLabel.text = [eventsStatForEventsInTimeInterval.hba1c stringWithNumberStyle1maxDigits];
                break;
            case 2:
                cell.textLabel.text = @"Kohlehydrate";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ KHE",
                                             [eventsStatForEventsInTimeInterval.chuDailyAvg stringWithNumberStyle1maxDigits]];
                break;
            case 3:
                cell.textLabel.text = @"KHE-Faktor";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@ eff.) IE/KHE",
                                             [eventsStatForEventsInTimeInterval.chuFactorAvg stringWithNumberStyle2maxDigits],
                                             [eventsStatForEventsInTimeInterval.effectiveChuFactorAvg stringWithNumberStyle2maxDigits]];
                break;
            case 4:
                cell.textLabel.text = @"Fett/Eiweiß";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ FPE",
                                             [eventsStatForEventsInTimeInterval.fpuDailyAvg stringWithNumberStyle1maxDigits]];
                break;
            case 5:
                cell.textLabel.text = @"FPU-Faktor";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@ eff.) IE/KHE",
                                             [eventsStatForEventsInTimeInterval.fpuFactorAvg stringWithNumberStyle2maxDigits],
                                             [eventsStatForEventsInTimeInterval.effectiveFpuFactorAvg stringWithNumberStyle2maxDigits]];
                break;
            case 6:
                cell.textLabel.text = @"Kalorien";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ kcal",
                                             [eventsStatForEventsInTimeInterval.energyDailyAvg stringWithNumberStyle0maxDigits]];
                break;
            case 7:
                cell.textLabel.text = @"Insulinsumme";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE",
                                             [eventsStatForEventsInTimeInterval.insulinDailyAvg stringWithNumberStyle1maxDigits]];
                break;
            case 8:
                cell.textLabel.text = @"Bolusinsulin";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE, inkl. %@ Korr. (+%@/%@)",
                                             [eventsStatForEventsInTimeInterval.shortBolusDailyAvg stringWithNumberStyle1maxDigits],
                                             [eventsStatForEventsInTimeInterval.correctionBolusDailyAvg stringWithNumberStyle2maxDigits],
                                             [eventsStatForEventsInTimeInterval.positiveCorrectionBolusDailyAvg stringWithNumberStyle2maxDigits],
                                             [eventsStatForEventsInTimeInterval.negativeCorrectionBolusDailyAvg stringWithNumberStyle2maxDigits]];
                break;
            case 9:
                cell.textLabel.text = @"NPH-Insulin";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE",
                                             [eventsStatForEventsInTimeInterval.fpuBolusDailyAvg stringWithNumberStyle1maxDigits]];
                break;
                break;
            case 10:
                cell.textLabel.text = @"Basalinsulin";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE",
                                             [eventsStatForEventsInTimeInterval.basalDosisDailyAvg stringWithNumberStyle1maxDigits]];
                break;
            case 11:
                cell.textLabel.text = @"von";
                cell.detailTextLabel.text = [self.dateFormatterForDateWithWeekDay stringFromDate:eventsStatForEventsInTimeInterval.firstDay];
                break;
            case 12:
                cell.textLabel.text = @"bis";
                cell.detailTextLabel.text = [self.dateFormatterForDateWithWeekDay stringFromDate:eventsStatForEventsInTimeInterval.lastDay];
                break;
            case 13:
                cell.textLabel.text = @"Tage";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",
                                             (long) eventsStatForEventsInTimeInterval.numberOfDays];
                break;
            case 14:
                cell.textLabel.text = @"Einträge";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld (%@ pro Tag)",
                                             (long) eventsStatForEventsInTimeInterval.numberOfEntries,
                                             [eventsStatForEventsInTimeInterval.numberOfEntriesPerDay stringWithNumberStyle1maxDigits]];
                break;
            case 15:
                cell.textLabel.text = @"Messungen";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ pro Tag",
                                            [eventsStatForEventsInTimeInterval.numberOfBloodSugarMeasurementsPerDay stringWithNumberStyle1maxDigits]];
                break;
                
            case 16:
                cell.textLabel.text = @"Insulingaben";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ pro Tag (%@/%@/%@) Boli/NPH/Basal",
                                             [eventsStatForEventsInTimeInterval.numberOfInjectionsPerDay stringWithNumberStyle1maxDigits],
                                             [eventsStatForEventsInTimeInterval.numberOfShortBolusInjectionsPerDay stringWithNumberStyle1maxDigits],
                                             [eventsStatForEventsInTimeInterval.numberOfFpuBolusInjectionsPerDay stringWithNumberStyle1maxDigits],
                                             [eventsStatForEventsInTimeInterval.numberOfBasalDosisInjectionsPerDay stringWithNumberStyle1maxDigits]];
                break;
            case 17:
                cell.textLabel.text = @"Nährwerte";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@/%@ g pro Tag KH/Eiweiß/Fett",
                                             [eventsStatForEventsInTimeInterval.carbsPerDay stringWithNumberStyle0maxDigits],
                                             [eventsStatForEventsInTimeInterval.proteinPerDay stringWithNumberStyle0maxDigits],
                                             [eventsStatForEventsInTimeInterval.fatPerDay stringWithNumberStyle0maxDigits]];
                break;
            case 18:
                cell.textLabel.text = @"Nährwerte";
                sum = eventsStatForEventsInTimeInterval.carbsPerDay.floatValue + eventsStatForEventsInTimeInterval.proteinPerDay.floatValue + eventsStatForEventsInTimeInterval.fatPerDay.floatValue;
                if (sum > 0) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@/%@ Gewichts-%%  KH/Eiweiß/Fett (%@ g insgesamt)",
                                                 [[NSNumber numberWithFloat: eventsStatForEventsInTimeInterval.carbsPerDay.floatValue   * 100.0 / sum] stringWithNumberStyle0maxDigits],
                                                 [[NSNumber numberWithFloat: eventsStatForEventsInTimeInterval.proteinPerDay.floatValue * 100.0 / sum] stringWithNumberStyle0maxDigits],
                                                 [[NSNumber numberWithFloat: eventsStatForEventsInTimeInterval.fatPerDay.floatValue     * 100.0 / sum] stringWithNumberStyle0maxDigits],
                                                 [[NSNumber numberWithFloat:sum] stringWithNumberStyle0maxDigits]];
                }
                break;
            case 19:
                cell.textLabel.text = @"Nährwerte";
                sum = 4.0 * eventsStatForEventsInTimeInterval.carbsPerDay.floatValue + 4.0 * eventsStatForEventsInTimeInterval.proteinPerDay.floatValue + 9.0 * eventsStatForEventsInTimeInterval.fatPerDay.floatValue;
                if (sum > 0) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@/%@ Energie-%%  KH/Eiweiß/Fett (%@ kcal insgesamt)",
                                                 [[NSNumber numberWithFloat: eventsStatForEventsInTimeInterval.carbsPerDay.floatValue   * 400.0 / sum] stringWithNumberStyle0maxDigits],
                                                 [[NSNumber numberWithFloat: eventsStatForEventsInTimeInterval.proteinPerDay.floatValue * 400.0 / sum] stringWithNumberStyle0maxDigits],
                                                 [[NSNumber numberWithFloat: eventsStatForEventsInTimeInterval.fatPerDay.floatValue     * 900.0 / sum] stringWithNumberStyle0maxDigits],
                                                 [[NSNumber numberWithFloat:sum] stringWithNumberStyle0maxDigits]];
                }
                break;
            case 20:
                // Verallgemeinern zu Tagen, an denen der Kommentar den String 'text' enthält
                cell.textLabel.text = @"Sporttage";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", eventsStatForEventsInTimeInterval.daysWithCommentsContainingSport];
                break;
                
            default:
                cell.textLabel.text = @"Error in Case";
                cell.detailTextLabel.text = @"Uwe, you gotta check this";
                break;
        }

    
    } else {
        EventsStatistic *eventsStatForEventsInTimeInterval = [self.eventsStatInTimeIntervals objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",
                               [self.dateFormatterForShortDate stringFromDate:eventsStatForEventsInTimeInterval.firstDay],
                               [self.dateFormatterForShortDate stringFromDate:eventsStatForEventsInTimeInterval.lastDay]];
        
        switch (indexPath.section) {
            case 0:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\t(%@-%@) mg/dl",
                                             [eventsStatForEventsInTimeInterval.bloodSugarWeightedAvg stringWithNumberStyle0maxDigits],
                                             eventsStatForEventsInTimeInterval.bloodSugarMin,
                                             eventsStatForEventsInTimeInterval.bloodSugarMax];
                break;
            case 1:
                cell.detailTextLabel.text = [eventsStatForEventsInTimeInterval.hba1c stringWithNumberStyle1maxDigits];
                break;
            case 2:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ KHE",
                                             [eventsStatForEventsInTimeInterval.chuDailyAvg stringWithNumberStyle1maxDigits]];
                break;
            case 3:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@ eff.) IE/KHE",
                                             [eventsStatForEventsInTimeInterval.chuFactorAvg stringWithNumberStyle2maxDigits],
                                             [eventsStatForEventsInTimeInterval.effectiveChuFactorAvg stringWithNumberStyle2maxDigits]];
                break;
            case 4:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ FPE",
                                             [eventsStatForEventsInTimeInterval.fpuDailyAvg stringWithNumberStyle1maxDigits]];
                break;
            case 5:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@ eff.) IE/KHE",
                                             [eventsStatForEventsInTimeInterval.fpuFactorAvg stringWithNumberStyle2maxDigits],
                                             [eventsStatForEventsInTimeInterval.effectiveFpuFactorAvg stringWithNumberStyle2maxDigits]];
                break;
            case 6:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ kcal",
                                             [eventsStatForEventsInTimeInterval.energyDailyAvg stringWithNumberStyle0maxDigits]];
                break;
            case 7:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE",
                                             [eventsStatForEventsInTimeInterval.insulinDailyAvg stringWithNumberStyle1maxDigits]];
                break;
            case 8:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@ Korr.) IE",
                                             [eventsStatForEventsInTimeInterval.shortBolusDailyAvg stringWithNumberStyle1maxDigits],
                                             [eventsStatForEventsInTimeInterval.correctionBolusDailyAvg stringWithNumberStyle2maxDigits]];
                break;
            case 9:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE",
                                             [eventsStatForEventsInTimeInterval.fpuBolusDailyAvg stringWithNumberStyle1maxDigits]];
                break;
                break;
            case 10:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ IE",
                                             [eventsStatForEventsInTimeInterval.basalDosisDailyAvg stringWithNumberStyle1maxDigits]];
                break;
            case 11:
                cell.detailTextLabel.text = [self.dateFormatterForDateWithWeekDay stringFromDate:eventsStatForEventsInTimeInterval.firstDay];
                break;
            case 12:
                cell.detailTextLabel.text = [self.dateFormatterForDateWithWeekDay stringFromDate:eventsStatForEventsInTimeInterval.lastDay];
                break;
            case 13:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",
                                             (long) eventsStatForEventsInTimeInterval.numberOfDays];
                break;
            case 14:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",
                                             (long) eventsStatForEventsInTimeInterval.numberOfEntries];
                break;
                
            default:
                cell.detailTextLabel.text = @"Uwe, you gotta check this";
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


-(NSDateFormatter *) dateFormatterForDate {
    if (!_dateFormatterForDate) {
        _dateFormatterForDate = [[NSDateFormatter alloc] init];  // Initialize Date Formatter
        _dateFormatterForDate.dateFormat = @"yyyy-MM-dd HH:mm";                          // Specify the date format
    }
    return _dateFormatterForDate;
}

-(NSDateFormatter *) dateFormatterForDateWithWeekDay {
    if (!_dateFormatterForDateWithWeekDay) {
        _dateFormatterForDateWithWeekDay = [[NSDateFormatter alloc] init];  // Initialize Date Formatter
        _dateFormatterForDateWithWeekDay.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEE dd.MM.yyyy HH:mm" options:0 locale:[NSLocale currentLocale]];
    }
    return _dateFormatterForDateWithWeekDay;
}
-(NSDateFormatter *) dateFormatterForShortDate {
    if (!_dateFormatterForShortDate) {
        _dateFormatterForShortDate = [[NSDateFormatter alloc] init];
        _dateFormatterForShortDate.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dd.MM." options:0 locale:[NSLocale currentLocale]];
    }
    return _dateFormatterForShortDate;
}

@end
