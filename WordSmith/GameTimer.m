//
//  GameTimer.m
//  WordSmith
//
//  Created by Joseph Constan on 7/19/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import "GameTimer.h"
#import "SettingsViewController.h"
#import "GameCenterManager.h"

@implementation GameTimer

@synthesize countdownState, label, delegate;

+ (GameTimer *) gameTimerWithDelegate:(UIViewController <GameTimerDelegate> *)newDelegate {
    GameTimer *ret = [[GameTimer alloc] initWithDelegate:newDelegate];
    
    return ret;
}

- (id) initWithDelegate:(UIViewController <GameTimerDelegate> *)newDelegate {
    if ((self = [super init])) {
        delegate = newDelegate;
        countdownState = 3;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        gameDuration = 120;
#ifdef TestingTournament
        gameDuration = 10;
#endif
    }
    return self;
}

- (void) togglePause {
    paused = !paused;
}

- (void) timerFired:(NSTimer *)theTimer {
    if (paused)
        return;
    
    if (countdownState > 0) {
        if (!label)
            label = delegate.countdownLabel;
        label.text = [NSString stringWithFormat:@"%ld", (long)countdownState];
    } else if (countdownState == 0) {
        label.text = @"Go!";
        [delegate gameStarted];
    } else {
        delegate.title = [NSString stringWithFormat:@"Time Remaining: %u", gameDuration+countdownState];
        if (countdownState == -1)
            label.hidden = YES;        
    }
    if (gameDuration+countdownState == 0) {
        [delegate endGame];
    }
    countdownState--;
}

- (void) end {
    [timer invalidate];
}

@end
