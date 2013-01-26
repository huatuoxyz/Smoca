//
//  SmocaAppDelegate.h
//  Smoca
//
//  Created by Dongri Jin on 12/05/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "OAuthViewController.h"

@class SmocaSettingViewController;

@interface SmocaAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>{
    Facebook *facebook;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;


@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) OAuthViewController *oauthViewController;
@property (nonatomic, retain) SmocaSettingViewController *viewController3;

//Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
//Core Data





@end
