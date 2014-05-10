//
//  WordSmithViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 11/14/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "WordSmithViewController.h"
#import "GameOverViewController.h"
#import "GameCenterManager.h"
#import "AppDelegate.h"
#import "PlayerScoreView.h"
#import "AIPlayer.h"
#import "GameTimer.h"
#import "Lexicontext.h"
#import "TileButton.h"
#import "TileLabel.h"
#import "CustomTextField.h"
#import "WordList.h"

#define AIWORDS ((NSMutableArray *)[arrayOfWordArrays objectAtIndex:1])

@implementation WordSmithViewController

@synthesize arrayOfWordArrays, countdownLabel, textField, seedLabel, isUsingLex, seed, wordList;

#pragma mark - Game Mechanics

- (void)gameStarted {
    LOGMETHOD;
    [UIView animateWithDuration:0.5 animations:^{
        countdownLabel.alpha = 0;
    }];
    if (self.singlePlayer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            [aiPlayer beginFindingAnagramsFromString:seed inVC:self];
        });
    }
    
    seedLabel.text = seed;
    self.textReceiver = textField;
    seedLabel.textReceiver = textField;
    textField.tileLabel = seedLabel;
}

- (void)receivedWord:(NSString *)word fromPlayer:(NSString *)playerID {
    if (self.gameTimer.countdownState >= 0) {
        seed = word;
    } else {
        NSUInteger playerNumber = 0;
        for (int i = 0; i < [GCM numberOfPlayers]; i++) {
            if ([[[GCM playerOrder] objectAtIndex:i] isEqualToString:playerID])
                playerNumber = i;
        }
        [((NSMutableArray *)[arrayOfWordArrays objectAtIndex:playerNumber]) addObject:word];
    }
}

- (BOOL)word:(NSString *)word isAnagramOfString:(NSString *)imstr {
    
    BOOL ret = YES;
    if (word.length < 3) {
        return NO;
    }
    
    NSMutableString *str = [imstr mutableCopy];
    for (int i = 0; i < word.length; i++) {
        unichar wc = [word characterAtIndex:i];
        BOOL found = NO;
        
        if (wc == ' ' || wc == '-') {   //no spaces or dashes allowed?
            return NO;
        }
        for (int j = 0; j < str.length; j++) {
            
            if (wc == [str characterAtIndex:j]) {
                [str deleteCharactersInRange:NSMakeRange(j, 1)];
                found = YES;
                break;
            }
        }
        if (found)
            continue;
        return NO;
    }
    return ret;
}

- (void)awardWordScores {
    //configure AI's words collection for single player
    if (self.singlePlayer) {
        aiPlayer.gameRunning = NO;
        float newCount = (AIWORDS.count / 14) * (-(float)(self.gameTimer.countdownState) / 60.0);
        newCount *= (aiPlayer.difficulty + 0.5);
        int nc = (int)newCount;
        
        [AIWORDS removeObjectsInRange:NSMakeRange(nc, AIWORDS.count-nc)];
    }
    
    //award points to each player
    for (int i = 0; i < GCM.numberOfPlayers; i++) {
        NSArray *wordArray = [arrayOfWordArrays objectAtIndex:i];
        for (NSString *word in wordArray) {
            [GCM givePointsForWord:word toPlayer:i withMultiplier:1];
        }
    }
}

- (void)endGame {
    [self awardWordScores];
    [super endGame];
}

#pragma mark GameCenterManagerDelegate

- (void)matchStarted {
    [super matchStarted];
        
    arrayOfWordArrays = [[NSMutableArray alloc] initWithCapacity:4];
    for (int i = 0; i < GCM.numberOfPlayers; i++) {
        [arrayOfWordArrays addObject:[NSMutableArray array]];
    }
        
    if (GCM.ourPlayerNumber == 0) {
        seed = @"";
        while (seed.length < 9 || seed.length > 13) {
            seed = [[Lexicontext sharedDictionary] randomWord];
        }        
        if (!self.singlePlayer)
            [GCM sendWord:seed];
    }
}

- (IBAction)submitButtonPressed {
    
    NSString *str = [textField.text lowercaseString];
    
    isUsingLex = YES;
    if ([self word:str isAnagramOfString:seed] &&
        [[Lexicontext sharedDictionary] containsDefinitionFor:str]) {
        
        NSMutableArray *words = [arrayOfWordArrays objectAtIndex:GCM.ourPlayerNumber];
        
        BOOL alreadyFound = NO;
        for (NSString *anagram in words) {
            if ([anagram isEqualToString:str]) {
                alreadyFound = YES;
                break;
            }
        }
                
        if (!alreadyFound) {
            //Valid anagram found, add to word list and send to other players
            [words addObject:str];
            if (!self.singlePlayer)
                [GCM sendWord:str];
            [wordList addWord:str];

        }
        
        textField.text = @"";
    }
    isUsingLex = NO;
}

@end
