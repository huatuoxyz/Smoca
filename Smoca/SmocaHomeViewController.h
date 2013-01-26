//
//  SmocaHomeViewController.h
//  Smoca
//
//  Created by Dongri Jin on 12/05/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SmocaAppDelegate.h"

@interface SmocaHomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, FBRequestDelegate>{
    IBOutlet UIButton *smoca_button;
    IBOutlet UIView *today_view;
    IBOutlet UITableView *today_tableview;
    IBOutlet UIView *tweetView;
    IBOutlet UIButton *tweet_button;
    IBOutlet UIButton *cancel_button;
    IBOutlet UITextView *tweet_textview;
    
    IBOutlet UISwitch *twitter_switch;
    IBOutlet UISwitch *facebook_switch;
    
    IBOutlet UILabel *twitter_result;
    IBOutlet UILabel *facebook_result;
}

//CoreData
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

-(IBAction) smocaAction;

-(IBAction)tweetAction:(id)sender;
-(IBAction)cancelAction:(id)sender;

-(IBAction)twitterSwitchAction:(id)sender;
-(IBAction)facebookSwitchAction:(id)sender;

@end
