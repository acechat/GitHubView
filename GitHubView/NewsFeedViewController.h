//
//  NewsFeedViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 19/09/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsFeedChannel.h"

@interface NewsFeedViewController : UITableViewController <NSXMLParserDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) NewsFeedChannel *feedChannel;
@property (nonatomic, retain) NSMutableArray *feedPosts;
@property (nonatomic, retain) NSMutableDictionary *userIconDictionary;

@property (nonatomic, retain) id currentElement;
@property (nonatomic, retain) NSMutableString *currentElementData;


- (void)feedChanged:(NSNotification *)notification;

@end
