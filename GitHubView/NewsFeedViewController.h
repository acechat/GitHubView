//
//  NewsFeedViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 19/09/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedViewController : UITableViewController


@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) NSString *loginUserID;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSMutableArray *feedPosts;
@property (nonatomic, retain) NSMutableDictionary *userIconDictionary;

@property (nonatomic, retain) id currentElement;
@property (nonatomic, retain) NSMutableString *currentElementData;


- (void)feedChanged:(NSNotification *)notification;

@end
