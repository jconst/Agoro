//
//  BaseGameViewController.h
//  WordSmith
//
//  Created by Joseph Constan on 7/19/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameTimer.h"


@class AIPlayer, GameTimer;

@interface BaseGameViewController : UIViewController <GameTimerDelegate, GameCenterManagerDelegate, UIActionSheetDelegate> {
    @public
    AIPlayer *aiPlayer;
}

@property (strong, nonatomic) GameTimer *gameTimer;
@property (nonatomic) BOOL singlePlayer;
@property (nonatomic) UIView <UIKeyInput> *textReceiver;

- (void) gameStarted;
- (void) endPressed;
- (void) endGame;

@end
