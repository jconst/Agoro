//
//  GameOverViewController.h
//  WordSmith
//
//  Created by Joseph Constan on 12/18/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameOverViewController : UIViewController {
    NSInteger myScore;
    GameResult result;
    NSTimer *countdownTimer;
}

@property (assign, nonatomic) UIViewController *delegate;

@property (strong, nonatomic) IBOutlet UIButton *agoroButton;

- (void)displayScores;
- (GameResult)determineResult;
- (void)viewWordsPressed:(UIButton *)sender;
- (IBAction)submitScore;
- (IBAction)returnPressed;

@end
