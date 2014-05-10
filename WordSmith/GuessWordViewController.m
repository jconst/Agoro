//
//  GuessWordViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 11/14/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "GuessWordViewController.h"
#import "SettingsViewController.h"
#import "GameCenterManager.h"
#import "GameOverViewController.h"
#import "AppDelegate.h"
#import "HintView.h"
#import "AIPlayer.h"
#import "PlayerScoreView.h"
#import "GameTimer.h"
#import "TileLabel.h"
#import "CustomTextField.h"

@implementation GuessWordViewController

@synthesize wordsToUse, countdownLabel, textField, wordLabel, hintView, skipButton, psv;

#pragma mark - Game Mechanics

- (void)gameStarted {
    
    skipButton.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        psv.alpha = 1;
        textField.alpha = 1;
        skipButton.alpha = 1;
        countdownLabel.alpha = 0;
    }];
    
    wordsToUse = [[NSMutableArray alloc] init];
    wordQueueCounter = 0;
    
    [self showNewWord];
    self.textReceiver = textField;
    wordLabel.textReceiver = textField;
    textField.tileLabel = wordLabel;
    
    [psv setNeedsDisplay];
}

- (void)showNewWord {
        
    if (wordsToUse.count <= wordQueueCounter) {
        currentWord = [self generateNewWord];
    } else {
        currentWord = [wordsToUse objectAtIndex:wordQueueCounter];
    }
    
    wordLabel.text = [self shuffledWord:currentWord];
    [hintView loadHintsForWord:currentWord];
    
    wordQueueCounter++;
}

- (NSString *)generateNewWord {
    Lexicontext *lex = [Lexicontext sharedDictionary];
    NSString *word = [lex randomWord];
    while (word.length < 5 || word.length > 11 ||
           [word rangeOfCharacterFromSet:[[NSCharacterSet letterCharacterSet] invertedSet]].location != NSNotFound ||
           [lex definitionAsDictionaryFor:word].count <= 2 || [lex thesaurusFor:word].count <= 2) {
        
        word = [lex randomWord];
    }
    [wordsToUse addObject:word];
    if (!self.singlePlayer)
        [GCM sendWord:word];
    return word;
}

- (NSString *)shuffledWord:(NSString *)word {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float difficulty = [defaults floatForKey:kRTWDifficulty];
    if (!self.singlePlayer || difficulty == 0) difficulty = 0.5;
    NSMutableString *ret = [word mutableCopy];
    
    for (int i = 0; i < word.length; i++) {
        float rand = ((double)arc4random() / ARC4RANDOM_MAX) * 1.0f;
        if (rand <= difficulty) {
            int index = arc4random() % ret.length;
            
            NSRange a = NSMakeRange(i, 1);
            NSRange b = NSMakeRange(index, 1);
            NSString *temp = [ret substringWithRange:a];
            
            [ret replaceCharactersInRange:a withString:[ret substringWithRange:b]];
            [ret replaceCharactersInRange:b withString:temp];
        }
    }
    //If word wasn't properly shuffled, re-shuffle it
    if ([word isEqualToString:ret])
        return [self shuffledWord:ret];
    return ret;
}

- (IBAction)skipButtonPressed:(id)sender {
    
    [self showNewWord];
    NSInteger score = [[[GCM scores] objectForKey:[[GCM playerOrder] objectAtIndex:GCM.ourPlayerNumber]] integerValue];
    score -= 10;
    [[GCM scores] setObject:[NSNumber numberWithInteger:score] 
                     forKey:[[GCM playerOrder] objectAtIndex:GCM.ourPlayerNumber]];
    [psv setNeedsDisplay];
    textField.text = @"";

    if (!self.singlePlayer)
        [GCM sendScore:[[GCM.scores objectForKey:[[GKLocalPlayer localPlayer] playerID]] intValue]];
}

- (void)receivedWord:(NSString *)word fromPlayer:(NSString *)playerID {
    [wordsToUse addObject:word];
}

- (void)receivedScoreUpdate:(NSInteger)score fromPlayer:(NSString *)playerID {
    
    [GCM.scores setValue:[NSNumber numberWithInteger:score] forKey:playerID];
    [psv setNeedsDisplay];
}

- (IBAction)submitButtonPressed {
        
    NSString *str = [textField.text lowercaseString];
    
    if ([str isEqualToString:currentWord]) {
               
        [GCM givePointsForWord:currentWord toPlayer:GCM.ourPlayerNumber withMultiplier:1];
        [psv setNeedsDisplay];
        if (!self.singlePlayer)
            [GCM sendScore:[[GCM.scores objectForKey:[[GKLocalPlayer localPlayer] playerID]] intValue]];
        
        [self showNewWord];
        
        textField.text = @"";
    }
}

@end
