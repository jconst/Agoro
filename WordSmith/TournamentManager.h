//
//  TournamentManager.h
//  WordSmith
//
//  Created by Joseph Constan on 5/31/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definitions.h"
#import "L2WViewController.h"
#import "WordSmithViewController.h"
#import "GuessWordViewController.h"
#import "NextRoundViewController.h"

typedef enum {
    loss = 0,
    tie,
    win
} GameResult;

@class NextRoundViewController;

@interface TournamentManager : NSObject {
    
    
    NSTimer *timer;
    GameResult results[3];
}

@property (strong, nonatomic) NextRoundViewController *nrvc;
@property (nonatomic) NSUInteger roundCounter;
@property (nonatomic) GameType currentGame;
@property (nonatomic) NSMutableArray *scores;

- (void)startTournament;
- (void)roundEndedWithResult:(GameResult)result;
- (void)advanceToNextRound;
- (void)endTournament;

@end
