//
//  ChooseLeaderboardViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 11/9/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "GameCenterManager.h"
#import "ChooseLeaderboardViewController.h"

@implementation ChooseLeaderboardViewController

- (IBAction)buttonPressed:(id)sender {
    
    GKLeaderboardViewController *hsController = [[GKLeaderboardViewController alloc] init];
    hsController.category = LEADERBOARD([sender tag]-1);
    hsController.timeScope = GKLeaderboardTimeScopeAllTime;
    hsController.leaderboardDelegate = self;
    [self presentModalViewController:hsController animated:YES];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    
    [self dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![[GameCenterManager sharedInstance] isGameCenterAvailable]) {
        [APPDELEGATE showAlertWithTitle:@"Game Center Required"
                                message:@"You must have game center functionality to view leaderboards."];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
