//
//  GameOverViewController.h
//  WordSmith
//
//  Created by Joseph Constan on 12/18/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TournamentManager.h"

@interface GameOverViewController : UIViewController {
    NSInteger myScore;
    GameResult result;
    NSTimer *countdownTimer;
}

@property (assign, nonatomic) UIViewController *delegate;

@property (strong, nonatomic) IBOutlet UIButton *agoroButton;
@property (strong, nonatomic) IBOutlet UIButton *fbButton;
@property (strong, nonatomic) IBOutlet UILabel *nextRoundLabel;

- (void)decreaseNextRoundCounter;
- (void)displayScores;
- (GameResult)determineResult;
- (void)viewWordsPressed:(UIButton *)sender;
- (IBAction)submitScore;
- (IBAction)returnPressed;
- (IBAction)FBButtonPressed:(id)sender;

@end
