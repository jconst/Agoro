//
//  PopularWordsViewController.h
//  WordSmith
//
//  Created by Joseph Constan on 12/7/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Lexicontext.h"

@interface PopularWordsViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *popWords;
@property (strong, nonatomic) NSArray *recentWords;

@property (strong, nonatomic) IBOutlet UITableView *popularTable;
@property (strong, nonatomic) IBOutlet UITableView *recentTable;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
