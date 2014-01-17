//
//  AIPlayer.m
//  WordSmith
//
//  Created by Joseph Constan on 12/13/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "AIPlayer.h"
#import "Lexicontext.h"
#import "AppDelegate.h"
#import "L2WDisplayView.h"
#import "WordSmithViewController.h"
#import "SettingsViewController.h"
#import "GameCenterManager.h"

@implementation AIPlayer {
    GameType gameType;
}

@synthesize difficulty, gameRunning;

- (id)initForGame:(GameType)gt {
    
    if ((self = [super init])) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        gameType = gt;
        
        switch (gt) {
            case l2w:
                difficulty = [defaults floatForKey:kL2WDifficulty];
                break;
            case ws:
                difficulty = [defaults floatForKey:kWSDifficulty];
                break;
            case rtw:
                difficulty = [defaults floatForKey:kRTWDifficulty];
                break;
            default:
                difficulty = 0.55;
                break;
        }
    }
    if (self.difficulty < 0.1) {
        self.difficulty = 0.55;
    }
    
    return self;
}

#pragma mark - Letter 2 Word
- (void)turnStartedWithView:(L2WDisplayView *)dv {
    
        float timeToMove = (1-difficulty)+0.5;
        double startTime = [[NSDate date] timeIntervalSince1970];
        NSString *nextLetter = [self nextLetterForPrefix:dv.prefix];
    
        double midTime = [[NSDate date] timeIntervalSince1970];
        //[dv prefixIsValid:[NSString stringWithFormat:@"%@%@", dv.prefix, nextLetter]];
    
        double endTime = [[NSDate date] timeIntervalSince1970];
        double prefTime = endTime - midTime;
        [dv performSelector:@selector(letterAdded:) 
                 withObject:nextLetter 
                 afterDelay:timeToMove-(endTime-startTime)-prefTime];
}

- (NSString *)randomLetter {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz";
    unichar ret = [letters characterAtIndex:(int)(arc4random() % letters.length)];
    NSString *retStr = [NSString stringWithFormat:@"%C",ret];
    return retStr;
}

- (NSString *)nextLetterForPrefix:(NSString *)prefix {
    
    NSString *ret = @"";
    
    if (prefix.length <= 0) {
        return [self randomLetter];
    } 
    
    Lexicontext *lex = [Lexicontext sharedDictionary];
    
    if (prefix.length >= 1 && prefix.length <= 2) {
        while ([ret rangeOfString:prefix].location != 0) {
            ret = [lex randomWord];
        }
        return [NSString stringWithFormat:@"%C", [ret characterAtIndex:prefix.length]];
    }
    
    NSDictionary *result = [lex wordsWithPrefix:prefix];
    NSMutableArray *words = [NSMutableArray array];
    
    for (id key in result) {
        for (NSString *word in (NSArray *)[result objectForKey:key]) {
            if ([word rangeOfCharacterFromSet:[[NSCharacterSet letterCharacterSet] invertedSet]].location == NSNotFound && //word has only letter characters
                word.length > prefix.length) {  //word is longer than prefix
                [words addObject:word];
            }
        }
    }
    
    float r = arc4random() % 100;
    float prob = 50 + (difficulty * 50);
    
    if (words.count > 0) {
        if (r < prob) {
            NSString *word = [words objectAtIndex:(int)(arc4random() % words.count)];
            unichar ucRet = [word characterAtIndex:prefix.length];
            ret = [NSString stringWithFormat:@"%C", ucRet];
        } else {
            ret = [self randomLetter];
        }
    } else {
        ret = [self randomLetter];
    }
    
    return ret;
}

#pragma mark - Word Smith

- (void)beginFindingAnagramsFromString:(NSString *)str inVC:(WordSmithViewController *)vc {
    Lexicontext *lex = [Lexicontext sharedDictionary];
    gameRunning = YES;
    
    while (gameRunning) {
        if (vc.isUsingLex) {
            continue;
        }
        NSString *word = [lex randomWord];
        NSMutableArray *words = [vc.arrayOfWordArrays objectAtIndex:1];
        
        if ([vc word:word isAnagramOfString:str] && ![word isEqualToString:str]) {
            BOOL shouldContinue = NO;
            
            for (NSString *anagram in words) {
                if ([anagram isEqualToString:word]) {
                    shouldContinue = YES;
                    break;
                }
            }
            if (shouldContinue)
                continue;
            else {
                [words addObject:word];
            }
        }
    }
}

@end
