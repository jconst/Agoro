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

#pragma mark - App Delegate

//#define TestingTournament 1

#ifdef TARGET_AGORO_FREE

#define AdsEnabled 1

#endif

#define kFBAppID @"181955628559810"
#define kAppStoreLink @"http://itunes.apple.com/us/app/agoro-word-game/id549026849?ls=1&mt=8"
#define kAppIconLink @"http://img684.imageshack.us/img684/1453/agoroiconlarge.png"

#define ARC4RANDOM_MAX      0x100000000
#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define LOGMETHOD NSLog(@"Logged Method: %@", NSStringFromSelector(_cmd))

#pragma mark - Game Center Manager

#define GAMENAME(X) [[NSArray arrayWithObjects: @"",@"Letter 2 Word",@"Word Smith",@"Reveal the Word",nil] objectAtIndex:X]
#define LEADERBOARD(X) [[NSArray arrayWithObjects: @"Letter2Word1",@"WordSmith1",@"RevealTheWord1",nil] objectAtIndex:X]

#define kCompID @"CompPlayer001"
#define kP1ID @"HumanPlayer001"

#define GCM [GameCenterManager sharedInstance]


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
