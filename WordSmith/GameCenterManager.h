#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "DOSingleton.h"


typedef enum {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateReceivedRandoms,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
} GameState;


@class GKLeaderboard, GKPlayer;

@interface GameCenterManager : DOSingleton <GKMatchmakerViewControllerDelegate, GKMatchDelegate>
{
    BOOL matchStarted;
    BOOL wasInvited;
    
    BOOL userAuthenticated;
    NSUInteger numberOfBeginMessagesReceived;
}

@property (weak, nonatomic) id <GameCenterManagerDelegate> delegate;
@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;

@property (nonatomic) BOOL gameCenterAvailable;

//Game Data
@property (strong, nonatomic) NSMutableArray *playerOrder;        //array of NSStrings containing each player's ID, in turn order
@property (strong, nonatomic) NSMutableDictionary *playersDict;   //dictionary of GKPlayer objects with player IDs as keys
@property (strong, nonatomic) NSMutableDictionary *scores;        //dictionary of scores with player IDs as keys
@property (strong, nonatomic) NSMutableDictionary *randomNumbers; //dictionary of random numbers with player IDs as keys

@property (assign, nonatomic) GameState gameState;
@property (assign, nonatomic) GameType  gType;
@property (assign, nonatomic) NSUInteger numberOfPlayers;
@property (assign, nonatomic) NSUInteger ourPlayerNumber;
@property (assign, nonatomic) uint32_t ourRandom;   


- (BOOL) isConnectedToInternet;
- (BOOL) isGameCenterAvailable;

//Game Setup
- (void) setupSinglePlayerGame;
- (void) setupMultiplayerGame;
- (void) setInviteHandler;
- (void) authenticateLocalUser;
- (void) setGameState:(GameState)state;
- (void) tryStartGame;
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

@end
