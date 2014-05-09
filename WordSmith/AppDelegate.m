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
@synthesize facebook;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Popular Words Management
- (NSDictionary *)popularWords {
    
    NSDictionary *ret;
    if ((ret = [[NSUserDefaults standardUserDefaults] objectForKey:@"PopularWords"])) {
        return ret;
    } else {
        return [NSDictionary dictionary];
    }
}

- (NSArray *)recentWords {
    
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

#pragma mark - Facebook
// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}

- (void)logInToFacebook {
    if (![facebook isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"offline_access", 
                                @"publish_stream",
                                @"publish_actions",
                                nil];
        [facebook authorize:permissions];
     }
}

- (void)postToFacebookWithMessage:(NSString *)message {
    NSLog(@"Message: %@", message);
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   kFBAppID, @"app_id",
                                   kAppStoreLink, @"link",
                                   kAppIconLink, @"picture",
                                   @"Agoro Word Game", @"name",
                                   message, @"description",
                                   //message,  @"message",
                                   nil];
    
    [facebook dialog:@"stream.publish" andParams:params andDelegate:self];
}

#pragma mark - iAds

- (void)showAdInView:(UIView *)theView {
#ifdef AdsEnabled
    
    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.delegate = self;
    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierLandscape];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    
    CGRect adFrame = adView.frame;
    adFrame.origin.y = theView.frame.size.height - adView.frame.size.height;
    adView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    adView.frame = adFrame;
    [theView addSubview:adView];
    
#endif
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
    
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setInteger:10 forKey:kGameDuration];
    
    //Facebook Stuff:
    facebook = [[Facebook alloc] initWithAppId:kFBAppID andDelegate:self];

    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
            
    return YES;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
