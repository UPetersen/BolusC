//
//  PlayingCardView.m
//  Super Card
//
//  Created by Uwe Petersen on 22.10.13.
//  Copyright (c) 2013 Uwe Petersen. All rights reserved.
//
// TODO
//  1. Reverse loop over data from older to newer data values to ensure that newest data lies on top
//  2. Add data points beyond the left and right borders (and then clip at the borders, i.e. 0 and 24 hours) to have solid lines that span the whole time range (but only if a data point exists for the preceeding and following day)
//  5. generalize this view and clearly seperate data (the model) from the view stuff
//  6. Add x- and y-labels (with units) and a title
//  7. Maybe draw x- and y-Ticks over the lines of the grid (therefore they would need a colored background which would have to match the varying colored background of the canvas -- sounds maybe too difficult to handle and, thus, would mean to better draw the ticks outside of the data rectangle which on should better do anyway, if one had more space...)
//  8. Rename this view to e.g. DayView and get rid of the old stuff from PlayingCardView not needed here.
//  9.Die Sachen zu managedObjectContext muessen hier raus.
//  11. Handle rotation of the device and ensure that paning and pinching ist possible all over the view area in horizontal orientation
//  12. Set the views background color, rather than filling a rect for the very same purpose
//  13. Paning doesn't work for gridlines with a value of zero. Use two array to overcome this:
//      a) An array of CGFloats for where the gridlines are supposed to be drawn (and thus don't use the array of NSNumber elements any more
//      b) A corresponding NSArray with NSString elements to be displayed at these positions

//  Solved already:
//  3. Apply horizontal and vertical scaling seperately (see link stored in Safari) and, when this is finally implemented,
//  4. ensure that paning does no more implizit scaling (as it now does, when a border is reached). To do this, for instance, don't allow max_x to grow, when min_x has reached its limit (DEFAULT_... or MIN_MIN... in the case of the y-axis)
//  10. Add MIN_MIN_x and MAX_MAX_X to allow panning over the 0- and 24-hour border and have a look at the data at night (use negative values in calculations and text labels according to the real hour of day? --> would mean to work with an array that stores two values, which should work)


// A C H T U N G, wenn das ganze funktionieren soll, im Storyboard opaque abwählen

#import "BloodSugarGraphView.h"
#import "Event.h"
#import "Event+Extensions.h"
#import "AppDelegate.h"

@interface BloodSugarGraphView()
//@property (nonatomic) CGFloat faceCardScaleFactor;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGPoint point;
@property (nonatomic) NSMutableArray *points;

@property (nonatomic) CGFloat scaleFactorX;
@property (nonatomic) CGFloat scaleFactorY;
@property (nonatomic) CGFloat scaleAngle;
@property (nonatomic) CGFloat min_x;
@property (nonatomic) CGFloat max_x;
@property (nonatomic) CGFloat min_y;
@property (nonatomic) CGFloat max_y;
@end

@implementation BloodSugarGraphView

// Core Data stuff
@synthesize managedObjectContext = _managedObjectContext;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

// stuff for conversion between view coordinates and the coordinates of the data
@synthesize scaleFactorX = _scaleFactorX;  // because we provide setter and getter
@synthesize scaleFactorY = _scaleFactorY;
@synthesize scaleAngle = _scaleAngle;
@synthesize min_x = _min_x;
@synthesize max_x = _max_x;
@synthesize min_y = _min_y;
@synthesize max_y = _max_y;

#define DEFAULT_MIN_X 0.0    // min x value in data coordinate system for initial view
#define DEFAULT_MAX_X 24.0    // ...
#define DEFAULT_MIN_Y 40.0    // ...
#define DEFAULT_MAX_Y 160.0   // ...

#define MIN_MIN_X -2400.0         // min x value in data coordinate system the view can be paned or scaled to
#define MAX_MAX_X 28.0        // ..
#define MIN_MIN_Y 10.0         // ..
#define MAX_MAX_Y 500.0       // ..

// colored rectangles in the background
#define MIN_BLOOD_SUGAR_RED_RANGE MIN_MIN_Y
#define MAX_BLOOD_SUGAR_RED_RANGE MAX_MAX_Y
#define MIN_BLOOD_SUGAR_YELLOW_RANGE 60.0
#define MAX_BLOOD_SUGAR_YELLOW_RANGE 130.0
#define MIN_BLOOD_SUGAR_GREEN_RANGE 70.0
#define MAX_BLOOD_SUGAR_GREEN_RANGE 100.0
#define BLOOD_SUGAR_GOAL 84.


// old stuff from superCard, to be deleted
#define DEFAULT_SCALE_ANGLE M_PI/2.0
#define CORNER_RADIUS 12.0
#define CORNER_TEXT_ORIGIN_X 2.0
#define CORNER_TEXT_ORIGIN_Y 2.0
#define DEFAULT_FACE_CARD_SACLE_FACTOR 0.90


# pragma mark - setter/getter for x/y boundaries and scale factors

-(void) setMin_x:(CGFloat)min_x
{
    _min_x = MAX(min_x, MIN_MIN_X);
    [self setNeedsDisplay];
}
-(void) setMax_x:(CGFloat)max_x
{
    _max_x = MIN(max_x, MAX_MAX_X);
    [self setNeedsDisplay];
}
-(void) setMin_y:(CGFloat)min_y
{
    _min_y = MAX(min_y, MIN_MIN_Y);
    [self setNeedsDisplay];
}
-(void) setMax_y:(CGFloat)max_y
{
    _max_y = MIN(max_y, MAX_MAX_Y);
    [self setNeedsDisplay];
}

-(CGFloat) min_x
{
    if (!_min_x) _min_x = DEFAULT_MIN_X;
    return _min_x;
}
-(CGFloat) max_x
{
    if (!_max_x) _max_x = DEFAULT_MAX_X;
    return _max_x;
}
-(CGFloat) min_y
{
    if (!_min_y) _min_y = DEFAULT_MIN_Y;
    return _min_y;
}
-(CGFloat) max_y
{
    if (!_max_y) _max_y = DEFAULT_MAX_Y;
    return _max_y;
}

-(CGFloat) scaleFactorX
{
    _scaleFactorX = (self.bounds.size.width - self.bounds.origin.x) / (self.max_x - self.min_x);
    return _scaleFactorX;
}
-(CGFloat) scaleFactorY
{
    _scaleFactorY = (self.bounds.size.height - self.bounds.origin.y) / (self.max_y - self.min_y);
    return _scaleFactorY;
}


# pragma mark - methods to convert from data coordinate systeme to view coordinate system


-(CGPoint) convertToPointInViewCoordinates: (CGPoint) point
{
    if (point.x && point.y) {
        return CGPointMake( (-self.min_x + point.x ) * self.scaleFactorX , ( self.max_y - point.y ) *  self.scaleFactorY );
    } else {
        return CGPointMake(0.0, 0.0);
    }
}
-(CGPoint) convertToPointInViewCoordinatesX: (CGFloat) x y: (CGFloat) y
{
    if (x && y) {
//        return CGPointMake( -self.min_x + self.scaleFactorX * (CGFloat) x , self.max_y - self.scaleFactorY * (CGFloat)y );
        return CGPointMake( (-self.min_x + (CGFloat) x) * self.scaleFactorX , ( self.max_y - (CGFloat) y ) * self.scaleFactorY );
    } else {
        return CGPointMake(0.0, 0.0);
    }
}
-(CGFloat) convertToViewCoordinatesX: (CGFloat) x
{
    if ( x ) {
//        return (CGFloat) -self.min_x + self.scaleFactorX * (CGFloat) x;
        return (-self.min_x + (CGFloat) x ) * self.scaleFactorX;
    } else {
        return 0.0;
    }
}
-(CGFloat) convertToViewCoordinatesY: (CGFloat) y
{
    if ( y ) {
//        return (CGFloat) self.max_y - self.scaleFactorY * (CGFloat)y;
        return (self.max_y - (CGFloat) y) *self.scaleFactorY;
    } else {
        return 0.0;
    }
}

//-(CGFloat) scaleAngle
//{
//    if (!_scaleAngle) _scaleAngle = DEFAULT_SCALE_ANGLE; // Lazy getter
//    return _scaleAngle;
//}
//-(void)setScaleAngle:(CGFloat)scaleAngle
//{
//    _scaleAngle = scaleAngle;
//}
//


#pragma mark - Initialization

//-(void) setPoints:(NSMutableArray *)points {
//    _points = points;
//}

-(CGFloat) hourOfDay: (NSDate *) timestamp
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:timestamp];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    return (CGFloat) (hour + ((CGFloat) minute )/ 60.0);
}

-(void)setup
{
    // do initialization here
}

-(void)awakeFromNib
{
    [self setup];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}


# pragma gesture recognizers

-(void)pan:(UIPanGestureRecognizer *)gesture {
   if((gesture.state == UIGestureRecognizerStateChanged) ||
      (gesture.state == UIGestureRecognizerStateEnded)) {
       CGPoint translation = [gesture translationInView:self];
       
       // Convert translation which is obtained in the view coordinate systeme to the units displayed
       CGFloat scaledTranslationX = translation.x / self.scaleFactorX;
       if ( (0 < scaledTranslationX  &&  MIN_MIN_X < self.min_x) ||
            (scaledTranslationX < 0  &&  self.max_x <  MAX_MAX_X)) {  // pan to right/left only if left/right limit is not yet reached
           self.min_x = self.min_x - scaledTranslationX;
           self.max_x = self.max_x - scaledTranslationX;
       }
       CGFloat scaledTranslationY = translation.y / self.scaleFactorY;
       if (( 0 > scaledTranslationY  &&  MIN_MIN_Y < self.min_y) ||  // pan up-/downwards only if lower/upper limit is not yet reached
           ( scaledTranslationY > 0  &&  self.max_y < MAX_MAX_Y) ){
               self.min_y = self.min_y + scaledTranslationY;
               self.max_y = self.max_y + scaledTranslationY;
           }
       
       [gesture setTranslation:CGPointMake(0.0, 0.0) inView:self]; // reset to ensure paning in small increments only
   }
}

-(void)pinch:(UIPinchGestureRecognizer *)gesture {
    if ((gesture.state == UIGestureRecognizerStateChanged)||
        (gesture.state == UIGestureRecognizerStateEnded)) {
//        self.faceCardScaleFactor *= gesture.scale;
        
        // Check that two touches were recognized (this es because once testing execution the program throwed an exception where index 1 (of touch1) was out of bounds
        if ([gesture numberOfTouches] >=2) {

            // Calculate angle between the two touches (i.e. position of the two fingers)
            CGPoint touchPosition0 = [gesture locationOfTouch:0 inView:self];  // position of first finger in view coordinates
            CGPoint touchPosition1 = [gesture locationOfTouch:1 inView:self];  // position of second finger in view coordinates
            
            // Calculate scale parts in x- and y-direction directly (without using atan and sin and cos)
            CGFloat distanceX = fabsf(touchPosition1.x-touchPosition0.x);              // distance between two touches in x-direction
            CGFloat distanceY = fabsf(touchPosition1.y-touchPosition0.y);              // distance between two touches in y-direction
            CGFloat distance = sqrtf( distanceX * distanceX + distanceY * distanceY);  // distance between the two touches
            CGFloat dummy = (gesture.scale - 1.0) / distance;                          // (kind of normalized) distance between new and old touch positions (i.e. the delta)
            CGFloat gestureScaleX = 1.0 + dummy * distanceX;  // resulting scale in x-direction
            CGFloat gestureScaleY = 1.0 + dummy * distanceY;  // resulting scale in y-direction
            
            // Calculate the new range (more precise: half of it) from the scale factor obtained from the gesture (i.e. the distance between the new minimum and the new maximum) (all in data coordinates
            CGFloat xHalfNewRange = (self.max_x - self.min_x) / 2.0 / gestureScaleX;
            // Calculate the current center of the current range (in data coordinates)
            CGFloat xMiddle = (self.min_x + self.max_x) / 2.0;
            //Calculate the new min and max values of the data range (which is the basis for all the scaling and drawing etc.)
            self.min_x = xMiddle - xHalfNewRange;
            self.max_x = xMiddle + xHalfNewRange;
            
            // dito for y-direction
            CGFloat yHalfNewRange = (self.max_y - self.min_y) / 2.0 / gestureScaleY;
            CGFloat yMiddle = (self.min_y + self.max_y) / 2.0;
            self.min_y = yMiddle - yHalfNewRange;
            self.max_y = yMiddle + yHalfNewRange;
            
            gesture.scale = 1; // damit immer nur inkrementell gescaled wird
            
        }
    }
}


# pragma mark - Drawing stuff

 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect  // Die Spielkartenfläche zeichnen
{
    
    // Draw a rectangle for both, green and yellow blood sugar range
    
    // red blood sugar range rectangle
    UIBezierPath *bloodSugarRangeRect = [UIBezierPath bezierPathWithRect:CGRectMake(0.0,
                                                                                    (self.max_y - MAX_BLOOD_SUGAR_RED_RANGE) * self.scaleFactorY,
                                                                                    self.bounds.size.width,
                                                                                    (MAX_BLOOD_SUGAR_RED_RANGE - MIN_BLOOD_SUGAR_RED_RANGE) * self.scaleFactorY)];
    [[UIColor colorWithHue:0.0 saturation:0.25 brightness:1.0 alpha:1.0] setFill]; // Direkte Angabe der Farbe rot im HSV-Farbraum für blasse Farben (erlaubt alpha=1)
    [bloodSugarRangeRect fill];                                                    // Rechteck farbig malen

    // Yellow blood sugar range rectangle
    bloodSugarRangeRect = [UIBezierPath bezierPathWithRect:CGRectMake(0.0, (self.max_y - MAX_BLOOD_SUGAR_YELLOW_RANGE) * self.scaleFactorY,
                                                                                    self.bounds.size.width,
                                                                                    (MAX_BLOOD_SUGAR_YELLOW_RANGE - MIN_BLOOD_SUGAR_YELLOW_RANGE) * self.scaleFactorY)];
    [[UIColor colorWithHue:1./7. saturation:0.25 brightness:1.0 alpha:1.0] setFill]; // Direkte Angabe der Farbe gelb im HSV-Farbraum für blasse Farben
    [bloodSugarRangeRect fill];                                                    // Rechteck farbig malen
    
    // Green blood sugar range rectangle
    bloodSugarRangeRect = [UIBezierPath bezierPathWithRect:CGRectMake(0.0, (self.max_y - MAX_BLOOD_SUGAR_GREEN_RANGE) * self.scaleFactorY,
                                                                                    self.bounds.size.width,
                                                                                    (MAX_BLOOD_SUGAR_GREEN_RANGE - MIN_BLOOD_SUGAR_GREEN_RANGE) * self.scaleFactorY )];
    [[UIColor colorWithHue:1./3. saturation:0.25 brightness:1.0 alpha:1.0] setFill]; // Direkte Angabe der Farbe grün im HSV-Farbraum für blasse Farben
    [bloodSugarRangeRect fill];                                                      // Rechteck farbig malen
    
    // Draw horizontal and vertical lines for grid
    
    // horizontal lines (y-lines)
    UIBezierPath *gridLines = [[UIBezierPath alloc] init];
    NSArray *yGridValues = @[@20,@40,@50,@60,@70,@80,@90,@100,@110,@120,@130,@140,@160,@180,@200,@250,@300,@350,@400,@450,@500];
    for (NSNumber *yValue in yGridValues){
//        CGFloat yVal = (self.max_y - [yValue floatValue]) * self.scaleFactorY;
        CGFloat yVal = [self convertToViewCoordinatesY:[yValue floatValue]];
        [gridLines moveToPoint:   CGPointMake(self.bounds.origin.x,  yVal)]; // start point of grid line
        [gridLines addLineToPoint:CGPointMake(self.bounds.size.width,yVal)]; // end point of grid line
    }
    // vertical lines (x-lines)
    NSArray *xGridValues = @[@(-2016),@(-1344),@(-1176),@(-1008),@(-840),@(-672),@(-504),@(-336),@(-168),@(-144),@(-120),@(-96),@(-72),@(-48),@(-24),@(-18),@(-12),@(-6),@(-3),@(0.001),@3,@6,@9,@12,@15,@18,@21,@24,@27];
    for (NSNumber *xValue in xGridValues){
//        CGFloat xVal = (-self.min_x + [xValue floatValue] ) * self.scaleFactorX;
        CGFloat xVal = [self convertToViewCoordinatesX:[xValue floatValue]];
        [gridLines moveToPoint:   CGPointMake(xVal, self.bounds.origin.y)];    // start point of grid line
        [gridLines addLineToPoint:CGPointMake(xVal, self.bounds.size.height)]; // end point of grid line
    }
    CGFloat dashPattern[] = {1,2};
    [gridLines setLineDash:dashPattern count:2 phase:0.0]; // Make'm dashed
    
    [[UIColor grayColor] setStroke];
    [gridLines stroke];
    
    
    // Draw grid annotation text (the grid line values)

    [self drawTextForXGrid:xGridValues forYGrid:yGridValues];

    
    // Draw one single line for the blood sugar goal
    
    UIBezierPath *bloodSugarGoalLine = [UIBezierPath new];
//    CGFloat yVal =(self.max_y - BLOOD_SUGAR_GOAL) * self.scaleFactorY;
    CGFloat yVal = [self convertToViewCoordinatesY:BLOOD_SUGAR_GOAL];
    [bloodSugarGoalLine moveToPoint:   CGPointMake(self.bounds.origin.x,   yVal)];
    [bloodSugarGoalLine addLineToPoint:CGPointMake(self.bounds.size.width, yVal)];
    [[UIColor greenColor] setStroke];
    [bloodSugarGoalLine setLineWidth:4.0];
    [bloodSugarGoalLine stroke];
    
    [self drawLine];
}

-(void) drawLine
{
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    int i = 0;
    
    if (self.fetchedResultsController.fetchedObjects) {
        
        Event *newestEvent = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
        self.point = [self convertToPointInViewCoordinatesX:[[newestEvent hourOfDay] floatValue]
                                                          y:[newestEvent.bloodSugar floatValue]];
        [path moveToPoint:self.point];
        
        // Loop over fetched data is going from newest to oldest values (otherwhise use reverseObjectEnumerator)
        for (Event *event in self.fetchedResultsController.fetchedObjects) {
            if (event.bloodSugar) {
                
                NSTimeInterval timeDiffInHours = [newestEvent.timeStamp timeIntervalSinceDate:event.timeStamp]/3600.0;
                self.point = [self convertToPointInViewCoordinatesX:([[newestEvent hourOfDay] floatValue] - (CGFloat) timeDiffInHours)
                                                                  y:[event.bloodSugar floatValue]];
                
                // Set Color according to no of day (wandering through the hue space from red to ..., wikipedia has a good reference)
                [[UIColor colorWithHue:1.-(CGFloat)(i)/6.0 saturation:1.0 brightness:1.0 alpha:1.0] setStroke];
                [path setLineWidth:2.0];
                // set linewidth according to the no of day
                //                CGFloat linewidth = MAX(6.*(1.0 - (CGFloat) lineNumber / 3.0), 1.0); // From linewidth 6 downwards to one in three steps
                //                [path setLineWidth:linewidth];
                [path addLineToPoint:self.point];  // Continue the line, since it's still on the same day
                
                // If value is out of x-Range, no more calulation and display needed
                if ([[newestEvent hourOfDay] floatValue]-(CGFloat) timeDiffInHours < self.min_x) {
                    NSLog(@"Break because below self.min = %g", self.min_x);
                    break;
                }
                
                // A C H T U N G  break hier, nach n Werten, der Einfachheit halber erst mal so
                i++;
                if (i>=700) break;
            }
        }
        [path stroke];
    }
}

-(void) drawLineForEachDay
{
    // Draw the data lines (one line for each day to be plotted)
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    int i = 0;
    int lineNumber = 0;
    CGFloat lastXValue = DEFAULT_MIN_X;
    
    //
    // Loop over fetched data is going from newest to oldest values (otherwhise use reverseObjectEnumerator)
    for (Event *event in self.fetchedResultsController.fetchedObjects) {
        if (event.bloodSugar) {
            
            //            self.point = CGPointMake((-self.min_x + [self hourOfDay:event.timeStamp]) * self.scaleFactorX,
            //                                     (self.max_y - (CGFloat)[event.bloodSugar floatValue])* self.scaleFactorY) ; // works unexpectedly
            self.point = [self convertToPointInViewCoordinatesX:[[event hourOfDay] floatValue]
                                                              y:[event.bloodSugar floatValue]];
            
            if (lastXValue <= self.point.x) {
                // Set Color according to no of day (wandering through the hue space from red to ..., wikipedia has a good reference)
                [[UIColor colorWithHue:1.-(CGFloat)lineNumber/7.0 saturation:1.0 brightness:1.0 alpha:1.0] setStroke];
                // set linewidth according to the no of day
                CGFloat linewidth = MAX(6.*(1.0 - (CGFloat) lineNumber / 3.0), 1.0); // From linewidth 6 downwards to one in three steps
                [path setLineWidth:linewidth];
                [path stroke];
                
                // ACHTUNG: neu initialisiert, sonst klappt das nicht mit den Farben (nimmt immer nur die zuletzt vorgegebene)
                path = [UIBezierPath new];
                
                //                NSLog(@"lineNumber %d", lineNumber);
                lineNumber++;
                [path moveToPoint:self.point]; // Start a new line, due to new day
            } else {
                [path addLineToPoint:self.point];  // Continue the line, since it's still on the same day
            }
            
            lastXValue = self.point.x;
            
            //            NSLog(@"Daten: %@, %@, Point %g, %g", event.timeStamp, event.bloodSugar, self.point.x, self.point.y);
            i++;
            
            // A C H T U N G  break hier, nach n Werten
            if (i>=30) break;
        }
    }

}

#define GRID_FONT_SIZE 10.0

// Draw Grid annotation (the grid line values)

-(void)drawTextForXGrid: (NSArray *) xGridValues forYGrid: (NSArray *) yGridValues{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    UIFont *font = [UIFont systemFontOfSize:GRID_FONT_SIZE];
    
    if (xGridValues && yGridValues) {
        
        // Grid text for vertical lines (x-lines)
        for (NSNumber *xGridValue in xGridValues) {
            NSAttributedString *text = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",xGridValue] attributes:@{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : font}];
            CGRect textBounds;
            textBounds.origin = CGPointMake((-self.min_x + [xGridValue floatValue]) * self.scaleFactorX - 1.1 * [text size].width,
                                            self.bounds.size.height - 1.0*[text size].height);
            
            textBounds.size = [text size];
            [text drawInRect:textBounds];
        }
        
        // Grid text for horizontal lines (y-lines)
        for (NSNumber *yGridValue in yGridValues) {
            NSAttributedString *text = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",yGridValue] attributes:@{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : font}];
            CGRect textBounds;
            textBounds.origin = CGPointMake(self.bounds.origin.x, (self.max_y - [yGridValue floatValue]) * self.scaleFactorY);
//            textBounds.origin = CGPointMake(self.min_x, (self.max_y - [yGridValue floatValue]) * self.scaleFactorY);
            
            textBounds.size = [text size];
            [text drawInRect:textBounds];
        }
    }
}


//// Von xcode erzeugt, wird aber von uns verändert, siehe oben
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}





# pragma mark - Sachen zu Core Data aus AppDelegate

//
//// Speicher die Daten in "Core Data", wenn Änderungen an den Daten (im managedObjectContext) vorgenommen wurden
//- (void)saveContext
//{
//    NSError *error = nil;
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}
//
//#pragma mark - Core Data stack
//
//// Wohl Standard, schätze, dass hier nichts gemacht werden muss
//
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

#pragma mark - Application's Documents directory

//// Returns the URL to the application's Documents directory.
//- (NSURL *)applicationDocumentsDirectory
//{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}

//-(void) saveContext:(NSManagedObjectContext *)context {
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}
//

// Lazy getter for managedObjectContext, which is received from the UPAppDelegate
-(NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

// TODO: fetched results controller muss raus hier und in den view controller oder sonst wo hin

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

//
//#pragma mark stuff from superCard
//
//-(CGFloat)faceCardScaleFactor
//{
//    // Lazy getter
//    if (!_faceCardScaleFactor) _faceCardScaleFactor = DEFAULT_FACE_CARD_SACLE_FACTOR;
//    return _faceCardScaleFactor;
//}
//-(void) setFaceCardScaleFactor:(CGFloat)faceCardScaleFactor
//{
//    _faceCardScaleFactor = faceCardScaleFactor;
//    [self setNeedsDisplay];
//}
//
//
//-(void)drawCorners  // Das "K♥" etc. in die Ecken zeichnen
//{
//    // Mit Attributed String erzeugen, (center alignment und Font dazu)
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.alignment = NSTextAlignmentCenter;
//    
//    UIFont *cornerFont = [UIFont systemFontOfSize:self.bounds.size.width * 0.20];
//    
//    NSAttributedString *cornerText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",[self rankAsString],self.suit] attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : cornerFont }];
//    
//    // Koordinaten für den Text in der View festlegen
//    CGRect textBounds;
//    textBounds.origin = CGPointMake(CORNER_TEXT_ORIGIN_X, CORNER_TEXT_ORIGIN_Y);
//    
//    // Größe ist die des Textes selbst.
//    textBounds.size = [cornerText size];
//    
//    [cornerText drawInRect:textBounds];  // Draw it, within the bounds of the text
//    
//    // Jetzt den Text in das untere rechte Eck zeichnen. Dazu Rotation etc, und dafür den Context auf den Stack pushen, bearbeiten und wieder runter nehmen, damit die Verschiebung und Rotation nicht auf alle weiteren zu zeichnenden Element angewandt werden
//    [self pushContextAndRotateUpsideDown]; // Hier ist Verschiebung und Rotation mit drin
//    [cornerText drawInRect:textBounds];    // Den bekannten Text dort zeichnen
//    [self popContext]; // Jetzt wieder von Stack nehmen, da abgeschlossen und man hat den alten context für spätere Weiterbearbeitung
//    
//    
//}
//-(void) pushContextAndRotateUpsideDown
//{
//    CGContextRef context = UIGraphicsGetCurrentContext(); // context holten
//    CGContextSaveGState(context); // Context wird auf den Stack gepusht
//    // Jetzt kann damit alles beliebige gemacht werden, ohne den bisherigen Context zu verändern
//    
//    // Verschiebung in das rechte untere Eck
//    CGContextTranslateCTM( context, self.bounds.size.width, self.bounds.size.height);
//    
//    // Drehung in radian
//    CGContextRotateCTM(context, M_PI);
//    
//}
//-(void)popContext
//{
//    CGContextRestoreGState(UIGraphicsGetCurrentContext());
//}
//
//
//-(NSString *) rankAsString
//{
//    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"][self.rank];
//}
//
//
//// Setter machen, damit ein redraw erzwungen wird, wenn sich die Karte ändert, wird der Einfachheit halber auch gemacht, wenn sich nur ein Property ändert.
//-(void)setSuit:(NSString *)suit
//{
//    _suit = suit;
//    [self setNeedsDisplay];
//}
//
//-(void)setRank:(NSUInteger)rank
//{
//    _rank = rank;
//    [self setNeedsDisplay];
//}
//
//-(void)setFaceUp:(BOOL)faceUp
//{
//    _faceUp = faceUp;
//    [self setNeedsDisplay];
//}
//
//
//
//#pragma mark - Draw Pips
//
//#define PIP_HOFFSET_PERCENTAGE 0.165
//#define PIP_VOFFSET1_PERCENTAGE 0.090
//#define PIP_VOFFSET2_PERCENTAGE 0.175
//#define PIP_VOFFSET3_PERCENTAGE 0.270
////#define PIP_FONT_SCALE_FACTOR 0.20
//#define PIP_FONT_SCALE_FACTOR 0.15
//
//- (void)drawPips
//{
//    if ((self.rank == 1) || (self.rank == 5) || (self.rank == 9) || (self.rank == 3)) {
//        [self drawPipsWithHorizontalOffset:0
//                            verticalOffset:0
//                        mirroredVertically:NO];
//    }
//    if ((self.rank == 6) || (self.rank == 7) || (self.rank == 8)) {
//        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
//                            verticalOffset:0
//                        mirroredVertically:NO];
//    }
//    if ((self.rank == 2) || (self.rank == 3) || (self.rank == 7) || (self.rank == 8) || (self.rank == 10)) {
//        [self drawPipsWithHorizontalOffset:0
//                            verticalOffset:PIP_VOFFSET2_PERCENTAGE
//                        mirroredVertically:(self.rank != 7)];
//    }
//    if ((self.rank == 4) || (self.rank == 5) || (self.rank == 6) || (self.rank == 7) || (self.rank == 8) || (self.rank == 9) || (self.rank == 10)) {
//        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
//                            verticalOffset:PIP_VOFFSET3_PERCENTAGE
//                        mirroredVertically:YES];
//    }
//    if ((self.rank == 9) || (self.rank == 10)) {
//        [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
//                            verticalOffset:PIP_VOFFSET1_PERCENTAGE
//                        mirroredVertically:YES];
//    }
//}
//
//- (void)drawPipsWithHorizontalOffset:(CGFloat)hoffset
//                      verticalOffset:(CGFloat)voffset
//                          upsideDown:(BOOL)upsideDown
//{
//    if (upsideDown) [self pushContextAndRotateUpsideDown];
//    CGPoint middle = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
//    UIFont *pipFont = [UIFont systemFontOfSize:self.bounds.size.width * PIP_FONT_SCALE_FACTOR];
//    NSAttributedString *attributedSuit = [[NSAttributedString alloc] initWithString:self.suit attributes:@{ NSFontAttributeName : pipFont }];
//    CGSize pipSize = [attributedSuit size];
//    CGPoint pipOrigin = CGPointMake(
//                                    middle.x-pipSize.width/2.0-hoffset*self.bounds.size.width,
//                                    middle.y-pipSize.height/2.0-voffset*self.bounds.size.height
//                                    );
//    [attributedSuit drawAtPoint:pipOrigin];
//    if (hoffset) {
//        pipOrigin.x += hoffset*2.0*self.bounds.size.width;
//        [attributedSuit drawAtPoint:pipOrigin];
//    }
//    if (upsideDown) [self popContext];
//}
//
//- (void)drawPipsWithHorizontalOffset:(CGFloat)hoffset
//                      verticalOffset:(CGFloat)voffset
//                  mirroredVertically:(BOOL)mirroredVertically
//{
//    [self drawPipsWithHorizontalOffset:hoffset
//                        verticalOffset:voffset
//                            upsideDown:NO];
//    if (mirroredVertically) {
//        [self drawPipsWithHorizontalOffset:hoffset
//                            verticalOffset:voffset
//                                upsideDown:YES];
//    }
//}




@end





//   Draw Rect Anteile von superCard
//    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:CORNER_RADIUS];

//    [roundedRect addClip]; // Alles außerhalb wird abgeschnitten
//    [[UIColor whiteColor] setFill]; // Inneres wird weiß gezeichnet bzw. Farbe festgelegt
//    UIRectFill(self.bounds); // Und jetzt auch tatsächlich zeichnen
//
//    [[UIColor blackColor] setStroke];  // Schwarze Linienfarbe für Umrandung
//    [roundedRect stroke];              // und zeichnen derselben
//
//    // Bild für die jeweilige Karte laden und einbringen (Bildname wird aus rank und suit zusammengesetzt
//    if (self.faceUp) {  // Wenn Karte aufgedeckt
//        UIImage *faceImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.jpg", [self rankAsString], self.suit]];
//        if(faceImage) {
//            // Bild wird in ein CGrect eingesetzt (Abstand zu den Rändern kann hier vorgegeben werden, was wir brauchen, um das "K♥" etc. nicht zu übermalen)
//            CGRect imageRect = CGRectInset(self.bounds,
//                                           self.bounds.size.width* (1.0 - self.faceCardScaleFactor),
//                                           self.bounds.size.height * (1.0 - self.faceCardScaleFactor));
//            [faceImage drawInRect:imageRect]; // Malen des Bildes
//
//        } else {
//            // Pips sind die Karten ohne Bild und nur mit Karos etc, (davon so viele wie die Karte Punkte hat)
//            [self drawPips];
//        }
//        [self drawCorners];    // Malt den Text, z.B. , in die linke obere und rechte untere Ecke
//    } else { // Wenn Kartenrückseite sichtbar Rückseitenbild laden und gleich zeichnen
//        [[UIImage imageNamed:@"cardback.png"] drawInRect:self.bounds];
//    }

