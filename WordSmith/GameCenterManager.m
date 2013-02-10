
#import "GameCenterManager.h"
#import "AppDelegate.h"
#import "MessageDefs.h"
#import "Reachability.h"
#import "TournamentManager.h"
#import "L2WDisplayView.h"
#import "Lexicontext.h"

@implementation GameCenterManager

//@synthesize ALL THE THINGS
@synthesize earnedAchievementCache, gameCenterAvailable, delegate, presentingViewController, match, playersDict, 
playerOrder, scores, gameState, ourPlayerNumber, ourRandom, gType, numberOfPlayers, randomNumbers,
tournamentManager, inTournament;

static GameCenterManager *sharedManager = nil;


#pragma mark - Initialization
- (id) init
{
	self = [super init];
	if(self!= NULL)
	{
		earnedAchievementCache= NULL;
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
        }
        gameState = kGameStateDone;
	}
	return self;
}

+ (GameCenterManager *) sharedInstance {
    if (!sharedManager) {
        sharedManager = [[GameCenterManager alloc] init];
    }
    return sharedManager;
}

#pragma mark - Game Center Management


- (void) callDelegate: (SEL) selector withArg: (id) arg error: (NSError*) err
{
	assert([NSThread isMainThread]);
	if([delegate respondsToSelector: selector])
	{
		if(arg != NULL)
			[delegate performSelector: selector withObject: arg withObject: err];
		else
			[delegate performSelector: selector withObject: err];
	}
	else
		NSLog(@"Missed Method");
}

- (void) callDelegateOnMainThread: (SEL) selector withArg: (id) arg error: (NSError*) err
{
	dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [self callDelegate: selector withArg: arg error: err];
                   });
}

- (void)setGameState:(GameState)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch) {
        NSLog(@"Waiting for match");
    } else if (gameState == kGameStateWaitingForRandomNumber) {
        NSLog(@"Waiting for rand #s");
    } else if (gameState == kGameStateReceivedRandoms) {
        NSLog(@"Received all rand #s, waiting for players to initialize");
    } else if (gameState == kGameStateWaitingToPressPlay) {
        NSLog(@"Next round of tournament, waiting for user to press play");
    } else if (gameState == kGameStateWaitingForStart) {
        NSLog(@"Initialized players, waiting for start");
    } else if (gameState == kGameStateActive) {
        NSLog(@"Game Active");
    } else if (gameState == kGameStateDone) {
        NSLog(@"Game Done");
        numberOfBeginMessagesReceived = 0;
    }
}

- (BOOL) isConnectedToInternet {
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
    
    return ((internetStatus == ReachableViaWiFi) || (internetStatus == ReachableViaWWAN));
}

- (BOOL) isGameCenterAvailable
{
	// check for presence of GKLocalPlayer API
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	// check if the device is running iOS 4.1 or later
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

- (void) authenticateLocalUser
{
    if (!gameCenterAvailable) return;
    
	if([GKLocalPlayer localPlayer].authenticated == NO)
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
}

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        userAuthenticated = TRUE;
        
        [self setInviteHandler];
        
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        userAuthenticated = FALSE;
        [APPDELEGATE showAlertWithTitle:@"Game Center Login Failed" message:@"We were unable to log you in with Game Center. \
         You will only be able to play single player games until you can log in."];
    }
}

#pragma mark - Matchmaking

- (void)setInviteHandler {
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        // Insert game-specific code here to clean up any game in progress:
        if (gameState != kGameStateWaitingForMatch && gameState != kGameStateDone) {
            if(inTournament)
                [tournamentManager endTournament];
            if (delegate && [delegate respondsToSelector:@selector(matchEnded)])
                [delegate matchEnded];
        }
        
        UIViewController *topVC = APPDELEGATE.navController.topViewController;
        
        if (acceptedInvite) {
            NSLog(@"acceptedInvite");
            wasInvited = YES;
            gType = UNKNOWN;
            
            [self findMatchWithMinPlayers:2 maxPlayers:4 invite:acceptedInvite playersToInvite:nil viewController:topVC delegate:nil];
        } else {
            NSLog(@"!acceptedInvite");
            //No game mode set, default to tournament:
            inTournament = YES;
            gType = l2w;
            [self findMatchWithMinPlayers:2 maxPlayers:4 invite:nil playersToInvite:playersToInvite viewController:topVC delegate:nil];
        }
    };
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                         invite:(GKInvite *)acceptedInvite
                playersToInvite:(NSArray *)playersToInvite
                 viewController:(UIViewController *)viewController
                       delegate:(id<GameCenterManagerDelegate>)theDelegate {
    
    if (!gameCenterAvailable) return;
    LOGMETHOD;
    
    randomNumbers = [[NSMutableDictionary alloc] initWithCapacity:4];
    playersDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    ourRandom = arc4random();
    gameState = kGameStateWaitingForMatch;
    
    matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    if (theDelegate) self.delegate = theDelegate;
    
    GKMatchmakerViewController *mmvc;
    
    if (acceptedInvite) {
        mmvc = [[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite];
    } else {
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        request.minPlayers = minPlayers;
        request.maxPlayers = maxPlayers;
        request.playersToInvite = playersToInvite;
        request.playerGroup = (inTournament) ? 4 : gType;      //ensures L2W players don't get matched with WS players, etc.
        if ([request respondsToSelector:@selector(setDefaultNumberOfPlayers:)])
            request.defaultNumberOfPlayers = 2;
        
        mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    }
    mmvc.matchmakerDelegate = self;
    
    NSLog(@"about to present");
    [presentingViewController presentViewController:mmvc animated:YES completion:nil];
    NSLog(@"made call to present");
}

#pragma mark GKMatchmakerViewControllerDelegate

// A peer-to-peer match has been found
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    gameState = kGameStateWaitingForRandomNumber;
    LOGMETHOD;
    self.match = theMatch;
    match.delegate = self;
    numberOfPlayers = match.playerIDs.count + match.expectedPlayerCount + 1; //+1 for local player
    if (!matchStarted && match.expectedPlayerCount == 0) {
        if (wasInvited && gType == UNKNOWN) {
            //Wait for gType data
        } else {
            [self sendGameTypeData];
            [self beginSetup];
        }
    }
}

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    LOGMETHOD;
    [presentingViewController dismissModalViewControllerAnimated:YES];
    [presentingViewController.navigationController popToRootViewControllerAnimated:NO];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    LOGMETHOD;
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@\nMatch request: %d", error.localizedDescription, viewController.matchRequest.minPlayers);
}

#pragma mark - Game Setup

#pragma mark Single Player

- (void)setupSinglePlayerGame {
    
    GCM.inTournament = NO;
    
    // Populate players dict
    self.playersDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    self.playerOrder = [[NSMutableArray alloc] initWithCapacity:2];
    self.scores = [[NSMutableDictionary alloc] initWithCapacity:2];
        
    GKPlayer *player = [GKLocalPlayer localPlayer];
    NSString *compID = kCompID;
    
    if (!player.playerID) {
        [playerOrder addObject:kP1ID];
        [scores setObject:[NSNumber numberWithInt:0] forKey:kP1ID];
    } else {
        [playersDict setObject:player forKey:player.playerID];
        [playerOrder addObject:player.playerID];
        [scores setObject:[NSNumber numberWithInt:0] forKey:player.playerID];
    }
    [playerOrder addObject:compID];
    [scores setObject:[NSNumber numberWithInt:0] forKey:compID];

    // Notify delegate that the (single player) match can begin
    matchStarted = YES;
    ourPlayerNumber = 0;
    numberOfPlayers = 2;
    gameState = kGameStateActive;
    [delegate matchStarted];
}

#pragma mark Multiplayer

//Only called for mult/tourn matches. Called AFTER received game type data from inviter (if applicable)
- (void)beginSetup {
    LOGMETHOD;
    
    [presentingViewController dismissModalViewControllerAnimated:YES];  //Get rid of matchmaker view
    
    if (inTournament) {
        [self setupTournament];
    } else {
        [self setupMultiplayerGame];
    }
    
    if (wasInvited) {
        if (inTournament) {
            NSLog(@"beginSetup inTournament");
            NextRoundViewController *nrVC = [presentingViewController.storyboard instantiateViewControllerWithIdentifier:@"NextRoundView"];
            [presentingViewController.navigationController pushViewController:nrVC animated:YES];
            self.delegate = nrVC;
        } else {
            switch (gType) {
                case l2w: {
                    GameViewController *l2wVC = [presentingViewController.storyboard instantiateViewControllerWithIdentifier:@"l2wView"];
                    [presentingViewController.navigationController pushViewController:l2wVC animated:YES];
                    self.delegate = l2wVC;
                    break;
                } case ws: {
                    WordSmithViewController *wsVC = [presentingViewController.storyboard instantiateViewControllerWithIdentifier:@"wsView"];
                    [presentingViewController.navigationController pushViewController:wsVC animated:YES];
                    self.delegate = wsVC;
                    break;
                } case rtw: {
                    GuessWordViewController *rtwVC = [presentingViewController.storyboard instantiateViewControllerWithIdentifier:@"rtwView"];
                    [presentingViewController.navigationController pushViewController:rtwVC animated:YES];
                    self.delegate = rtwVC;
                    break;
                } default: {
                    NSLog(@"gType unknown");
                    break;
                }
            }
        }
    }
}

- (void)setupTournament {
    LOGMETHOD;
    //Load "playersDict" with the players in the match
    [self lookupPlayers];
    
    tournamentManager = [[TournamentManager alloc] init];
    [tournamentManager startTournament];
}

//called AFTER finding match and BEFORE sending/receiving random numbers
- (void)setupMultiplayerGame {
    LOGMETHOD;
    if (!inTournament) {    //Not in tournament:
        //Load "playersDict" with the players in the match
        [self lookupPlayers];
    }

    scores = [[NSMutableDictionary alloc] initWithCapacity:4];
    numberOfBeginMessagesReceived = 0;
    
    [self receivedRandomNumber:ourRandom fromPlayer:[[GKLocalPlayer localPlayer] playerID]];
    [self sendRandomNumber];
}

- (void)receivedRandomNumber:(uint32_t)randomNumber fromPlayer:(NSString *)playerID {
    
    NSLog(@"Received random number: %u, ours %u", randomNumber, ourRandom);
    
    [randomNumbers setObject:[NSNumber numberWithUnsignedInt:randomNumber] forKey:playerID];
    
    if (randomNumbers.count == numberOfPlayers) {
        gameState = kGameStateReceivedRandoms;
        if (!playersDict || playersDict.count == 0)
            NSLog(@"can't initialize players yet, players haven't been looked up");
        else
            [self initializePlayers];
    }
}

- (void)lookupPlayers {
    LOGMETHOD;
    [GKPlayer loadPlayersForIdentifiers:match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            matchStarted = NO;
            [delegate matchEnded];
        } else {
            NSLog(@"found players");
            //populate the player dictionary with all wireless players
            for (GKPlayer *player in players) {
                [playersDict setObject:player forKey:player.playerID];
            }
            //add local player to the dictionary
            [playersDict setObject:[GKLocalPlayer localPlayer] forKey:[[GKLocalPlayer localPlayer] playerID]];
            //Received randoms yet?
            if (gameState == kGameStateReceivedRandoms)
                [self initializePlayers];
        }
    }];
}

//Called after all random numbers are received AND all player information has been looked up, whichever comes last
- (void)initializePlayers {
    LOGMETHOD;
    //Organize lists of players using some kind of insertion sort abomination
    playerOrder = [[NSMutableArray alloc] initWithCapacity:numberOfPlayers];
    for (NSString *playerID in randomNumbers) {
        uint32_t randomBeingInserted = [(NSNumber *)[randomNumbers objectForKey:playerID] unsignedIntValue];
        
        if (playerOrder.count <= 0) {
            [playerOrder addObject:playerID];
        } else {
            for (int i = 0; i < playerOrder.count; i++) {
                
                NSString *idInList = [playerOrder objectAtIndex:i];
                uint32_t randomInList = [(NSNumber *)[randomNumbers objectForKey:idInList] unsignedIntValue];
                
                if (randomBeingInserted < randomInList) {
                    [playerOrder insertObject:playerID atIndex:i];
                    break;
                } else if (i == playerOrder.count-1) {
                    [playerOrder addObject:playerID];
                    break;
                }
            }
        }
    }
    //Determine which player we are (Player 0 will act essentially as the "host" of the game)
    for (int i = 0; i < playerOrder.count; i++) {
        if ([(NSString *)[playerOrder objectAtIndex:i] isEqualToString:[[GKLocalPlayer localPlayer] playerID]])
            ourPlayerNumber = i;
    }
    
    //Add score NSNumbers to the score dictionary
    [self resetScores];
    
    //Let other players know we're ready to start:
    gameState = kGameStateWaitingForStart;
    
    if (!inTournament) {
        [self sendGameBegin];
        [self tryStartGame];
    }
}

- (void)tryStartGame {
    LOGMETHOD;
    NSLog(@"num of Players: %d", numberOfPlayers);
    NSLog(@"num of begin msgs: %d", numberOfBeginMessagesReceived);
    
    if (numberOfBeginMessagesReceived >= numberOfPlayers - 1 &&
        gameState == kGameStateWaitingForStart &&
        [delegate respondsToSelector:@selector(matchStarted)]) {
        
        // Notify delegate match can begin
        matchStarted = YES;
        gameState = kGameStateActive;
        [self sendGameBegin];
        [delegate matchStarted];
    }
}

#pragma mark - Game Management

#pragma mark Messages

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [self.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        NSLog(@"Error sending init packet");
        [self match:self.match didFailWithError:error];
    }
}

- (void)sendRandomNumber {
    LOGMETHOD;
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];    
    [self sendData:data];
}

- (void)sendGameBegin {
    
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];    
    [self sendData:data];
}

- (void)sendMoveWithLetter:(NSString *)letter {
    
    MessageMove message;
    message.message.messageType = kMessageTypeMove;
    message.letter = [letter characterAtIndex:0];
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove)];    
    [self sendData:data];
}

- (void)sendScore:(NSUInteger)score {
    
    MessageScore message;
    message.message.messageType = kMessageTypeScore;
    message.score = score;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageScore)];    
    [self sendData:data];
}

- (void) sendGameTypeData {
    int type = (inTournament) ? 4 : gType;
    NSString *message = [NSString stringWithFormat:@"gtp%d", type];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self sendData:data];
}

- (void) sendWord:(NSString *)word {
    
    NSString *message = [NSString stringWithFormat:@"wsw%@", word];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];    
    [self sendData:data];
}

- (void)sendGameOver {
    
    MessageGameOver message;
    message.message.messageType = kMessageTypeGameOver;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];    
    [self sendData:data];
}

- (void)sendDisconnect {
    MessageGameOver message;
    message.message.messageType = kMessageTypeGameOver;
    message.disconnect = YES;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];    
    [self sendData:data];
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    if (gType != l2w && [[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] substringToIndex:3] isEqualToString:@"wsw"]) {
        
        NSString *word = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] substringFromIndex:3];
        if (gType == ws)
            [((WordSmithViewController *)delegate) receivedWord:word fromPlayer:playerID];
        else if (gType == rtw)
            [((GuessWordViewController *)delegate) receivedWord:word fromPlayer:playerID];
        return;
    } else if (gType == UNKNOWN && [[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] substringToIndex:3] isEqualToString:@"gtp"]) {
        NSString *typeStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] substringFromIndex:3];
        int typeInt = [typeStr intValue];
        if (typeInt == 4) {
            inTournament = YES;
            gType = l2w;
        } else
            gType = (GameType)typeInt;
        [self beginSetup];
    }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        MessageRandomNumber *messageInit = (MessageRandomNumber *) [data bytes];
        [self receivedRandomNumber:messageInit->randomNumber fromPlayer:playerID];
        
    } else if (message->messageType == kMessageTypeGameBegin) {
        
        numberOfBeginMessagesReceived++;

        NSLog(@"game state: %d", gameState);
        
        if (gameState == kGameStateWaitingForStart)
            [self tryStartGame];
        
    } else if (message->messageType == kMessageTypeMove) {
        
        if (gType == l2w) {
            MessageMove *messageMove = (MessageMove *) [data bytes];
            unichar letter = messageMove->letter;
            NSString *letterString = [NSString stringWithFormat:@"%C", letter];
            [[(GameViewController *)delegate dv] letterAdded:letterString];
        }
    } else if (message->messageType == kMessageTypeScore) {
        
        if (gType == rtw) {
            MessageScore *messageScore = (MessageScore *) [data bytes];
            NSInteger score = messageScore->score;
            [(GuessWordViewController *)delegate receivedScoreUpdate:score fromPlayer:playerID];
        }
    } else if (message->messageType == kMessageTypeGameOver) {
        
        if (inTournament && ((MessageGameOver *)message)->disconnect == YES) {
            [tournamentManager endTournament];
        }
        [delegate matchEnded];
    }
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (match != theMatch) return;
    
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!matchStarted && theMatch.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
                if (wasInvited && gType == UNKNOWN) {
                    NSLog(@"wasInvited");
                    //Wait for gType data
                } else {
                    NSLog(@"!wasInvited");
                    [self sendGameTypeData];
                    [self beginSetup];
                }
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            matchStarted = NO;
            inTournament = NO;
            [delegate matchEnded];
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (match != theMatch) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    
    if (match != theMatch) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}

#pragma mark - Score Management

- (void)givePointsForWord:(NSString *)word toPlayer:(NSUInteger)playerNumber withMultiplier:(float)mult {
    
    NSDictionary *letterScores = [[NSDictionary alloc] initWithContentsOfFile:
                                  [[NSBundle mainBundle] pathForResource:@"letterscores" ofType:@"plist"]];
    NSInteger currentScore = [[scores objectForKey:[playerOrder objectAtIndex:playerNumber]] integerValue];
    NSInteger wordScore = 0;
    for (int i = 0; i < word.length; i++) {
        unichar letter = [word characterAtIndex:i];
        NSString *key = [NSString stringWithFormat:@"%C", letter];
        
        wordScore += [[letterScores objectForKey:key] unsignedIntegerValue];
    }
    [scores setObject:[NSNumber numberWithInteger:(int)(mult*(currentScore+wordScore))] 
                     forKey:[playerOrder objectAtIndex:playerNumber]];
    
    if ([[Lexicontext sharedDictionary] containsDefinitionFor:word]) {
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] addPopularWord:word];
    }
}

- (void)resetScores {
    for (NSString *playerID in playerOrder) {
        [scores setObject:[NSNumber numberWithInteger:0] forKey:playerID];
    }
}

- (void) reloadHighScoresForCategory: (NSString*) category
{
	GKLeaderboard* leaderBoard= [[GKLeaderboard alloc] init];
	leaderBoard.category= category;
	leaderBoard.timeScope= GKLeaderboardTimeScopeAllTime;
	leaderBoard.range= NSMakeRange(1, 1);
	
	[leaderBoard loadScoresWithCompletionHandler:  ^(NSArray *scores, NSError *error)
	{
		[self callDelegateOnMainThread: @selector(reloadScoresComplete:error:) withArg: leaderBoard error: error];
	}];
}

- (void) reportScore: (int64_t) score forCategory: (NSString*) category 
{
    NSLog(@"Reporting Score: %lld forCategory: %@", score, category);
	GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];	
	scoreReporter.value = score;
	[scoreReporter reportScoreWithCompletionHandler: ^(NSError *error) 
	 {
		 [self scoreReported:error];
	 }];
}

- (void) scoreReported: (NSError*) error {
    if (!error) {
        //[APPDELEGATE showAlertWithTitle:@"Score Uploaded" message:nil];
    } else {
        [APPDELEGATE showAlertWithTitle:@"Error Uploading Score" message:[error localizedDescription]];
    }
}

/*#pragma mark Achievements

//None of this is being used yet but it will be useful in the future

- (void) submitAchievement: (NSString*) identifier percentComplete: (double) percentComplete
{
	//GameCenter check for duplicate achievements when the achievement is submitted, but if you only want to report 
	// new achievements to the user, then you need to check if it's been earned 
	// before you submit.  Otherwise you'll end up with a race condition between loadAchievementsWithCompletionHandler
	// and reportAchievementWithCompletionHandler.  To avoid this, we fetch the current achievement list once,
	// then cache it and keep it updated with any new achievements.
	if(self.earnedAchievementCache == NULL)
	{
		[GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *theScores, NSError *error)
		{
			if(error == NULL)
			{
				NSMutableDictionary* tempCache= [NSMutableDictionary dictionaryWithCapacity: [theScores count]];
				for (GKAchievement* score in theScores)
				{
					[tempCache setObject: score forKey: score.identifier];
				}
				self.earnedAchievementCache= tempCache;
				[self submitAchievement: identifier percentComplete: percentComplete];
			}
			else
			{
				//Something broke loading the achievement list.  Error out, and we'll try again the next time achievements submit.
				[self callDelegateOnMainThread: @selector(achievementSubmitted:error:) withArg: NULL error: error];
			}

		}];
	}
	else
	{
		 //Search the list for the ID we're using...
		GKAchievement* achievement= [self.earnedAchievementCache objectForKey: identifier];
		if(achievement != NULL)
		{
			if((achievement.percentComplete >= 100.0) || (achievement.percentComplete >= percentComplete))
			{
				//Achievement has already been earned so we're done.
				achievement= NULL;
			}
			achievement.percentComplete= percentComplete;
		}
		else
		{
			achievement= [[GKAchievement alloc] initWithIdentifier: identifier];
			achievement.percentComplete= percentComplete;
			//Add achievement to achievement cache...
			[self.earnedAchievementCache setObject: achievement forKey: achievement.identifier];
		}
		if(achievement!= NULL)
		{
			//Submit the Achievement...
			[achievement reportAchievementWithCompletionHandler: ^(NSError *error)
			{
				 [self callDelegateOnMainThread: @selector(achievementSubmitted:error:) withArg: achievement error: error];
			}];
		}
	}
}

- (void) resetAchievements
{
	self.earnedAchievementCache= NULL;
	[GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error) 
	{
		 [self callDelegateOnMainThread: @selector(achievementResetResult:) withArg: NULL error: error];
	}];
}

- (void) mapPlayerIDtoPlayer: (NSString*) playerID
{
	[GKPlayer loadPlayersForIdentifiers: [NSArray arrayWithObject: playerID] withCompletionHandler:^(NSArray *playerArray, NSError *error)
	{
		GKPlayer* player= NULL;
		for (GKPlayer* tempPlayer in playerArray)
		{
			if([tempPlayer.playerID isEqualToString: playerID])
			{
				player= tempPlayer;
				break;
			}
		}
		[self callDelegateOnMainThread: @selector(mappedPlayerIDToPlayer:error:) withArg: player error: error];
	}];
	
}*/
@end