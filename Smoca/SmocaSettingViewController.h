//
//  SmocaSettingViewController.h
//  Smoca
//
//  Created by Dongri Jin on 12/05/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmocaAppDelegate.h"

@interface SmocaSettingViewController : UIViewController<FBSessionDelegate>{
    IBOutlet UIButton *twitter_button;
    IBOutlet UIButton *facebook_button;
    IBOutlet UIView *social_view;
}

-(IBAction)twitterAction:(id)sender;
-(IBAction)facebookAction:(id)sender;

-(void)setTwitterLabel;

@end
