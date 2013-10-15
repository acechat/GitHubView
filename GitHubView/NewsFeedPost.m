//
//  NewsFeedPost.m
//  GitHubView
//
//  Created by Sungju Kwon on 8/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "NewsFeedPost.h"

@implementation NewsFeedPost

@synthesize isRead;
@synthesize title;
@synthesize details;
@synthesize content = _content;
@synthesize updated;
@synthesize name = _name;
@synthesize media;
@synthesize image;

- (void)setName:(NSString *)name {
    _name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setContent:(NSString *)content {
    NSArray *components = [content componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    NSMutableArray *componentsToKeep = [NSMutableArray array];
    NSString *tmpString;
    for (int i = 0; i < [components count]; i = i + 2) {
        tmpString = [NSString stringWithFormat:@"%@", [[components objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        if (tmpString.length == 0) continue;
        [componentsToKeep addObject:tmpString];
    }
    
    NSString *plainText = [componentsToKeep componentsJoinedByString:@":"];

    _content = [plainText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
    NSRange range = [_content rangeOfString:@"/"];
    if (range.location > 0 && range.location < _content.length) {
        NSString *substring = [[_content substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        range = [substring rangeOfString:@":"];
        substring = [substring substringFromIndex:NSMaxRange(range)];
        self.details = substring;
    } else {
        self.details = componentsToKeep[componentsToKeep.count - 1];
    }
}

@end
