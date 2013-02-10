//
//  SettingsViewController.h
//  WordSmith
//
//  Created by Joseph Constan on 12/14/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class MasterViewController;

#define kL2WDifficulty @"l2wDifficulty"
#define kWSDifficulty @"wsDifficulty"
#define kRTWDifficulty @"rtwDifficulty"
#define kGameDuration @"gameDuration"

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISlider *l2wSlider;
@property (strong, nonatomic) IBOutlet UISlider *rtwSlider;
@property (strong, nonatomic) IBOutlet UISlider *wsSlider;

@property (assign, nonatomic) MasterViewController *mvc;

- (IBAction)donePressed:(id)sender;

@end
