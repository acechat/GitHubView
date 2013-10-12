//
//  AccountViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 27/09/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AccountViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSMutableDictionary *userDetails;
@property (nonatomic, retain) UIImage *avatarImage;

@property (nonatomic, retain) NSString *userToView;

@property (nonatomic, retain) NSArray *titleOfCell;
@property (nonatomic, retain) NSMutableArray *repoList;

@end
