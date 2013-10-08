//
//  NewsFeedPost.h
//  GitHubView
//
//  Created by Sungju Kwon on 8/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsFeedPost : NSObject

@property (nonatomic, assign) BOOL isRead;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *updated;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *media;
@property (nonatomic, retain) UIImage *image;

@end
