//
//  AppDelegate.m
//  WordSmith
//
//  Created by Joseph Constan on 10/12/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "SettingsViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navController;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Popular Words Management
- (NSDictionary *)popularWords
{
    NSDictionary *ret;
    if ((ret = [[NSUserDefaults standardUserDefaults] objectForKey:@"PopularWords"])) {
        return ret;
    } else {
        return [NSDictionary dictionary];
    }
}

- (NSArray *)recentWords
{
    NSArray *ret;
    if ((ret = [[NSUserDefaults standardUserDefaults] objectForKey:@"RecentWords"])) {
        return ret;
    } else {
        return [NSArray array];
    }
}

- (void)addPopularWord:(NSString *)word {
    //Add to Popular Words:
    NSMutableDictionary *dict = [[self popularWords] mutableCopy];
    
    NSUInteger useCount = 1;
    if ([dict objectForKey:word]) {
        useCount = [[dict objectForKey:word] intValue] + 1;
    }
    [dict setObject:[NSNumber numberWithUnsignedInteger:useCount] forKey:word];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:dict] forKey:@"PopularWords"];
    
    //Add to Recent Words:
    NSMutableArray *array = [[self recentWords] mutableCopy];
    BOOL exists = NO;
    for (NSString *string in array) {
        if ([word isEqualToString:string])
            exists = YES;
    }
    if (!exists) [array insertObject:word atIndex:0];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:array] forKey:@"RecentWords"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    
    LOGMETHOD;
    NSLog(@"error: %@", error);
    [banner removeFromSuperview];
    banner.delegate = nil;
}

#pragma mark - App Lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    navController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateInitialViewController];
    self.window.rootViewController = navController;
        
    return YES;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
