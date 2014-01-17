//
//  NextRoundViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 7/18/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import "NextRoundViewController.h"
#import "GameCenterManager.h"
#import "TournamentManager.h"

@implementation NextRoundViewController

@synthesize bgView, playButton;

//TODO: Handle matchEnded calls

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"nrvc prepare for segue");
    GCM.delegate = [segue destinationViewController];
    if (GCM.gameState == kGameStateWaitingToPressPlay)
        GCM.gameState = kGameStateWaitingForStart;
    [GCM sendGameBegin];
    [GCM tryStartGame];
}

- (IBAction)playButtonPressed:(id)sender {
    
    switch (GCM.tournamentManager.currentGame) {
        case l2w:
            [self performSegueWithIdentifier:@"LoadL2W" sender:nil];
            break;
        case ws:
            [self performSegueWithIdentifier:@"LoadWS" sender:nil];
            break;
        case rtw:
            [self performSegueWithIdentifier:@"LoadRTW" sender:nil];
            break;
        default:
            NSLog(@"Error: unrecognized tournamentManager.currentGame: %d", GCM.tournamentManager.currentGame);
            break;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    self.navigationItem.hidesBackButton = YES;
    
    NSString *title = [NSString stringWithFormat:@"Round %d", GCM.gType];
    self.navigationItem.title = title;

    NSString *imgName = [NSString stringWithFormat:@"Round%d.png", GCM.gType];
    bgView.image = [UIImage imageNamed:imgName];
    bgView.frame = self.view.bounds;
    
    imgName = [NSString stringWithFormat:@"Round%dBtn.png", GCM.gType];
    playButton.imageView.image = [UIImage imageNamed:imgName];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
