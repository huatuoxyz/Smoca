//
//  SmocaStatisticsViewController.m
//  Smoca
//
//  Created by Dongri Jin on 12/05/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SmocaStatisticsViewController.h"
#import "UIButton+BGColor.h"
#import "UIColor+DRAdditions.h"
#import "SmocaAppDelegate.h"
#import "DRScreenStatus.h"

@interface SmocaStatisticsViewController ()

@end

@implementation SmocaStatisticsViewController

#define BAR_POSITION @"POSITION"
#define BAR_HEIGHT @"HEIGHT"
#define COLOR @"COLOR"
#define CATEGORY @"CATEGORY"

#define AXIS_START_X 0
#define AXIS_END_X 13

#define AXIS_START_Y 0

@synthesize data;
@synthesize graph;
@synthesize hostingView;

@synthesize managedObjectContext;
@synthesize dayFetchedResultsController;
@synthesize monthFetchedResultsController;
@synthesize yearFetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Statistics", @"Statistics");
        self.tabBarItem.image = [UIImage imageNamed:@"graph_bar"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    SmocaAppDelegate *appDelegate = (SmocaAppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;

    
    [self.view setBackgroundColor:[UIColor_DRAdditions hexToUIColor:@"1A1A1A" alpha:1]];
    
    [day_button setBackgroundColorString:@"3C3D3F" forState:UIControlStateNormal];
    [day_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [month_button setBackgroundColorString:@"3C3D3F" forState:UIControlStateNormal];
    [month_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [year_button setBackgroundColorString:@"3C3D3F" forState:UIControlStateNormal];
    [year_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self setDayFetchedResultsController];
    
    [self loadStatisticsView:0];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}


- (void) loadStatisticsView:(NSInteger)i{
    
    self.data = [NSMutableArray array];
    
    NSInteger startX = 0, endX = 0;
    if (i==0) {
        
        NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
        [dayFormat setDateFormat:@"dd"];
        NSInteger day = [[dayFormat stringFromDate:[NSDate date]] intValue];
        [dayFormat release];
        //day = 1;
        if (day<10) {
            day=10;
        }
        startX = day-9;
        endX   = day;
        for (int index = day-9; index <= day; index++) {
            for (NSManagedObject *obj in [self.dayFetchedResultsController fetchedObjects]) {
                if ([[[[obj valueForKey:@"day"] componentsSeparatedByString:@"-"] lastObject] intValue] == index) {
                    double position = index-1; //Bars will be 10 pts away from each other
                    double height = [[obj valueForKey:@"dayCount"] intValue];
                    NSDictionary *bar = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithDouble:position],BAR_POSITION,
                                         [NSNumber numberWithDouble:height],BAR_HEIGHT,
                                         [[obj valueForKey:@"dayCount"] stringValue],CATEGORY,
                                         nil];
                    [self.data addObject:bar];
                }
            }
        }
    }
    if (i==1) {
        startX = 1;
        endX   = 12;
        for (int index = 1; index <= 12; index++) {
            for (NSManagedObject *obj in [self.monthFetchedResultsController fetchedObjects]) {
                if ([[[[obj valueForKey:@"month"] componentsSeparatedByString:@"-"] lastObject] intValue] == index) {
                    double position = index-1; //Bars will be 10 pts away from each other
                    double height = [[obj valueForKey:@"monthCount"] intValue];
                    NSDictionary *bar = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithDouble:position],BAR_POSITION,
                                         [NSNumber numberWithDouble:height],BAR_HEIGHT,
                                         [[obj valueForKey:@"monthCount"] stringValue],CATEGORY,
                                         nil];
                    [self.data addObject:bar];
                }
            }
        }
    }
    if (i==2) {
        
        NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
        [yearFormat setDateFormat:@"yyyy"];
        NSInteger year = [[yearFormat stringFromDate:[NSDate date]] intValue];
        [yearFormat release];
        //day = 1;
        startX = year-3;
        endX   = year;
        
        for (int index = startX; index <= endX; index++) {
            for (NSManagedObject *obj in [self.monthFetchedResultsController fetchedObjects]) {
                if ([[obj valueForKey:@"year"] intValue] == index) {
                    double position = index-1; //Bars will be 10 pts away from each other
                    double height = [[obj valueForKey:@"yearCount"] intValue];
                    NSDictionary *bar = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithDouble:position],BAR_POSITION,
                                         [NSNumber numberWithDouble:height],BAR_HEIGHT,
                                         [[obj valueForKey:@"yearCount"] stringValue],CATEGORY,
                                         nil];
                    [self.data addObject:bar];
                }
            }
        }
    }
    
    [self generateBarPlot:i startX:startX endX:endX];
}


// グラフに使用するデータの数を返すように実装します。
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ( [plot.identifier isEqual:@"chocoplot"] )
        return [self.data count];
    return 0;
}

//棒の設定
-(NSNumber *)numberForPlot:(CPTPlot *)plot 
                     field:(NSUInteger)fieldEnum 
               recordIndex:(NSUInteger)index 
{
    if ( [plot.identifier isEqual:@"chocoplot"] )
    {
        NSDictionary *bar = [self.data objectAtIndex:index];
        
        if(fieldEnum == CPTBarPlotFieldBarLocation)
            return [bar valueForKey:BAR_POSITION];
        else if(fieldEnum ==CPTBarPlotFieldBarTip)
            return [bar valueForKey:BAR_HEIGHT];
    }
    return [NSNumber numberWithFloat:0];
}

//棒のラベル設定
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if ( [plot.identifier isEqual: @"chocoplot"] )
    {
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.fontName = @"Helvetica";
        textStyle.fontSize = 11.0f;
        textStyle.color = [CPTColor grayColor];
        
        NSDictionary *bar = [self.data objectAtIndex:index];
        CPTTextLayer *label = [[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%@", [bar valueForKey:@"CATEGORY"]]] autorelease];
        label.textStyle =textStyle;
        
        return label;
    }
    
    CPTTextLayer *defaultLabel = [[[CPTTextLayer alloc] initWithText:[NSString stringWithString:@"Label"]] autorelease];
    return defaultLabel;
    
}

//色の設定
-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot
                  recordIndex:(NSUInteger)index
{
    if ( [barPlot.identifier isEqual:@"chocoplot"] )
    {
        //NSDictionary *bar = [self.data objectAtIndex:index];
        CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor whiteColor]
                                                            endingColor:[CPTColor blueColor]
                                                      beginningPosition:0.0 endingPosition:0.3 ];
        [gradient setGradientType:CPTGradientTypeAxial];
        [gradient setAngle:320.0]; 
        
        CPTFill *fill = [CPTFill fillWithGradient:gradient];
        
        return fill;
        
    }
    return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    
}


/*
-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    if (coordinate == CPTCoordinateY) {
        newRange = ((CPTXYPlotSpace*)space).yRange;
    }
    return newRange;
}



-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)displacement {
    return CGPointMake(displacement.x, 0);
}
*/


- (void)generateBarPlot:(NSInteger)i startX:(NSInteger)aStartX endX:(NSInteger)aEndX
{

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];

    CGFloat height = 480.0f;
    if ([DRScreenStatus is4inch]) {
        height = 568.0f;
    }
    
    //Create host view
    self.hostingView = [[CPTGraphHostingView alloc] 
                        initWithFrame:CGRectMake(0, 60, 320, height-49-20-60)];
    [self.view addSubview:self.hostingView];
    //Create graph and set it as host view's graph
    self.graph = [[CPTXYGraph alloc] initWithFrame:self.hostingView.bounds];
    [self.hostingView setHostedGraph:self.graph];
    
    [self.hostingView release];
    [self.graph release];
    
    //set graph padding and theme
    self.graph.plotAreaFrame.paddingTop = 40.0f;
    self.graph.plotAreaFrame.paddingRight = 40.0f;
    self.graph.plotAreaFrame.paddingBottom = 40.0f;
    self.graph.plotAreaFrame.paddingLeft = 40.0f;
    [self.graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    NSInteger startX=0, endX=0, startY=0, endY=0;
    float majorIntervalLength = 0.0f;
    if (i==0) {
        startX = aStartX-1;
        endX   = aEndX+1;
        endY = 50;
        majorIntervalLength=10.0f;
    }
    if (i==1) {
        startX = aStartX-1;
        endX   = aEndX+1;
        endY = 30*30;
        majorIntervalLength=10.0f*30;
    }
    if (i==2) {
        startX = aStartX-1;
        endX   = aEndX+1;
        endY = 30*30*12;
        majorIntervalLength=10.0f*30*12;
    }
    
    //set axes ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:
                        CPTDecimalFromFloat(startX)
                                                    length:CPTDecimalFromFloat((endX - startX))];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:
                        CPTDecimalFromFloat(startY)
                                                    length:CPTDecimalFromFloat((endY - startY))];
    
    //plotSpace.allowsUserInteraction = YES;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    //set axes' title, labels and their text styles
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = 11;
    textStyle.color = [CPTColor grayColor];
    //axisSet.xAxis.title = @"CHOCOLATE";
    //axisSet.yAxis.title = @"AWESOMENESS";
    axisSet.xAxis.titleTextStyle = textStyle;
    axisSet.yAxis.titleTextStyle = textStyle;
    axisSet.xAxis.titleOffset = 0.0f;
    axisSet.yAxis.titleOffset = 0.0f;
    
    axisSet.xAxis.labelTextStyle = textStyle;
    axisSet.xAxis.labelOffset = 3.0f;
    axisSet.yAxis.labelTextStyle = textStyle;
    axisSet.yAxis.labelOffset = 3.0f;
    
    //set axes' line styles and interval ticks
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor grayColor];
    lineStyle.lineWidth = 1.0f;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(1.0f);
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromFloat(majorIntervalLength);
    axisSet.xAxis.majorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 5.0f;
    axisSet.xAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTicksPerInterval = 1;
    axisSet.yAxis.minorTicksPerInterval = 1;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.yAxis.minorTickLength = 5.0f;
    
    // labelFormatから小数点以下を削除
    axisSet.xAxis.labelFormatter = formatter;
    axisSet.yAxis.labelFormatter = formatter;
    
    [formatter release];
    
    //横グリッド線を引く
    axisSet.yAxis.majorGridLineStyle = lineStyle;
    
    //x,yは0から始める（刻み）
    axisSet.xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
    /*
    axisSet.yAxis.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0)
                                                                length:CPTDecimalFromInteger(50)];
    axisSet.yAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0)
                                                                length:CPTDecimalFromInteger(100)];
    
    axisSet.xAxis.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0.5)
                                                                length:CPTDecimalFromInteger(50)];
    axisSet.xAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0.5)
                                                                length:CPTDecimalFromInteger(100)];
    
    */
    
    // Create bar plot and add it to the graph
    CPTBarPlot *plot = [[CPTBarPlot alloc] init] ;
    plot.dataSource = self;
    plot.delegate = self;
    plot.barWidth = [[NSDecimalNumber decimalNumberWithString:@"0.5"]
                     decimalValue];
    plot.barOffset = [[NSDecimalNumber decimalNumberWithString:@"1.0"]
                      decimalValue];
    plot.barCornerRadius = 0.0;
    
    // Remove bar outlines
    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor = [CPTColor grayColor];
    
    plot.lineStyle = borderLineStyle;
    // Identifiers are handy if you want multiple plots in one graph
    plot.identifier = @"chocoplot";
    [self.graph addPlot:plot];
    [plot release];
}

-(IBAction)dayAction:(id)sender{
    [self setDayFetchedResultsController];
    [self loadStatisticsView:0];
}

-(IBAction)monthAction:(id)sender{
    [self setMonthFetchedResultsController];
    [self loadStatisticsView:1];
}

-(IBAction)yearAction:(id)sender{
    [self setYearFetchedResultsController];
    [self loadStatisticsView:2];
}


#pragma mark - CoreData
- (void)setDayFetchedResultsController {
    
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
	[dayFormat setDateFormat:@"yyyy-MM"];
    NSString *month = [dayFormat stringFromDate:[NSDate date]];
    [dayFormat release];
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // expression 集計の対象を設定します。
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"time"];
    // 集計関数(count)の指定
    NSExpression *expression = [NSExpression expressionForFunction:@"count:"
                              arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    // expresssion description 集計式の対象
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"dayCount"];//集計式の名
    [expressionDescription setExpression:expression];//集計関数
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];//結果の種類
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects: expressionDescription, @"day", Nil]];
    [expressionDescription release];
    
    //where
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"month=%@", month];
	[fetchRequest setPredicate:pred];
    
    //group by
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:@"day"]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    
    // Edit the sort key as appropriate.
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    [aFetchedResultsController performFetch:&error];
    self.dayFetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
}

- (void)setMonthFetchedResultsController {
    
    NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
	[yearFormat setDateFormat:@"yyyy"];
    NSString *year = [yearFormat stringFromDate:[NSDate date]];
    [yearFormat release];
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // expression 集計の対象を設定します。
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"time"];
    // 集計関数(count)の指定
    NSExpression *expression = [NSExpression expressionForFunction:@"count:"
                                                         arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    // expresssion description 集計式の対象
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"monthCount"];//集計式の名
    [expressionDescription setExpression:expression];//集計関数
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];//結果の種類
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects: expressionDescription, @"month", Nil]];
    [expressionDescription release];
    //where
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"year=%@", year];
	[fetchRequest setPredicate:pred];
    
    //group by
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:@"month"]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"month" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    [aFetchedResultsController performFetch:&error];
    self.monthFetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
}

- (void)setYearFetchedResultsController {
    
    //NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
	//[yearFormat setDateFormat:@"yyyy"];
    //NSString *year = [yearFormat stringFromDate:[NSDate date]];
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // expression 集計の対象を設定します。
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"time"];
    // 集計関数(count)の指定
    NSExpression *expression = [NSExpression expressionForFunction:@"count:"
                                                         arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    // expresssion description 集計式の対象
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"yearCount"];//集計式の名
    [expressionDescription setExpression:expression];//集計関数
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];//結果の種類
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects: expressionDescription, @"year", Nil]];
    [expressionDescription release];
    
    //where
    //NSPredicate* pred = [NSPredicate predicateWithFormat:@"year=%@", year];
	//[fetchRequest setPredicate:pred];
    
    //group by
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:@"year"]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    [aFetchedResultsController performFetch:&error];
    self.monthFetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
}



@end
