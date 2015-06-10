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
//  11. Handle rotation of the device and ensure that paning and pinching ist possible all over the view area in horizontal orientation
//  12. Set the views background color, rather than filling a rect for the very same purpose
//  13. Paning doesn't work for gridlines with a value of zero. Use two array to overcome this:
//      a) An array of CGFloats for where the gridlines are supposed to be drawn (and thus don't use the array of NSNumber elements any more
//      b) A corresponding NSArray with NSString elements to be displayed at these positions

//  Solved already:
//  3. Apply horizontal and vertical scaling seperately (see link stored in Safari) and, when this is finally implemented,
//  4. ensure that paning does no more implizit scaling (as it now does, when a border is reached). To do this, for instance, don't allow max_x to grow, when min_x has reached its limit (DEFAULT_... or MIN_MIN... in the case of the y-axis)
//  8. Rename this view to e.g. DayView and get rid of the old stuff from PlayingCardView not needed here.
//  9.Die Sachen zu managedObjectContext muessen hier raus.
//  10. Add MIN_MIN_x and MAX_MAX_X to allow panning over the 0- and 24-hour border and have a look at the data at night (use negative values in calculations and text labels according to the real hour of day? --> would mean to work with an array that stores two values, which should work)


// A C H T U N G, wenn das ganze funktionieren soll, im Storyboard opaque abwählen

#import "BloodSugarGraphView.h"
#import "Event.h"
#import "Event+Extensions.h"
#import "AppDelegate.h"

@interface BloodSugarGraphView()

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
            CGFloat distanceX = fabs(touchPosition1.x-touchPosition0.x);              // distance between two touches in x-direction
            CGFloat distanceY = fabs(touchPosition1.y-touchPosition0.y);              // distance between two touches in y-direction
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
    NSArray *xGridValues = @[@(-2016),@(-1344),@(-1176),@(-1008),@(-840),@(-672),@(-504),@(-336),@(-168),@(-144),@(-120),@(-96),@(-72),@(-48),@(-24),@(0.001),@3,@6,@9,@12,@15,@18,@21,@24,@27];
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
    
    if (self.Events) {

        
        Event *newestEvent = [self.Events objectAtIndex:0];
        
        self.point = [self convertToPointInViewCoordinatesX:[[newestEvent hourOfDay] floatValue]
                                                          y:[newestEvent.bloodSugar floatValue]];
        [path moveToPoint:self.point];
        
        // Loop over fetched data is going from newest to oldest values (otherwhise use reverseObjectEnumerator)
        for (Event *event in self.Events) {
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
    for (Event *event in self.Events) {
        if (event.bloodSugar) {
            
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

@end

