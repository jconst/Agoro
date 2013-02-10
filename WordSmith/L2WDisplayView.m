//
//  L2WDisplayView.m
//  WordSmith
//
//  Created by Joseph Constan on 12/17/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "L2WDisplayView.h"
#import "GameViewController.h"
#import "Lexicontext.h"
#import "GameCenterManager.h"
#import "PlayerScoreView.h"

@implementation L2WDisplayView

@synthesize delegate, prefix, turnUsed;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        prefix = @"";
        turnUsed = NO;
        
        displayLabel = [[UILabel alloc] initWithFrame:self.bounds];
        displayLabel.adjustsFontSizeToFitWidth = YES;
        displayLabel.font = [UIFont boldSystemFontOfSize:40.0];
        displayLabel.backgroundColor = [UIColor clearColor];
        displayLabel.text = @"";
        displayLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:displayLabel];
        [self letterAdded:@""];
        
        pids = [[GameCenterManager sharedInstance] playerOrder];
    }

    return self;
}

- (void)letterAdded:(NSString *)letter {
    
    NSString *oldPrefix = prefix;
    prefix = [NSString stringWithFormat:@"%@%@", prefix, letter];
    
    switch ([self prefixStatus:prefix]) {
        case incomplete:
            displayLabel.textColor = [UIColor blueColor];
            displayLabel.text = [NSString stringWithFormat:@"%@☐", prefix];
            [delegate turnChanged];
            break;
        case invalid: {
            displayLabel.textColor = [UIColor redColor];
            displayLabel.text = prefix;
            
            [UIView animateWithDuration:0.35 animations:^{
                displayLabel.alpha = 0;
            } completion:^(BOOL finished) {
                prefix = @"";
                [self letterAdded:@""];
                displayLabel.alpha = 1;
            }];
            
            if (letter.length == 1) {
                NSUInteger previousTurn = delegate.turn - 1;
                if (previousTurn <= 0)
                    previousTurn = [[[GameCenterManager sharedInstance] playerOrder] count];
                [[GameCenterManager sharedInstance] givePointsForWord:oldPrefix toPlayer:previousTurn-1 withMultiplier:1];
                [delegate.psv setNeedsDisplay];
            }
        } break;
        case complete: {
            displayLabel.textColor = [UIColor greenColor];
            displayLabel.text = prefix;
            
            [UIView animateWithDuration:0.35 animations:^{
                displayLabel.alpha = 0;
            } completion:^(BOOL finished) {
                prefix = @"";
                [self letterAdded:@""];
                displayLabel.alpha = 1;
            }];
            
            [[GameCenterManager sharedInstance] givePointsForWord:oldPrefix toPlayer:delegate.turn-1 withMultiplier:1];
            [delegate.psv setNeedsDisplay];
        } break;
        default:
            break;
    }
}

- (prefixStat)prefixStatus:(NSString *)pref {
    
    if (pref.length < 2)
        return incomplete;
    
    Lexicontext *lex = [Lexicontext sharedDictionary];
    NSDictionary *source = [lex wordsWithPrefix:pref];
    NSMutableArray *result = [NSMutableArray array];
    
    for (id key in source) {
        for (NSString *word in (NSArray *)[source objectForKey:key]) {
            if ([word rangeOfCharacterFromSet:
                 [[NSCharacterSet letterCharacterSet] invertedSet]].location == NSNotFound) //word has only letter characters
                [result addObject:word];
        }
    }
    
    for (NSString *word in result) {
        if ([word isEqualToString:pref] && result.count == 1)
            return complete;
        else
            return incomplete;
    }
    return invalid;
}

#pragma mark UIKeyInput

- (void)insertText:(NSString *)text {
    
    NSString *currentPID = [pids objectAtIndex:([delegate turn]-1)];
    text = [text lowercaseString];
    
    //check if it is local player's turn:
    if ([currentPID isEqualToString:kP1ID] ||
        [[[GKLocalPlayer localPlayer] playerID] isEqualToString:currentPID]) {
        
        if (text.length == 1) {
            if ([text rangeOfCharacterFromSet:[[NSCharacterSet letterCharacterSet] 
                                               invertedSet]].location == NSNotFound){ //word has only letter characters
                //make sure the same player doesn't go twice in a row:
                if (turnUsed)
                    return;
                [self letterAdded:text];
                if (!delegate.singlePlayer) {
                    [[GameCenterManager sharedInstance] sendMoveWithLetter:text];
                    turnUsed = YES;
                }
            }
        }
    }
}

- (void)deleteBackward {
    //Do nothing; This game doesn't allow backspacing
}

- (BOOL)hasText {
    return YES;
}

- (BOOL)canBecomeFirstResponder {
    return YES;  
}

@end
