//
//  WordList.h
//  WordSmith
//
//  Created by Joseph Constan on 7/28/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordList : UIScrollView {
    CGPoint originOfNextWord;
}

- (UIView *)labelWithBackgroundForString:(NSString *)string;
- (void)addWord:(NSString *)word;

@end
