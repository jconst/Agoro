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
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
