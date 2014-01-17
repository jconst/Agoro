//
//  TileLabel.h
//  WordSmith
//
//  Created by Joseph Constan on 7/24/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileLabel : UIView

@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) id <UIKeyInput> textReceiver;

- (id)initWithFrame:(CGRect)frame textReceiver:(id <UIKeyInput>)newTextReceiver text:(NSString *)newText;
- (void)tilePressed:(id)sender;
- (void)removeAllSubviews;
- (void)enableTiles;

@end
