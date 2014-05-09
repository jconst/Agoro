//
//  TournamentOverViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 9/12/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import "TournamentOverViewController.h"
#import "GameCenterManager.h"
#import "AppDelegate.h"
#import "MasterViewController.h"

@implementation TournamentOverViewController

@synthesize winScoreLabel;

- (id)initWithScores:(NSArray *)allScores {
    
    self = [super initWithNibName:@"TournamentOverViewController" bundle:nil];
    if (self) {

        // Calculate scores:
        totalScores = [[NSMutableArray alloc] initWithCapacity:4];  //4 players max
        ourScores = [[NSMutableArray alloc] initWithCapacity:3];    //3 rounds
        ourTotal = 0;
        NSLog(@"allScores: %@", allScores);
        NSLog(@"allScores obj 1: %@", [allScores objectAtIndex:0]);
        for (int i = 0; i < [GCM numberOfPlayers]; i++) {
            [totalScores addObject:[NSNumber numberWithInt:0]];
        }
        for (NSDictionary *scoresForRound in allScores) {
            
            NSString *ourID = [[GKLocalPlayer localPlayer] playerID];
            [ourScores addObject:[scoresForRound objectForKey:ourID]];
            
            for (int i = 0; i < [GCM numberOfPlayers]; i++) {
                NSString *pid = [[GCM playerOrder] objectAtIndex:i];
                NSInteger subtotal = [[totalScores objectAtIndex:i] integerValue];
                subtotal += [[scoresForRound objectForKey:pid] integerValue];
                
                [totalScores replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:subtotal]];
            }
        }
        for (NSNumber *score in ourScores) {
            ourTotal += [score integerValue];
        }
        
        didWin = YES;
        for (NSNumber *score in totalScores) {
            if (ourTotal < [score integerValue]) {
                didWin = NO;
            }
        }
    }
    return self;
}



- (IBAction)returnPressed {    
    [APPDELEGATE.navController popToRootViewControllerAnimated:NO];
    
    [self.presentingViewController.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)FBButtonPressed {
    NSString *playerName = @"I";
    if (![GCM isConnectedToInternet]) {
        [APPDELEGATE showAlertWithTitle:@"Can't post to Facebook" message:@"You aren't connected to the internet"];
    } else if ([GCM isGameCenterAvailable]) {
        playerName = [[GKLocalPlayer localPlayer] alias];
    }
    [APPDELEGATE postToFacebookWithMessage:
     [NSString stringWithFormat:@"%@ scored %ld points in Tournament Mode on Agoro Word Game! Can you beat it?",
      playerName, (long)ourTotal]];
}

- (void)makeDetailsHidden:(BOOL)shouldHide {
    for (UIView *subview in self.view.subviews) {
        if (subview.tag > 0 && subview.tag < 100) {
            subview.hidden = shouldHide;
        } else if (subview.tag >= 100) {
            subview.hidden = !shouldHide;
        }
    }
}

- (IBAction)pressedViewDetails:(id)sender {
    [self displayScores:ourScores withTotal:ourTotal];
}

- (void)displayWinWithScore:(NSInteger)score {
    [self makeDetailsHidden:YES];
    
    winScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)score];
}

- (void)displayScores:(NSArray *)scoreArray withTotal:(NSInteger)total {
    
    [self makeDetailsHidden:NO];
    
    //Display Scores:
    //  I gave the 4 labels that display player aliases/scores tags of 10-13, which
    //  correspond to the round whose score should be displayed. Then I loop through each
    //  and load them all up with the corresponding text.
    for (int i = 0; i < 3; i++) {
        UILabel *scoreLabel = (UILabel *)[self.view viewWithTag:i+10];
        
        scoreLabel.text = [(NSNumber *)[scoreArray objectAtIndex:i] stringValue];
        
        //scoreLabel.font = [UIFont fontWithName:@"BelloPro" size:20.0];
    }
    UILabel *totalScoreLabel = (UILabel *)[self.view viewWithTag:13];
    
    totalScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)total];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        
    if (didWin) {
        [self displayWinWithScore:ourTotal];
    } else {
        [self displayScores:ourScores withTotal:ourTotal];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
