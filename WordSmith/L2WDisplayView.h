//
//  L2WDisplayView.h
//  WordSmith
//
//  Created by Joseph Constan on 12/17/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    invalid = 0,
    incomplete,
    complete
} prefixStat;

@class L2WViewController;

@interface L2WDisplayView : UIView <UIKeyInput> {
    
    UILabel *displayLabel;
    NSString *prefix;
    NSArray *pids;
}

@property (nonatomic, weak) L2WViewController *delegate;
@property (strong, nonatomic) NSString *prefix;
@property (nonatomic) BOOL turnUsed;    //used to make sure the same player doesn't go twice in a row

- (void)letterAdded:(NSString *)letter;
- (prefixStat)prefixStatus:(NSString *)prefix;

@end
