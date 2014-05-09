//
//  GameOverViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 12/18/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "GameOverViewController.h"
#import "MasterViewController.h"
#import "GuessWordViewController.h"
#import "PlayerScoreView.h"
#import "AppDelegate.h"
#import "WordSmithViewController.h"
#import "TournamentManager.h"

#define kScoresFrame CGRectMake(162.5, 64, (self.view.bounds.size.width/3)-5, self.view.bounds.size.height/2.4)

@implementation GameOverViewController

@synthesize delegate, fbButton, nextRoundLabel, agoroButton;

- (IBAction)submitScore {
    if (GCM.gameCenterAvailable && [GCM isConnectedToInternet]) {
        [GCM reportScore:[(NSNumber *)[[GCM scores] objectForKey:[GCM.playerOrder objectAtIndex:GCM.ourPlayerNumber]] longLongValue]
             forCategory:LEADERBOARD(GCM.gType - 1)];
    } else {
        [APPDELEGATE showAlertWithTitle:@"Can't Submit Score to Leaderboard" message:@"Game Center is unavailable at this time."];
    }
}

- (IBAction)returnPressed {    
    [APPDELEGATE.navController popToRootViewControllerAnimated:NO];
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (GCM.inTournament) {
        if (GCM.tournamentManager.roundCounter == 3)
            nextRoundLabel.text = @"Results in 5";
        agoroButton.hidden = YES;
        fbButton.hidden = YES;
        nextRoundLabel.hidden = NO;
        countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(decreaseNextRoundCounter) userInfo:nil repeats:YES];
    }
    
    for (NSInteger i = 31; i <= 34; i++) {
        UIButton *viewWordsButton = (UIButton *)[self.view viewWithTag:i];
        viewWordsButton.hidden = ((GCM.gType != ws) || (i-30 > GCM.numberOfPlayers));
        [viewWordsButton addTarget:self action:@selector(viewWordsPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self displayScores];
    
    result = [self determineResult];
    
    //For WordSmith, list anagrams found by each player:
    /*if (!delegate)
        return;
    else if ([delegate isKindOfClass:[WordSmithViewController class]]) {
        WordSmithViewController *vc = (WordSmithViewController *)delegate;
        
        for (UIView *subview in self.view.subviews) {
            //  I gave the 4 textviews for displaying anagrams a tag of 1 - 4, which corresponds to the player
            //  whose anagrams it should display. Then I loop through each and load them all up with the
            //  corresponding text.
            if (subview.tag > 0 && subview.tag <= GCM.numberOfPlayers) {
                UITextView *textView = (UITextView *)subview;
                
                //Find alias for Player #(subview.tag) and store it in a string:
                NSString *alias;
                if (vc.singlePlayer) {
                    if (textView.tag == 1)
                        alias = @"Player 1";
                    else if (textView.tag == 2)
                        alias = @"Computer";
                } else {
                    NSString *pid = [[GCM playerOrder] objectAtIndex:textView.tag - 1];
                    alias = [[[GCM playersDict] objectForKey:pid] alias];
                }
                
                //Fill text view with list of anagrams
                textView.text = [NSString stringWithFormat:@"%@ found:", alias];
                NSArray *words = [vc.arrayOfWordArrays objectAtIndex:textView.tag-1];
                for (int i = 0; i < words.count; i++) {
                    NSString *str = [words objectAtIndex:i];
                    
                    textView.text = [NSString stringWithFormat:@"%@\n%d. %@", textView.text, i+1, str];
                }
            } 
        }
    }*/
}

- (void)displayScores {
    //Display Scores:
    //  I gave the 4 labels that display player aliases/scores tags of 11-14 & 21-24, which
    //  correspond to the player whose score it should display. Then I loop through each
    //  and load them all up with the corresponding text.
    for (int i = 1; i <= GCM.numberOfPlayers; i++) {
        UILabel *aliasLabel = (UILabel *)[self.view viewWithTag:i+10];
        UILabel *scoreLabel = (UILabel *)[self.view viewWithTag:i+20];
        
        //Find alias for Player #(subview.tag) and store it in a string:
        NSString *alias;
        NSString *pid = [[GCM playerOrder] objectAtIndex:i-1];
        BaseGameViewController *vc = (BaseGameViewController *)GCM.delegate;
        
        if (vc.singlePlayer) {
            if (i == 1)
                alias = @"Player 1";
            else if (i == 2)
                alias = @"Computer";
        } else {
            alias = [[[GCM playersDict] objectForKey:pid] alias];
        }
        aliasLabel.text = alias;
        scoreLabel.text = [[[GCM scores] objectForKey:pid] stringValue];
        
        aliasLabel.font = [UIFont fontWithName:@"BelloPro" size:20.0];
        if (vc.singlePlayer && GCM.gType == rtw)
            return;
    }
}

- (GameResult)determineResult {
    //Determine Win/loss/tie
    GameResult ret;
    BOOL didWin = YES;
    NSUInteger tieCount = 0;
    myScore = [[[GCM scores] objectForKey:[[GCM playerOrder] objectAtIndex:[GCM ourPlayerNumber]]] unsignedIntValue];
    
    for (NSString *key in [GCM scores]) {
        NSInteger score = [[[GCM scores] objectForKey:key] unsignedIntValue];
        if (myScore < score) {
            didWin = NO;
        } else if (myScore == score) {
            tieCount++;
        }
    }
    ret = (didWin) ? ((tieCount >= 2) ? tie : win) : loss;
    if (!GCM.inTournament) {
        [self submitScore];
    }
    return ret;
}

- (void)decreaseNextRoundCounter {
    //Decrement counter label:
    NSUInteger index = nextRoundLabel.text.length-1;
    NSInteger counter = [nextRoundLabel.text substringFromIndex:index].integerValue;
    if (counter > 0) counter--;
    nextRoundLabel.text = [NSString stringWithFormat:@"%@%ld", [nextRoundLabel.text substringToIndex:index], (long)counter];
    
    //Countdown finished:
    if (counter == 0) {
        /*if (GCM.tournamentManager.roundCounter == 3)
            [GCM.tournamentManager endTournament];
        else*/
            [GCM.tournamentManager roundEndedWithResult:result];
        [countdownTimer invalidate];
    }
}

- (IBAction)FBButtonPressed:(id)sender {
    NSString *playerName = @"I";
    if (![GCM isConnectedToInternet]) {
        [APPDELEGATE showAlertWithTitle:@"Can't post to Facebook" message:@"You aren't connected to the internet"];
    } else if ([GCM isGameCenterAvailable]) {
        playerName = [[GKLocalPlayer localPlayer] alias];
    }
    [APPDELEGATE postToFacebookWithMessage:
     [NSString stringWithFormat:@"%@ scored %ld points at %@ in Agoro Word Game! Can you beat it?",
      playerName, (long)myScore, GAMENAME(GCM.gType)]];
}

- (void)viewWordsPressed:(UIButton *)sender {
    NSInteger i = sender.tag - 30;
    WordSmithViewController *vc = (WordSmithViewController *)delegate;

    sender.hidden = YES;
    [self.view viewWithTag:i+10].hidden = YES; //Player alias
    [self.view viewWithTag:i+20].hidden = YES; //Score
    UITextView *textView = (UITextView *)[self.view viewWithTag:i];
    textView.userInteractionEnabled = YES;
    
    //Fill text view with list of anagrams
    textView.text = @"";
    NSArray *words = [vc.arrayOfWordArrays objectAtIndex:textView.tag-1];
    for (int i = 0; i < words.count; i++) {
        NSString *str = [words objectAtIndex:i];
        
        textView.text = [NSString stringWithFormat:@"%@\n%d. %@", textView.text, i+1, str];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
