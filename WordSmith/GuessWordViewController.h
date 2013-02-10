//
//  GuessWordViewController.h
//  WordSmith
//
//  Created by Joseph Constan on 11/14/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseGameViewController.h"

@class AIPlayer, PlayerScoreView, GameTimer, HintView, TileLabel, CustomTextField;

@interface GuessWordViewController : BaseGameViewController
{
    NSUInteger wordQueueCounter;
    
    NSString *currentWord;
}
@property (strong, nonatomic) NSMutableArray *wordsToUse;   //a queue of words to be guessed, ensures each player has same words

@property (strong, nonatomic) IBOutlet UILabel *countdownLabel;
@property (strong, nonatomic) IBOutlet CustomTextField *textField;
@property (strong, nonatomic) IBOutlet TileLabel *wordLabel;
@property (strong, nonatomic) IBOutlet HintView *hintView;
@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) IBOutlet PlayerScoreView *psv;

- (void) gameStarted;
- (void)receivedScoreUpdate:(NSInteger)score fromPlayer:(NSString *)playerID;
- (void)receivedWord:(NSString *)word fromPlayer:(NSString *)playerID;
- (void) showNewWord;
- (NSString *)generateNewWord;
- (IBAction)skipButtonPressed:(id)sender;
- (IBAction)submitButtonPressed;

@end
