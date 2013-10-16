//
//  CommitDetailViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 16/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommitDetailViewController : UITableViewController

@property (nonatomic, retain) NSDictionary *commitInfo;
@property (nonatomic, retain) NSMutableArray *committedFileList;

@property (nonatomic, retain) NSArray *titleOfCell;

@end
