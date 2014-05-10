//
//  GameViewController.h
//  WordSmith
//
//  Created by Joseph Constan on 10/12/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseGameViewController.h"

@class L2WDisplayView, AIPlayer, GameTimer, PlayerScoreView;

@interface L2WViewController : BaseGameViewController <GameCenterManagerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *countdownLabel;
@property (strong, nonatomic) IBOutlet UILabel *prefixLabel;
@property (strong, nonatomic) IBOutlet PlayerScoreView *psv;
@property (strong, nonatomic) IBOutlet UILabel *turnArrow;
@property (strong, nonatomic) L2WDisplayView *dv;

@property (nonatomic) NSUInteger turn;

- (void) gameStarted;
- (void) turnChanged;

@end
