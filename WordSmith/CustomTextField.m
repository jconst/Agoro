//
//  CustomTextField.m
//  WordSmith
//
//  Created by Joseph Constan on 7/24/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import "CustomTextField.h"
#import "TileLabel.h"

@implementation CustomTextField

@synthesize tileLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clearButtonMode = UITextFieldViewModeAlways;
        self.userInteractionEnabled = NO;
        self.text = @"test";
    }
    return self;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (text.length <= 0) {
        [tileLabel enableTiles];
    }
}

- (void)insertText:(NSString *)newText {
    
    self.text = [self.text stringByAppendingString:newText] ?: newText;
}

- (BOOL)becomeFirstResponder {
    return NO;
}

@end
