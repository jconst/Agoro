//
//  GameViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 10/12/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "GameViewController.h"
#import "GameCenterManager.h"
#import "MessageDefs.h"
#import "AppDelegate.h"
#import "Lexicontext.h"
#import "PlayerScoreView.h"
#import "L2WDisplayView.h"
#import "AIPlayer.h"
#import "GameOverViewController.h"
#import "GameTimer.h"
#import "TournamentManager.h"

#define l2wDisplayFrame CGRectMake(15, 20, 300, 50)

@implementation GameViewController

@synthesize countdownLabel, prefixLabel, turn, psv, dv, turnArrow;

- (void)turnChanged {
    NSArray *pids = [[GameCenterManager sharedInstance] playerOrder];
    
    if (turn == [pids count]) {
        turn = 1;
    } else {
        turn++;
    }
    dv.turnUsed = NO;
    [UIView animateWithDuration:0.3 animations:^{
        turnArrow.frame = CGRectMake(psv.frame.origin.x - 20, psv.frame.origin.y + (turn*16), 16, 16);
    }];
    if ([[pids objectAtIndex:turn-1] isEqualToString:kCompID]) {
        [aiPlayer turnStartedWithView:dv];
    }
}

- (void)gameStarted {
    
    [UIView animateWithDuration:0.5 animations:^{
        psv.alpha = 1;
        dv.alpha = 1;
        turnArrow.alpha = 1;
        countdownLabel.alpha = 0;
    }];
    turn = 1;
    [dv becomeFirstResponder];
    [psv setNeedsDisplay];
}

#pragma mark - GameCenterManagerDelegate

- (void)matchStarted {      
    psv.alpha = 0;
    
    dv = [[L2WDisplayView alloc] initWithFrame:l2wDisplayFrame];
    dv.delegate = self;
    dv.alpha = 0;
    [self.view addSubview:dv];
    self.textReceiver = dv;
    
    turnArrow.backgroundColor = [UIColor clearColor];
    turnArrow.alpha = 0;
        
    [super matchStarted];
}

@end
