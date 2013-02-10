//
//  TileButton.h
//  WordSmith
//
//  Created by Joseph Constan on 7/24/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTileFrame CGRectMake(0,0,36,36)

@interface TileButton : UIButton

@property (strong, nonatomic) NSString *letter;

+ (TileButton *)tileWithLetter:(NSString *)letter;

@end
