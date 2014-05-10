//
//  SettingsViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 12/14/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "MasterViewController.h"
#import "GameCenterManager.h"
#import "AppDelegate.h"

@implementation SettingsViewController

@synthesize l2wSlider, rtwSlider, wsSlider, mvc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)donePressed:(id)sender {
     
    [mvc dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [@[l2wSlider, rtwSlider, wsSlider] enumerateObjectsUsingBlock:^(UISlider *slider, NSUInteger i, BOOL *stop) {
        [slider setMinimumValue:0.1];
        [slider setMinimumTrackImage:[[UIImage imageNamed:@"ZipperMin.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]
                            forState:UIControlStateNormal];
        [slider setMaximumTrackImage:[UIImage imageNamed:@"ZipperMax.png"] forState:UIControlStateNormal];
        [slider setThumbImage:[UIImage imageNamed:@"Slider.png"] forState:UIControlStateNormal];
        
        if ([defaults floatForKey:DifficultyForGame(i)]) {
            double val = [defaults floatForKey:DifficultyForGame(i)];
            [slider setValue:val animated:NO];
        } else {
            [l2wSlider setValue:0.55 animated:NO];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [@[l2wSlider, rtwSlider, wsSlider] enumerateObjectsUsingBlock:^(UISlider *slider, NSUInteger i, BOOL *stop) {
        [defaults setFloat:[slider value]
                    forKey:DifficultyForGame(i)];
    }];
    [defaults synchronize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
