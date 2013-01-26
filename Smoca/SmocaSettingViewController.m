//
//  SmocaSettingViewController.m
//  Smoca
//
//  Created by Dongri Jin on 12/05/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SmocaSettingViewController.h"
#import "UIButton+BGColor.h"
#import "UIColor+DRAdditions.h"
#import <QuartzCore/QuartzCore.h>

@interface SmocaSettingViewController ()

@end

@implementation SmocaSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Setting", @"Setting");
        self.tabBarItem.image = [UIImage imageNamed:@"cog_01"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor_DRAdditions hexToUIColor:@"1A1A1A" alpha:1]];
        
    social_view.backgroundColor = [UIColor_DRAdditions hexToUIColor:@"424242" alpha:1];
    social_view.layer.cornerRadius   = 8.0f;
	social_view.layer.borderWidth   = 5.0f;
    social_view.layer.borderColor   = [[UIColor_DRAdditions hexToUIColor:@"696969" alpha:1] CGColor];
	social_view.layer.masksToBounds = YES;
    
    [twitter_button setBackgroundColorString:@"3C3D3F" forState:UIControlStateNormal];
    [twitter_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [facebook_button setBackgroundColorString:@"3C3D3F" forState:UIControlStateNormal];
    [facebook_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if ([(NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"] length] == 0) {
        [twitter_button setTitle:@"接続" forState:UIControlStateNormal];
    }else{
        [twitter_button setTitle:@"切断" forState:UIControlStateNormal];
    }
    
    SmocaAppDelegate *delegate = (SmocaAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![delegate.facebook isSessionValid]) {
        [facebook_button setTitle:@"接続" forState:UIControlStateNormal];
    }else {
        [facebook_button setTitle:@"切断" forState:UIControlStateNormal];
    }

}

- (void)fbDidLogin {
	SmocaAppDelegate *delegate = (SmocaAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[delegate.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[delegate.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [facebook_button setTitle:@"切断" forState:UIControlStateNormal];
}

-(void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"did not login");
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

-(IBAction)twitterAction:(id)sender{
    
    if ([(NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"] length] == 0) {
        [self displayLoginView];
    }else{
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"",                             @"consumer_key",
                             @"",                             @"consumer_secret",
                             @"",                             @"oauth_token",
                             @"",                             @"oauth_token_secret",
                             @"",                             @"user_id",
                             @"",                             @"screen_name",
                             nil];
        
        for (id key in dic) {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [twitter_button setTitle:@"接続" forState:UIControlStateNormal];
    }

}

-(IBAction)facebookAction:(id)sender{
    SmocaAppDelegate *delegate = (SmocaAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![delegate.facebook isSessionValid]) {
        //[facebook authorize:nil];
        [delegate.facebook authorize:[NSArray arrayWithObjects:@"publish_stream", @"offline_access",nil]];
    }else{
        [delegate.facebook logout];
        [facebook_button setTitle:@"接続" forState:UIControlStateNormal];
    }
}


-(void)setTwitterLabel{
    [twitter_button setTitle:@"切断" forState:UIControlStateNormal];
}

- (void)displayLoginView{
    SmocaAppDelegate *delegate = (SmocaAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.oauthViewController.flowType = TwitterLoginCallbackFlow;
    UINavigationController *naviLoginController = [[UINavigationController alloc] initWithRootViewController:delegate.oauthViewController];
    [self presentModalViewController:naviLoginController animated:YES];
    //[delegate.oauthViewController release];
    
}

@end
