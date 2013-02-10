//
//  TournamentOverViewController.h
//  WordSmith
//
//  Created by Joseph Constan on 9/12/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TournamentManager.h"

@interface TournamentOverViewController : UIViewController {
        
    NSMutableArray *ourScores;
    NSMutableArray *totalScores;
    NSInteger ourTotal;
    
    GameResult tournamentResult;
    BOOL didWin;
}

@property (strong, nonatomic) IBOutlet UILabel *winScoreLabel;

- (IBAction)FBButtonPressed;
- (IBAction)pressedViewDetails:(id)sender;
- (id)initWithScores:(NSArray *)scores;
- (void)displayScores:(NSArray *)scoreArray withTotal:(NSInteger)total;

@end
