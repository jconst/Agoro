//
//  ChooseModeViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 11/9/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "ChooseModeViewController.h"
#import "AppDelegate.h"
#import "GameCenterManager.h"
#import <iAd/iAd.h>

@implementation ChooseModeViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {

    GCM.delegate = [segue destinationViewController];
    
    if (sender.tag == 1) {
        [GCM setupSinglePlayerGame];
    } else {
        if (![GCM isConnectedToInternet]) {
            GCM.delegate = nil;
            [APPDELEGATE showAlertWithTitle:@"No Internet Connection"
                                    message:@"An internet connection is required to play multiplayer/tournament games."];
            //[[[segue sourceViewController] navigationController] popToRootViewControllerAnimated:YES];
        }
        else if (sender.tag == 3) {
            //tournament game
            GCM.inTournament = YES;
            GCM.gType = l2w;
        }
        [GCM findMatchWithMinPlayers:2 maxPlayers:4 invite:nil playersToInvite:nil viewController:self delegate:[segue destinationViewController]];
    }
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
#ifdef AdsEnabled
    
    ADBannerView *adView = [[ADBannerView alloc] init];
    adView.delegate = APPDELEGATE;
    adView.frame = CGRectMake(0, (self.view.frame.origin.y + self.view.frame.size.height) - adView.frame.size.height,
                              adView.frame.size.width, adView.frame.size.height);
    [self.view addSubview:adView];
    
#endif
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
