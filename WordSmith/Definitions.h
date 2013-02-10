//
//  Definitions.h
//  WordSmith
//
//  Created by Joseph Constan on 10/4/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#ifndef WordSmith_Definitions_h
#define WordSmith_Definitions_h

#import <GameKit/GameKit.h>

typedef enum {
    l2w = 1,
    ws,
    rtw,
    UNKNOWN
} GameType;

@protocol GameCenterManagerDelegate <NSObject>
@optional
- (void) processGameCenterAuth: (NSError*) error;
- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error;
- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error;
- (void) achievementResetResult: (NSError*) error;
- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error;

// Matchmaking
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerID;
@end

#endif
