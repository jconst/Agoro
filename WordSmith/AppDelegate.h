//
//  AppDelegate.h
//  WordSmith
//
//  Created by Joseph Constan on 10/12/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "FBConnect.h"

@class MasterViewController;

#define kFBAppID @"181955628559810"
#define kAppStoreLink @"http://itunes.apple.com/us/app/agoro-word-game/id549026849?ls=1&mt=8"
#define kAppIconLink @"http://img684.imageshack.us/img684/1453/agoroiconlarge.png"

#define ARC4RANDOM_MAX      0x100000000
#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define LOGMETHOD NSLog(@"Logged Method: %@", NSStringFromSelector(_cmd))

@interface AppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate, FBDialogDelegate, ADBannerViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) Facebook *facebook;

- (NSDictionary *)popularWords;
- (NSArray *)recentWords;
   
- (void)addPopularWord:(NSString *)word;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
- (void)logInToFacebook;
- (void)postToFacebookWithMessage:(NSString *)message;
@end
