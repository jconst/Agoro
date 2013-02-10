//
//  GameTimer.h
//  WordSmith
//
//  Created by Joseph Constan on 7/19/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameTimerDelegate <NSObject>

@property (strong, nonatomic) UILabel *countdownLabel;

- (void) gameStarted;
- (void) endGame;

@end

@interface GameTimer : NSObject {
    NSTimer *timer;
    NSUInteger gameDuration;
    BOOL paused;
}

@property (nonatomic) NSInteger countdownState;
@property (nonatomic) UILabel *label;
@property (nonatomic) UIViewController <GameTimerDelegate> *delegate;

+ (GameTimer *) gameTimerWithDelegate:(UIViewController <GameTimerDelegate> *)newDelegate;

- (id) initWithDelegate:(UIViewController <GameTimerDelegate> *)newDelegate;
- (void) togglePause;
- (void) timerFired:(NSTimer *)theTimer;
- (void) end;

@end
