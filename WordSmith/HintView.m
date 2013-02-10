//
//  HintView.m
//  WordSmith
//
//  Created by Joseph Constan on 2/24/12.
//  Copyright (c) 2012 Codevs, Inc. All rights reserved.
//

#import "HintView.h"

@implementation HintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code

    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    hints = [[NSMutableArray alloc] initWithCapacity:5];
    self.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:13.0];
}

- (void)loadHintsForWord:(NSString *)word {
    [hints removeAllObjects];
    
    //Add definition as hint:
    NSString *def = [self definitionForWord:word];
    if (def.length > 0)
        [hints addObject:def];
    else 
        [hints addObject:@"No Definition Available"];
    
    //Build and add synonym string as hint:
    NSArray *syns = [self synonymsForWord:word];
    if (syns.count > 0) {
        NSMutableString *synString = [NSMutableString stringWithFormat:@"Synonyms: %@", [syns objectAtIndex:0]];
        for (int i = 1; i < syns.count; i++) {
            
            [synString appendFormat:@", %@", [syns objectAtIndex:i]];
        }
        [hints addObject:synString];
    } else
        [hints addObject:@"No Synonyms Available"];
    
    //Add 3-letter prefix as hint:
    NSMutableString *prefix = [word mutableCopy];
    [prefix deleteCharactersInRange:NSMakeRange(3, word.length - 3)];
    [hints addObject:[NSString stringWithFormat:@"Prefix: %@-", prefix]];
    
    //Load all hints into the text view
    self.contentSize = CGSizeMake(self.frame.size.width * (hints.count+1), self.frame.size.height);
    self.text = @"";
    for (int i = 0; i < hints.count; i++) {
        self.text = [NSString stringWithFormat:@"%@%d. %@\n", self.text, i+1, [hints objectAtIndex:i]];
    }
}

- (NSString *)definitionForWord:(NSString *)word {
    Lexicontext *lex = [Lexicontext sharedDictionary];
    
    //show definition as hint:
    NSDictionary *def = [lex definitionAsDictionaryFor:word];
    NSUInteger len = 10000;
    NSString *hint = @"";
    for (id key in def) {
        NSArray *arr = [def objectForKey:key];
        
        for (NSString *imstr in arr) {
            NSMutableString *str = [imstr mutableCopy];
            // ignore hints that contain the word
            if ([str rangeOfString:word].location != NSNotFound)
                continue;
            // remove example sentences
            NSRange quoteRange = [str rangeOfString:@"\""];
            if (quoteRange.location != NSNotFound) {
                [str deleteCharactersInRange:NSMakeRange(quoteRange.location, str.length-quoteRange.location)];
            }
            //find shortest string
            if (str.length < len) {
                hint = str;
                len = str.length;
            }
        }
    }
    return hint;
}

- (NSArray *)synonymsForWord:(NSString *)word {
    Lexicontext *lex = [Lexicontext sharedDictionary];
    
    //show definition as hint:
    NSDictionary *thes = [lex thesaurusFor:word];
    NSMutableArray *syns = [NSMutableArray arrayWithCapacity:3];
    for (id key in thes) {
        NSArray *topArr = [thes objectForKey:key];
        for (NSArray *arr in topArr) {
            for (NSString *syn in arr) {
                if ([syn rangeOfString:word].location == NSNotFound)
                    [syns addObject:syn];
                if (syns.count >= 3)
                    return syns;
            }
        }
    }
    return syns;
}

@end
