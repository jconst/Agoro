//
//  TileButton.m
//  WordSmith
//
//  Created by Joseph Constan on 7/24/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import "TileButton.h"

@implementation TileButton

@synthesize letter;

+ (TileButton *)tileWithLetter:(NSString *)letter {
    
    TileButton *ret = [[TileButton alloc] initWithFrame:kTileFrame];
    
    ret.letter = letter;
    NSString *fileName = [NSString stringWithFormat:@"%@.png", [letter uppercaseString]];
    UIImage *tileImage = [UIImage imageNamed:fileName];
    [ret setImage:tileImage forState:UIControlStateNormal];
    
    return ret;
}

@end
