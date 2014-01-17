//
//  PopularWordsViewController.m
//  WordSmith
//
//  Created by Joseph Constan on 12/7/11.
//  Copyright (c) 2011 Codevs, Inc. All rights reserved.
//

#import "PopularWordsViewController.h"
#import "GameCenterManager.h"

@implementation PopularWordsViewController

@synthesize popWords, recentWords, popularTable, recentTable, webView;

#pragma mark - Facebook

- (IBAction)fbPressed {
    
    NSString *name;
    
    if ([GCM isConnectedToInternet] && [GCM isGameCenterAvailable])
        name = [[GKLocalPlayer localPlayer] alias];
    else
        name = @"I";
    
    NSMutableString *message = [NSMutableString stringWithFormat:@"%@ played these words most often in Agoro Word Game for iOS: ", name];
    
    for (int i = 0; i < popWords.count && i < 10; i++) {
        NSString *separator = (i == 9) ? @". Download Agoro now in the App Store." : @", ";
        [message appendString:[popWords objectAtIndex:i]];
        [message appendString:separator];
    }
    [APPDELEGATE postToFacebookWithMessage:message];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    recentWords = [[APPDELEGATE recentWords] copy];
    if (recentWords.count > 100) {
        recentWords = [recentWords subarrayWithRange:NSMakeRange(0, 100)];
    }
    popWords = [[NSMutableArray alloc] init];
    
    NSArray *keys = [[APPDELEGATE popularWords] keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue])
            return (NSComparisonResult)NSOrderedAscending;
        if ([obj1 integerValue] < [obj2 integerValue])
            return (NSComparisonResult)NSOrderedDescending;
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    //Cap popular words at 100
    keys = (keys.count > 100) ? [keys subarrayWithRange:NSMakeRange(0, 100)] : keys;
    
    Lexicontext *lex = [Lexicontext sharedDictionary];
    
    for (NSString *key in keys) {
        if ([lex containsDefinitionFor:key]) {
            [popWords addObject:key];
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:@selector(fbPressed)];
}

- (void)viewWillAppear:(BOOL)animated {
    popularTable.rowHeight = 22;
    recentTable.rowHeight = 22;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == popularTable)
        return [popWords count];
    else
        return [recentWords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    cell.textLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:10.0];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    if (tableView == popularTable)
        cell.textLabel.text = [popWords objectAtIndex:[indexPath row]];
    else
        cell.textLabel.text = [recentWords objectAtIndex:[indexPath row]];
    
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *word = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    Lexicontext *lex = [Lexicontext sharedDictionary];
    if ([lex containsDefinitionFor:word]) {
        NSMutableString *html = [[lex definitionAsHTMLFor:word] mutableCopy];
        
        //Fix up HTML styling:
        [html replaceOccurrencesOfString:@"<br/><br/>1" withString:@"<br/>1" options:0 range:NSMakeRange(0, [html length])];
        [html replaceOccurrencesOfString:@"#000000" withString:@"#343434" options:0 range:NSMakeRange(0, [html length])];
        [html replaceOccurrencesOfString:@"font-family:'Georgia'" withString:@"font-family:'AmericanTypewriter'" options:0 range:NSMakeRange(0, [html length])];
        [html replaceOccurrencesOfString:@"font-size:20px" withString:@"font-size:16px" options:0 range:NSMakeRange(0, [html length])];
        
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        if (html.length > 0)
            [webView loadHTMLString:html baseURL:baseURL];
    }
}

@end
