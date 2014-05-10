//
//  AIPlayer.h
//  WordSmith
//
//  Created by Joseph Constan on 12/13/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class L2WDisplayView, WordSmithViewController;

@interface AIPlayer : NSObject {
}

@property (nonatomic) float difficulty;
@property (nonatomic) BOOL gameRunning;

- (id)initForGame:(GameType)gt;
//Letter 2 Word
- (void)turnStartedWithView:(L2WDisplayView *)dv;
- (NSString *)nextLetterForPrefix:(NSString *)prefix;
- (NSString *)randomLetter;
//Word Smith
- (void)beginFindingAnagramsFromString:(NSString *)str inVC:(WordSmithViewController *)vc;

@end
