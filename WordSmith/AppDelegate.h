//
//  AppDelegate.h
//  WordSmith
//
//  Created by Joseph Constan on 10/12/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class MasterViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ADBannerViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

- (NSDictionary *)popularWords;
- (NSArray *)recentWords;
- (void)addPopularWord:(NSString *)word;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
@end
