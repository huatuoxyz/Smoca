//
//  OAuthViewController.m
//  Tweetese
//
//  Created by Dongri Jin on 11/07/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OAuthViewController.h"

#import "ASIHTTPRequest.h"
#import "OAuthCore.h"
#import "DRScreenStatus.h"

#define CONSUMER_KEY    @"****"
#define CONSUMER_SECRET @"****"


@implementation OAuthViewController

@synthesize flowType;
@synthesize oauth_token;
@synthesize oauth_token_secret;
@synthesize user_id;
@synthesize screen_name;


- (void)showAlert:(NSString *) alertStr{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	// KVC: define a set of keys that are known but that we are not interested in. Just ignore them.
	if ([[NSSet setWithObjects:
		  @"oauth_callback_confirmed",
		  nil] containsObject:key]) {
		
        // ... but if we got a new key that is not known, log it.
	} else {
		NSLog(@"Got unknown key from provider response. Key: \"%@\", value: \"%@\"", key, value);
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat height = 480.0f;
    if ([DRScreenStatus is4inch]) {
        height = 568.0f;
    }
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, height-20-44)];
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView release];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];
	self.navigationItem.leftBarButtonItem = btnCancel;
    
    NSString *callbackUrl;
    
    if (flowType == TwitterLoginPinFlow) {
        textField = [[UITextField alloc] initWithFrame:
                                  CGRectMake(10,19,150,26)];
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.font = [UIFont systemFontOfSize:17];
        textField.placeholder = @"PIN";
        
        self.navigationItem.titleView = textField;
        
        UIBarButtonItem *loginButton = [[[UIBarButtonItem alloc] 
                                         initWithTitle:NSLocalizedString(@"Login",nil)
                                         style:UIBarButtonItemStyleBordered 
                                         target:self
                                         action:@selector(login)] autorelease];
        self.navigationItem.rightBarButtonItem = loginButton;
        callbackUrl = nil;
    }else{
        self.navigationItem.title = @"Twitter OAuth";
        callbackUrl = @"smoca://handleOAuthLogin";
    }
    
    [self synchronousRequestTwitterTokenWithCallbackUrl:callbackUrl];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [webView release];
    [textField release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) synchronousRequestTwitterTokenWithCallbackUrl:(NSString *)callbackUrl {
    
    NSString *url = @"https://api.twitter.com/oauth/request_token";
	
	self.oauth_token = @"";
	self.oauth_token_secret = @"";
	
    NSString *_callbackUrl = callbackUrl;
    if (!callbackUrl) {
        _callbackUrl = @"oob";
    }
    
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	request.requestMethod = @"POST";
    
    [request appendPostData:[[NSString stringWithFormat:@"oauth_callback=%@", _callbackUrl] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *oauth_header = OAuthorizationHeader([request url],
                                            [request requestMethod],
                                            [request postBody],
                                            CONSUMER_KEY,
                                            CONSUMER_SECRET,
                                            @"",
                                            @"");

	[request addRequestHeader:@"Authorization" value:oauth_header];
	[request startSynchronous];
	
	if ([request error]) {
        [self showAlert:[request responseString]];
	} else {
		NSArray *responseBodyComponents = [[request responseString] componentsSeparatedByString:@"&"];
		for (NSString *component in responseBodyComponents) {
			NSArray *subComponents = [component componentsSeparatedByString:@"="];
			[self setValue:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];			
		}
	}
    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", [self valueForKey:@"oauth_token"]]];
    [webView loadRequest:[NSURLRequest requestWithURL:myURL]];
}


- (void) synchronousAuthorizeTwitterTokenWithVerifier:(NSString *)oauth_verifier {
	
	NSString *url = @"https://api.twitter.com/oauth/access_token";
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	request.requestMethod = @"POST";
	
    [request appendPostData:[[NSString stringWithFormat:@"oauth_token=%@&oauth_verifier=%@&oauth_consumer_key=%@", oauth_token,oauth_verifier,CONSUMER_KEY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *oauth_header = OAuthorizationHeader([request url],
                                                  [request requestMethod],
                                                  [request postBody],
                                                  CONSUMER_KEY,
                                                  CONSUMER_SECRET,
                                                  oauth_token,
                                                  @"");
    
    [request addRequestHeader:@"Authorization" value:oauth_header];
	[request startSynchronous];
	
	if ([request error]) {
        [self showAlert:request.responseString];
	} else {
		NSArray *responseBodyComponents = [[request responseString] componentsSeparatedByString:@"&"];
		for (NSString *component in responseBodyComponents) {
			NSArray *subComponents = [component componentsSeparatedByString:@"="];
			[self setValue:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];			
		}
		
        [[NSUserDefaults standardUserDefaults] setObject:oauth_token forKey:@"oauth_token"];
        [[NSUserDefaults standardUserDefaults] setObject:oauth_token_secret forKey:@"oauth_token_secret"];
        
        [[NSUserDefaults standardUserDefaults] setObject:CONSUMER_KEY forKey:@"consumer_key"];
        [[NSUserDefaults standardUserDefaults] setObject:CONSUMER_SECRET forKey:@"consumer_secret"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[self valueForKey:@"user_id"] forKey:@"user_id"];
        [[NSUserDefaults standardUserDefaults] setObject:[self valueForKey:@"screen_name"] forKey:@"screen_name"];
        
        [self dismissModalViewControllerAnimated:YES];
        
        
        /*
        TweeteseAppDelegate *appDelegate = (TweeteseAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
        appDelegate.timelineViewController.aCount = 20;
        appDelegate.mentionsViewController.aCount = 20;
        appDelegate.messagesViewController.aCount = 20;
        
        [appDelegate.timelineViewController viewDidLoad];
        [NSThread detachNewThreadSelector:@selector(reloadInputViewsThread:) toTarget:self withObject:appDelegate.mentionsViewController];
        [NSThread detachNewThreadSelector:@selector(reloadInputViewsThread:) toTarget:self withObject:appDelegate.messagesViewController];
        */
        //[NSThread detachNewThreadSelector:@selector(loadDataFromAPI) toTarget:appDelegate.timelineViewController withObject:nil];
        //[NSThread detachNewThreadSelector:@selector(loadDataFromAPI) toTarget:appDelegate.mentionsViewController withObject:nil];
        //[NSThread detachNewThreadSelector:@selector(viewDidLoad) toTarget:appDelegate.messagesViewController withObject:nil];
        
        //[appDelegate.mentionsViewController reloadInputViews];
        //[appDelegate.messagesViewController reloadInputViews];
        
        //[NSThread detachNewThreadSelector:@selector(reloadInputViews) toTarget:appDelegate.mentionsViewController withObject:nil];
        //[NSThread detachNewThreadSelector:@selector(reloadInputViews) toTarget:appDelegate.messagesViewController withObject:nil];
        //[NSThread detachNewThreadSelector:@selector(reloadInputViewsThread:) toTarget:self withObject:appDelegate.timelineViewController];
        
        //[appDelegate.mentionsViewController performSelectorInBackground:@selector(reloadInputViews) withObject:nil];
        //[appDelegate.messagesViewController performSelectorInBackground:@selector(reloadInputViews) withObject:nil];
        //[appDelegate.timelineViewController performSelectorOnMainThread:@selector(reloadInputViews) withObject:nil waitUntilDone:NO];
        //[appDelegate.mentionsViewController performSelectorOnMainThread:@selector(reloadInputViews) withObject:nil waitUntilDone:NO];
        //[appDelegate.messagesViewController performSelectorOnMainThread:@selector(reloadInputViews) withObject:nil waitUntilDone:NO];
        
        //[appDelegate.timelineViewController viewDidLoad];
        //[appDelegate.mentionsViewController loadDataFromDB];
        //[appDelegate.messagesViewController loadDataFromDB];
	}
    
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSString *html = [aWebView stringByEvaluatingJavaScriptFromString: @"document.getElementsByTagName(\"code\")[0].innerHTML"];
    textField.text = html;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)login{
    [self synchronousAuthorizeTwitterTokenWithVerifier:textField.text];
}

- (void)close{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)reloadInputViewsThread:(UIViewController *)viewController{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [viewController reloadInputViews];
    [pool release];
}


- (void)cancelAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
