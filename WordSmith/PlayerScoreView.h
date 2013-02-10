//
//  PlayerScoreView.h
//  WordSmith
//
//  Created by Joseph Constan on 12/5/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterManager.h"

@interface PlayerScoreView : UIView {
    NSMutableArray *labels;
}

- (void)removeAllSubviews;

@end
