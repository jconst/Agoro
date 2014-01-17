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
#import <iAd/iAd.h>

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

- (IBAction)fbLoginPressed:(id)sender {
    [APPDELEGATE logInToFacebook];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [l2wSlider setMinimumValue:0.1];
    [rtwSlider setMinimumValue:0.1];
    [wsSlider setMinimumValue:0.1];
    
    [l2wSlider setMinimumTrackImage:[UIImage imageNamed:@"ZipperMin.png"] forState:UIControlStateNormal];
    [l2wSlider setMaximumTrackImage:[UIImage imageNamed:@"ZipperMax.png"] forState:UIControlStateNormal];
    [l2wSlider setThumbImage:[UIImage imageNamed:@"Slider.png"] forState:UIControlStateNormal];
    
    [rtwSlider setMinimumTrackImage:[UIImage imageNamed:@"ZipperMin.png"] forState:UIControlStateNormal];
    [rtwSlider setMaximumTrackImage:[UIImage imageNamed:@"ZipperMax.png"] forState:UIControlStateNormal];
    [rtwSlider setThumbImage:[UIImage imageNamed:@"Slider.png"] forState:UIControlStateNormal];
    
    [wsSlider setMinimumTrackImage:[UIImage imageNamed:@"ZipperMin.png"] forState:UIControlStateNormal];
    [wsSlider setMaximumTrackImage:[UIImage imageNamed:@"ZipperMax.png"] forState:UIControlStateNormal];
    [wsSlider setThumbImage:[UIImage imageNamed:@"Slider.png"] forState:UIControlStateNormal];
    
    if ([defaults floatForKey:kL2WDifficulty]) {
        [l2wSlider setValue:[defaults floatForKey:kL2WDifficulty] animated:NO];
        [rtwSlider setValue:[defaults floatForKey:kRTWDifficulty] animated:NO];
        [wsSlider setValue:[defaults floatForKey:kWSDifficulty] animated:NO];
    } else {
        [l2wSlider setValue:0.55 animated:NO];
        [rtwSlider setValue:0.55 animated:NO];
        [wsSlider setValue:0.55 animated:NO];
    }

    [APPDELEGATE showAdInView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setFloat:[l2wSlider value] forKey:kL2WDifficulty];
    [defaults setFloat:[rtwSlider value] forKey:kRTWDifficulty];
    [defaults setFloat:[wsSlider value] forKey:kWSDifficulty];
    
    [defaults synchronize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
