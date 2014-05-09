//
//  NextRoundViewController.h
//  WordSmith
//
//  Created by Joseph Constan on 7/18/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definitions.h"

@interface NextRoundViewController : UIViewController <GameCenterManagerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *bgView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@end
