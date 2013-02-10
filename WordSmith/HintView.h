//
//  HintView.h
//  WordSmith
//
//  Created by Joseph Constan on 2/24/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lexicontext.h"

@interface HintView : UITextView {
    
    NSMutableArray *hints;
}

- (void)loadHintsForWord:(NSString *)word;
- (NSString *)definitionForWord:(NSString *)word;
- (NSArray *)synonymsForWord:(NSString *)word;

@end
