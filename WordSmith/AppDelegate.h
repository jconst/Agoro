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

@interface AppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate, FBDialogDelegate, ADBannerViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) Facebook *facebook;

- (NSDictionary *)popularWords;
- (NSArray *)recentWords;
- (void)addPopularWord:(NSString *)word;

- (void)logInToFacebook;
- (void)postToFacebookWithMessage:(NSString *)message;

- (void)showAdInView:(UIView *)theView;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
@end
