//
//  AccountViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 27/09/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UITableViewController

@property (nonatomic, retain) NSMutableDictionary *userDetails;
@property (nonatomic, retain) UIImage *avatarImage;

@property (nonatomic, retain) NSString *userToView;

@end
