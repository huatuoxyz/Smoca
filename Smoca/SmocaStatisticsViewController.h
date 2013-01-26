//
//  SmocaStatisticsViewController.h
//  Smoca
//
//  Created by Dongri Jin on 12/05/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface SmocaStatisticsViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate, NSFetchedResultsControllerDelegate>{
    IBOutlet UIButton *day_button;
    IBOutlet UIButton *month_button;
    IBOutlet UIButton *year_button;
}

@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) CPTGraphHostingView *hostingView;
@property (nonatomic, retain) CPTXYGraph *graph;

//Core Data
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *dayFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *monthFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *yearFetchedResultsController;


-(IBAction)dayAction:(id)sender;
-(IBAction)monthAction:(id)sender;
-(IBAction)yearAction:(id)sender;

@end
