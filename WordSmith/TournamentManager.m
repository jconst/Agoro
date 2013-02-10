//
//  TournamentManager.m
//  WordSmith
//
//  Created by Joseph Constan on 5/31/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import "TournamentManager.h"
#import "TournamentOverViewController.h"
#import "AppDelegate.h"
#import "GameCenterManager.h"

@implementation TournamentManager

@synthesize currentGame, roundCounter, nrvc, scores;

- (void)startTournament {
    LOGMETHOD;
    scores = [[NSMutableArray alloc] initWithCapacity:3];
    roundCounter = 1;
    currentGame = l2w;
    nrvc = (NextRoundViewController *)GCM.delegate; //This cast MIGHT have some problems in the future
    [GCM setupMultiplayerGame];
}

- (void)roundEndedWithResult:(GameResult)result {
    results[roundCounter-1] = result;
    [scores addObject:[[GCM scores] copy]];
    NSLog(@"GCM scores: %@", [GCM scores]);
    [self advanceToNextRound];
}

- (void)advanceToNextRound {
    roundCounter++;
    if (roundCounter > 3) {
        [self endTournament];
        return;
    }
    
    currentGame++;
    if (currentGame > 3)
        currentGame = l2w;

    GCM.gType = currentGame;
    GCM.gameState = kGameStateWaitingToPressPlay;
    [GCM resetScores];
    UIViewController *currentGameView = ((UIViewController *)GCM.delegate);
        
    nrvc = [currentGameView.storyboard instantiateViewControllerWithIdentifier:@"NextRoundView"];
    [currentGameView.navigationController pushViewController:nrvc animated:YES];
    
    [currentGameView dismissModalViewControllerAnimated:YES];
}

- (void)endTournament {
    LOGMETHOD;
    GCM.inTournament = NO;
    if (roundCounter > 3) { //tournament has ended normally; otherwise, one player disconnected
        UIViewController *currentGameView = ((UIViewController *)GCM.delegate);
        NSLog(@"tournament scores: %@", scores);
        TournamentOverViewController *tovc = [[TournamentOverViewController alloc] initWithScores:scores];
        [currentGameView.modalViewController presentModalViewController:tovc animated:YES];
    
        //[currentGameView dismissModalViewControllerAnimated:YES];
    }
}

@end
