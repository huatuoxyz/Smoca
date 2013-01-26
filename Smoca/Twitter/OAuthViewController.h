//
//  OAuthViewController.h
//  Tweetese
//
//  Created by Dongri Jin on 11/07/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TwitterLoginPinFlow,
    TwitterLoginCallbackFlow
} TwitterLoginFlowType;

@interface OAuthViewController : UIViewController <UIWebViewDelegate> {
    UIWebView *webView;
    UITextField *textField;
}

@property TwitterLoginFlowType flowType;
@property (copy) NSString *oauth_token;
@property (copy) NSString *oauth_token_secret;
@property (copy) NSString *user_id;
@property (copy) NSString *screen_name;

- (void) synchronousRequestTwitterTokenWithCallbackUrl:(NSString *)callbackUrl;
- (void) synchronousAuthorizeTwitterTokenWithVerifier:(NSString *)oauth_verifier;

@end
