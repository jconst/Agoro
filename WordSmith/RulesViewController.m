//
//  RulesViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 11/15/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "RulesViewController.h"

@implementation RulesViewController

@synthesize textView;

- (void)viewWillAppear:(BOOL)animated {
    textView.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14.0];
    [textView setContentOffset:CGPointMake(0, 6) animated:NO];
}

- (IBAction)buttonPressed:(UIButton *)sender {
    NSArray *rulesArray = [[NSArray alloc] initWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"plist"]];
    textView.text = [rulesArray objectAtIndex:sender.tag];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
