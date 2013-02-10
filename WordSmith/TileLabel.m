//
//  TileLabel.m
//  WordSmith
//
//  Created by Joseph Constan on 7/24/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import "TileLabel.h"
#import "TileButton.h"

@implementation TileLabel

@synthesize text, textReceiver;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame textReceiver:nil text:nil];
}

- (id)initWithFrame:(CGRect)frame textReceiver:(id <UIKeyInput>)newTextReceiver text:(NSString *)newText
{
    self = [super initWithFrame:frame];
    if (self) {
        if (newTextReceiver)
            self.textReceiver = newTextReceiver;
        if (newText)
            self.text = newText;
    }
    return self;
}

- (void)setText:(NSString *)newText {
    
    [self removeAllSubviews];
     
    NSUInteger sideLen = kTileFrame.size.width;
    
    self.frame = CGRectMake(0, self.frame.origin.y, newText.length*sideLen, sideLen);
    self.center = CGPointMake(self.superview.center.x, self.center.y);
    
    for (int i = 0; i < newText.length; i++) {
        if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:[newText characterAtIndex:i]] ||
            [[NSCharacterSet punctuationCharacterSet] characterIsMember:[newText characterAtIndex:i]]) {
            continue;
        }
        TileButton *tile = [TileButton tileWithLetter:[newText substringWithRange:NSMakeRange(i, 1)]];
        tile.frame = CGRectMake(i*sideLen, 0, tile.frame.size.width, tile.frame.size.height);
        
        [tile addTarget:self action:@selector(tilePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tile];
    }
}

- (void)tilePressed:(TileButton *)sender {
    [textReceiver insertText:sender.letter];
    sender.enabled = NO;
}

- (void)enableTiles {
    for (UIView *subview in self.subviews) {
        ((TileButton *)subview).enabled = YES;
    }
}

- (void)removeAllSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

@end
