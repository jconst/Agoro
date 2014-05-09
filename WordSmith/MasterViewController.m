//
//  MasterViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 10/12/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "MasterViewController.h"
#import "SettingsViewController.h"
#import "AIPlayer.h"
#import "TileLabel.h"
#import "GameCenterManager.h"

@implementation MasterViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIView *)sender {
    
    UIViewController *dvc = [segue destinationViewController];
    
    if ([dvc isKindOfClass:[SettingsViewController class]]) {
        SettingsViewController *svc = (SettingsViewController *)dvc;
        svc.mvc = self;
    } else if (sender.tag > 0) {
        GCM.gType = (GameType)sender.tag;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GameCenterManager *GCManager = [GameCenterManager sharedInstance];
   // if ([GameCenterManager isGameCenterAvailable]) {
		GCManager.delegate = self;
		[GCManager authenticateLocalUser];
	//}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end