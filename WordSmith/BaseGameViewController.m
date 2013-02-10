//
//  BaseGameViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 7/19/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import "BaseGameViewController.h"
#import "AIPlayer.h"
#import "GameTimer.h"
#import "GameOverViewController.h"
#import "TournamentManager.h"
#import "GameCenterManager.h"
#import "AppDelegate.h"

@implementation BaseGameViewController

@synthesize singlePlayer, gameTimer, countdownLabel, textReceiver;

- (void)gameStarted {
    // Abstract Method
}

- (void)endPressed {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Are you sure?"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Quit"
                                           otherButtonTitles:nil];
    [as showFromBarButtonItem:[self.navigationItem leftBarButtonItem] animated:YES];
}

- (void)endGame {
    
    GCM.gameState = kGameStateDone;
    [gameTimer end];
    
    GameOverViewController *govc = [[GameOverViewController alloc] initWithNibName:@"GameOverViewController" bundle:nil];
    govc.delegate = self;
    [self presentModalViewController:govc animated:YES];
    
    if (singlePlayer)
        aiPlayer.gameRunning = NO;
    else {
        /*if (GCM.ourPlayerNumber == 0 && GCM.numberOfPlayers >= 2)
            
            [GCM sendGameOver];*/
    }
}

- (void)pressedPause {
    [gameTimer togglePause];
    
    UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(pressedPlay)];
    self.navigationItem.rightBarButtonItem = pauseButton;
    
    textReceiver.userInteractionEnabled = NO;
}

- (void)pressedPlay {
    [gameTimer togglePause];
    
    UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pressedPause)];
    self.navigationItem.rightBarButtonItem = pauseButton;
    
    textReceiver.userInteractionEnabled = YES;
    [textReceiver becomeFirstResponder];
}

#pragma mark - GameCenterManagerDelegate

- (void)matchStarted {
    LOGMETHOD;
    singlePlayer = NO;
    for (NSString *playerID in [[GameCenterManager sharedInstance] playerOrder]) {
        if ([playerID isEqualToString:kCompID])
            singlePlayer = YES;
    }
    //start timer
    self.gameTimer = [GameTimer gameTimerWithDelegate:self];
    
    if (singlePlayer)
        aiPlayer = [[AIPlayer alloc] initForGame:GCM.gType];
}

- (void)matchEnded {    
    [self endGame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            //end game with game center
            if (!singlePlayer) {
                [GCM sendDisconnect];
                if (GCM.inTournament)
                    [GCM.tournamentManager endTournament];
            }
            [self endGame];            
            break;
        default:
            break;
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (singlePlayer) {
        UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pressedPause)];
        self.navigationItem.rightBarButtonItem = pauseButton;
    }
    
    UIBarButtonItem *endButton = [[UIBarButtonItem alloc] initWithTitle:@"End Game" style:UIBarButtonItemStyleBordered target:self action:@selector(endPressed)];
    self.navigationItem.leftBarButtonItem = endButton;
    self.navigationItem.hidesBackButton = YES;
}

/*- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([GameCenterManager sharedInstance].gameState == kGameStateDone) {
        NSLog(@"kGameState = Done");
        [self.navigationController popToRootViewControllerAnimated:NO];
        return;
    }
}*/

@end
