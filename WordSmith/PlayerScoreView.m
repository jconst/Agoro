//
//  PlayerScoreView.m
//  WordSmith
//
//  Created by Joseph Constan on 12/5/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "PlayerScoreView.h"

@implementation PlayerScoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        labels = [[NSMutableArray alloc] initWithCapacity:8];
        
        /*CGRect frm = CGRectMake(0, 0, self.frame.size.width, 24);
        UILabel *label = [[UILabel alloc] initWithFrame:frm];
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Scores:";
        [self addSubview:label];*/
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self removeAllSubviews];
    [labels removeAllObjects];
    
    // Drawing code
    NSDictionary *players = [GCM playersDict];
    NSArray *pids = [GCM playerOrder];
    NSDictionary *scores = [GCM scores];
    
    for (int i = 1; i <= [pids count]; i++) {
        NSString *pid = [pids objectAtIndex:i-1];
        NSString *alias;
        
        if ([pid isEqualToString:kCompID]) {
            if (GCM.gType == rtw)
                continue;
            else
                alias = @"Computer";
        } else if ([pid isEqualToString:kP1ID]) {
            if ([GKLocalPlayer localPlayer])
                alias = [[GKLocalPlayer localPlayer] alias];
        } else {
            alias = [[players objectForKey:pid] alias] ?: [NSString stringWithFormat:@"Player %d", i];
        }
        if (!alias) {
            alias = [NSString stringWithFormat:@"Player %d", i];
        }
        
        NSNumber *score = [scores objectForKey:pid] ? [scores objectForKey:pid] : 
        [NSNumber numberWithInt:0];
        
        CGRect frm = CGRectMake(0, i*16, self.frame.size.width, 16);
        UILabel *label = [[UILabel alloc] initWithFrame:frm];
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%@: %@", alias, score];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0];
        [self addSubview:label];
        
        [labels addObject:label];
    }
}

- (void)removeAllSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

@end