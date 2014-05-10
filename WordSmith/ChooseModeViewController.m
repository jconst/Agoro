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

@implementation ChooseModeViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {

    GCM.delegate = [segue destinationViewController];
    
    if (sender.tag == 1) {
        [GCM setupSinglePlayerGame];
    } else {
        if (![GCM isConnectedToInternet]) {
            GCM.delegate = nil;
            [APPDELEGATE showAlertWithTitle:@"No Internet Connection"
                                    message:@"An internet connection is required to play multiplayer games."];
            //[[[segue sourceViewController] navigationController] popToRootViewControllerAnimated:YES];
        }
        [GCM findMatchWithMinPlayers:2 maxPlayers:4 invite:nil playersToInvite:nil viewController:self delegate:[segue destinationViewController]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
