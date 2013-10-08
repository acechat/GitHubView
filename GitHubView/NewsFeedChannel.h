//
//  NewsFeedChannel.h
//  GitHubView
//
//  Created by Sungju Kwon on 8/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsFeedChannel : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *description;

@end
