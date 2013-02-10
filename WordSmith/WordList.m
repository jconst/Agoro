//
//  WordList.m
//  WordSmith
//
//  Created by Joseph Constan on 7/28/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import "WordList.h"

@implementation WordList

- (void) addWord:(NSString *)word {
    UIView *label = [self labelWithBackgroundForString:word];
    if (originOfNextWord.x + label.frame.size.width > self.frame.size.width) {
        originOfNextWord = CGPointMake(0, originOfNextWord.y + 30);
    }
    CGRect newFrame = label.frame;
    newFrame.origin = originOfNextWord;
    label.frame = newFrame;
    
    [self addSubview:label];
    
    originOfNextWord.x += (label.frame.size.width + 6);
    self.contentSize = CGSizeMake(self.frame.size.width, originOfNextWord.y + 30);
    if (originOfNextWord.y >= self.frame.size.height) {
        CGPoint bottomOffset = CGPointMake(0, self.contentSize.height - self.bounds.size.height);
        [self setContentOffset:bottomOffset animated:YES];
    }
}

- (UIView *)labelWithBackgroundForString:(NSString *)string {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 21)];
    //label.textColor = [UIColor darkGrayColor];
    label.text = [string uppercaseString];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    label.font = [UIFont fontWithName:@"AmericanTypewriter" size:21.0];
    [label sizeToFit];
    label.font = [UIFont fontWithName:@"AmericanTypewriter" size:16.0];

    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:label.frame];
    bgView.image = [UIImage imageNamed:@"WordBackground.png"];
    bgView.alpha = 0.9;
    [bgView addSubview:label];
    
    return bgView;
}

@end
