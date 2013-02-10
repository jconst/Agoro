#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Definitions.h"

typedef enum {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateReceivedRandoms,
    kGameStateWaitingToPressPlay,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
} GameState;

//#define TestingTournament 1
//#define AdsEnabled 1

#define GAMENAME(x) [[NSArray arrayWithObjects: @"",@"Letter 2 Word",@"Word Smith",@"Reveal the Word",nil] objectAtIndex:(x)]
#define LEADERBOARD(x) [[NSArray arrayWithObjects: @"Letter2Word1",@"WordSmith1",@"RevealTheWord1",nil] objectAtIndex:(x)]

#define kCompID @"CompPlayer001"
#define kP1ID @"HumanPlayer001"

#define GCM [GameCenterManager sharedInstance]


@class GKLeaderboard, GKAchievement, GKPlayer, TournamentManager;

@interface GameCenterManager : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate> 
{
    BOOL matchStarted;
    BOOL wasInvited;
    
	NSMutableDictionary* earnedAchievementCache;
	__weak id <GameCenterManagerDelegate, NSObject> delegate;
    BOOL userAuthenticated;
    NSUInteger numberOfBeginMessagesReceived;
}

@property (weak, nonatomic) id <GameCenterManagerDelegate> delegate;
@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;

//This property must be atomic to ensure that the cache is always in a viable state...
@property (strong) NSMutableDictionary* earnedAchievementCache;
@property (nonatomic) BOOL gameCenterAvailable;

//Game Data
@property (strong, nonatomic) NSMutableArray *playerOrder;        //array of NSStrings containing each player's ID, in turn order
@property (strong, nonatomic) NSMutableDictionary *playersDict;   //dictionary of GKPlayer objects with player IDs as keys
@property (strong, nonatomic) NSMutableDictionary *scores;        //dictionary of scores with player IDs as keys
@property (strong, nonatomic) NSMutableDictionary *randomNumbers; //dictionary of random numbers with player IDs as keys
@property (strong, nonatomic) TournamentManager *tournamentManager;

@property (assign, nonatomic) GameState gameState;
@property (assign, nonatomic) GameType  gType;
@property (assign, nonatomic) NSUInteger numberOfPlayers;
@property (assign, nonatomic) NSUInteger ourPlayerNumber;
@property (assign, nonatomic) uint32_t ourRandom;   
@property (assign, nonatomic) BOOL inTournament;


+ (GameCenterManager *)sharedInstance;
- (BOOL) isConnectedToInternet;
- (BOOL) isGameCenterAvailable;

//Game Setup
- (void) setupSinglePlayerGame;
- (void) setupMultiplayerGame;
- (void) setupTournament;
- (void)setInviteHandler;
- (void) authenticateLocalUser;
- (void) setGameState:(GameState)state;
- (void) tryStartGame;
- (void) mapPlayerIDtoPlayer: (NSString*) playerID;
- (void) givePointsForWord:(NSString *)word toPlayer:(NSUInteger)lastTurn withMultiplier:(float)mult;
- (void) findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                          invite:(GKInvite *)acceptedInvite
                 playersToInvite:(NSArray *)playersToInvite
                  viewController:(UIViewController *)viewController 
                        delegate:(id<GameCenterManagerDelegate>)theDelegate;

//Messages
- (void) sendData:(NSData *)data;
- (void) sendRandomNumber;
- (void) sendGameBegin;
- (void) sendGameOver;
- (void) sendMoveWithLetter:(NSString *)letter;
- (void) sendWord:(NSString *)word;
- (void) sendScore:(NSUInteger)score;
- (void) sendDisconnect;

//Scores
- (void)resetScores;
- (void) scoreReported: (NSError*) error;
- (void) reportScore: (int64_t) score forCategory: (NSString*) category;
- (void) reloadHighScoresForCategory: (NSString*) category;
//Achievements
- (void) submitAchievement: (NSString*) identifier percentComplete: (double) percentComplete;
- (void) resetAchievements;

@end
