//
//  SmocaHomeViewController.m
//  Smoca
//
//  Created by Dongri Jin on 12/05/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SmocaHomeViewController.h"
#import "UIButton+BGColor.h"
#import "UIColor+DRAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "SmocaAppDelegate.h"
#import "ASIFormDataRequest.h"
#import "OAuthCore.h"

@interface SmocaHomeViewController ()

@end

@implementation SmocaHomeViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Fire", @"Fire");
        self.tabBarItem.image = [UIImage imageNamed:@"fire_02"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    SmocaAppDelegate *appDelegate = (SmocaAppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self setFetchedResultsController];

    //[self.view setBackgroundColor:[UIColor_DRAdditions hexToUIColor:@"1C1F25" alpha:1]];
    [self.view setBackgroundColor:[UIColor_DRAdditions hexToUIColor:@"1A1A1A" alpha:1]];
    
    [smoca_button setBackgroundColorString:@"3C3D3F" forState:UIControlStateNormal];
    [smoca_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [today_tableview setBackgroundColor:[UIColor_DRAdditions hexToUIColor:@"1C1F25" alpha:1]];
    
    today_view.layer.cornerRadius   = 8.0f;
	today_view.layer.borderWidth   = 5.0f;
    today_view.layer.borderColor   = [[UIColor_DRAdditions hexToUIColor:@"696969" alpha:1] CGColor];
	today_view.layer.masksToBounds = YES;
    
    tweetView.hidden = YES;
    tweetView.backgroundColor = [UIColor_DRAdditions hexToUIColor:@"424242" alpha:1];
    tweetView.layer.cornerRadius   = 8.0f;
	tweetView.layer.borderWidth   = 5.0f;
    tweetView.layer.borderColor   = [[UIColor_DRAdditions hexToUIColor:@"696969" alpha:1] CGColor];
	tweetView.layer.masksToBounds = YES;

    tweet_textview.layer.cornerRadius   = 8.0f;
	tweet_textview.layer.borderWidth   = 1.0f;
    tweet_textview.layer.borderColor   = [[UIColor lightGrayColor] CGColor];
	tweet_textview.layer.masksToBounds = YES;
    
    [tweet_button setBackgroundColorString:@"3C3D3F" forState:UIControlStateNormal];
    [tweet_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [cancel_button setBackgroundColorString:@"3C3D3F" forState:UIControlStateNormal];
    [cancel_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //cell.selectionStyle = UITableViewCellSelectionStyleGray;
    //cell.backgroundColor = [UIColor blackColor];
    //cell.backgroundView.backgroundColor = [UIColor blackColor];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    //cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    //cell.textLabel.numberOfLines = 0;
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    NSArray *objects = [self.fetchedResultsController fetchedObjects];
    NSManagedObject *data = [objects objectAtIndex:indexPath.row];
    NSDate *time = [data valueForKey:@"time"];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:time];
    
    NSLog(@"newDateString %@", newDateString);
    [outputFormatter release];
    
    cell.textLabel.text = [NSString stringWithFormat:@"本日%d本目", abs([objects count]-indexPath.row)];
    cell.detailTextLabel.text=newDateString;
    
    //cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    //cell.detailTextLabel.numberOfLines = 0;
    
    //UIView *cellView = [[UIView alloc] initWithFrame:cell.bounds];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(100, 2, 250, 30)];
    cellView.backgroundColor = [UIColor_DRAdditions hexToUIColor:@"3D3E3F" alpha:1];
    cell.selectedBackgroundView=cellView;
    [cellView release];
    //cell.backgroundColor = [UIColor blackColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // For even
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor_DRAdditions hexToUIColor:@"494949" alpha:1];
    }
    // For odd
    else {
        cell.backgroundColor = [UIColor_DRAdditions hexToUIColor:@"3D3E3F" alpha:1];
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


 // Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
         NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
         [context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
         // Save the context.
         NSError *error = nil;
         if (![context save:&error]) {
             NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
             abort();
         }
         [self setFetchedResultsController];
         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
         [tableView reloadData];
     } else if (editingStyle == UITableViewCellEditingStyleInsert) {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
}



 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  
    
    return 50.0f;
}
*/

- (IBAction) smocaAction{
    //insert data
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:context];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
	[dayFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *day = [dayFormat stringFromDate:now];
    
    NSDateFormatter *monthFormat = [[NSDateFormatter alloc] init];
	[monthFormat setDateFormat:@"yyyy-MM"];
    NSString *month = [monthFormat stringFromDate:now];
    
    NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
	[yearFormat setDateFormat:@"yyyy"];
    NSString *year = [yearFormat stringFromDate:now];
    
    [newManagedObject setValue:now forKey:@"time"];
    [newManagedObject setValue:day forKey:@"day"];
    [newManagedObject setValue:month forKey:@"month"];
    [newManagedObject setValue:year forKey:@"year"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self setFetchedResultsController];
    [today_tableview reloadData];
    NSInteger count = [[self.fetchedResultsController fetchedObjects] count];
    
    int totalSecond = count * (5*60+30);
    int m = totalSecond/60;
    int s = totalSecond%60;
    NSString *tweet_text = [NSString stringWithFormat:@"喫煙ったー。\n本日%d本目, 寿命が%d分%d秒縮まった！",count, m, s];
    [tweet_textview setText:tweet_text];
    
    //[self.view bringSubviewToFront:tweetView];
    //tweetView.frame = CGRectMake(20+280/2, 65+233/2, 0, 0);
    tweetView.hidden = NO;
    
    today_view.hidden = YES;
    
    [tweet_textview becomeFirstResponder];
    
    if ([(NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"] length] == 0) {
        [twitter_switch setOn:NO];
    }else{
        [twitter_switch setOn:YES];
    }
    
    SmocaAppDelegate *delegate = (SmocaAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![delegate.facebook isSessionValid]) {
        [facebook_switch setOn:NO];
    }else {
        [facebook_switch setOn:YES];
    }

}

#pragma mark - CoreData
- (void)setFetchedResultsController {
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSDictionary *entityProperties = [[NSEntityDescription entityForName:@"History" inManagedObjectContext:self.managedObjectContext] propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"time"]]];
    
    //where
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
	[inputDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *condition = [inputDateFormatter stringFromDate:[NSDate date]];
    NSString *start = [condition stringByAppendingFormat:@" 00:00:00"];
    NSString *end = [condition stringByAppendingFormat:@" 23:59:59"];
    
    [inputDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startDate = [inputDateFormatter dateFromString:start];
    NSDate *endDate = [inputDateFormatter dateFromString:end];
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"time => %@ and time <= %@", startDate, endDate];
	[fetchRequest setPredicate:pred];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    
    // Edit the sort key as appropriate.
     
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    [aFetchedResultsController performFetch:&error];
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
}

-(IBAction)tweetAction:(id)sender{
    if (twitter_switch.isOn) {
        //Twitter
        NSString *postUrl = @"http://api.twitter.com/1/statuses/update.json";
        
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc]
                                       initWithURL:[NSURL URLWithString:postUrl]];
        [request setRequestMethod:@"POST"];
        
        [request appendPostData:[[NSString stringWithFormat:@"status=%@",tweet_textview.text] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        NSString *header = OAuthorizationHeader([request url],
                                                [request requestMethod],
                                                [request postBody],
                                                [d valueForKey:@"consumer_key"],
                                                [d valueForKey:@"consumer_secret"],
                                                [d valueForKey:@"oauth_token"],
                                                [d valueForKey:@"oauth_token_secret"]);
        
        [request addRequestHeader:@"Authorization" value:header];
        
        [request setCompletionBlock:^{
            // Use when fetching text data
            //NSString *responseString = [request responseString];
            // Use when fetching binary data
            //NSData *responseData = [request responseData];
            twitter_result.text = @"成功";
            [self postResult];
        }];
        [request setFailedBlock:^{
            //NSError *error = [request error];
            twitter_result.text = @"失敗";
        }];
        [request startAsynchronous];
    }
    
    if (facebook_switch.isOn) {
        //Facebook
        SmocaAppDelegate *delegate = (SmocaAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       tweet_textview.text, @"message",
                                       nil];
        
        [delegate.facebook requestWithMethodName:@"stream.publish"
                                       andParams:params
                                   andHttpMethod:@"POST"
                                     andDelegate:self];
    }
    

}

-(IBAction)cancelAction:(id)sender{
    tweetView.hidden = YES;
    [tweet_textview resignFirstResponder];
    today_view.hidden = NO;
    twitter_result.text = @"";
    facebook_result.text = @"";
}

-(IBAction)twitterSwitchAction:(id)sender{
    SmocaAppDelegate *appDelegate = (SmocaAppDelegate *)[UIApplication sharedApplication].delegate;
    twitter_switch = (UISwitch*)sender;
    if (twitter_switch.isOn){
        if ([(NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"] length] == 0) {
            [appDelegate.tabBarController setSelectedIndex:2];
            [twitter_switch setOn:NO];
        }
    }
}

-(IBAction)facebookSwitchAction:(id)sender{
    SmocaAppDelegate *appDelegate = (SmocaAppDelegate *)[UIApplication sharedApplication].delegate;
    facebook_switch = (UISwitch*)sender;
    if (facebook_switch.isOn){
        if (![appDelegate.facebook isSessionValid]) {
            [appDelegate.tabBarController setSelectedIndex:2];
            [facebook_switch setOn:NO];
        }
    }
}

//Facebook Delegate
- (void)request:(FBRequest*)request didLoad:(id)result {
    facebook_result.text = @"成功";
    [self postResult];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    facebook_result.text = @"失敗";
    NSLog(@"%@", error);
}

- (void)postResult{
    if ([twitter_result.text isEqualToString:@"成功"] && 
        [facebook_result.text isEqualToString:@"成功"]) {
        [NSThread sleepForTimeInterval:2];
        tweetView.hidden = YES;
        [tweet_textview resignFirstResponder];
        today_view.hidden = NO;
        twitter_result.text = @"";
        facebook_result.text = @"";
    }
}

@end
