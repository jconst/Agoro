//
//  WordSmithViewController.h
//  WordSmith
//
//  Created by Joseph Constan on 11/14/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseGameViewController.h"

@class AIPlayer, GameTimer, CustomTextField, TileLabel, WordList;

@interface WordSmithViewController : BaseGameViewController <GameCenterManagerDelegate>

//this array contains up to 4 different arrays, which in turn contain 
//each anagram found so far by each respective player:
@property (retain) NSMutableArray *arrayOfWordArrays;

@property (strong, nonatomic) NSString *seed;
@property (strong, nonatomic) IBOutlet CustomTextField *textField;
@property (strong, nonatomic) IBOutlet TileLabel *seedLabel;
@property (strong, nonatomic) IBOutlet UILabel *countdownLabel;
@property (strong, nonatomic) IBOutlet WordList *wordList;

@property (assign, nonatomic) BOOL isUsingLex;  //to keep player & AI from trying to access lexicontext at the same time

- (IBAction)submitButtonPressed;
- (void) gameStarted;
- (void) receivedWord:(NSString *)word fromPlayer:(NSString *)playerID;
- (BOOL) word:(NSString *)word isAnagramOfString:(NSString *)imstr;

@end