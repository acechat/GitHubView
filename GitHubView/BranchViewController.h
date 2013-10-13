//
//  BranchViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 13/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BranchViewController : UITableViewController

@property (nonatomic, retain) NSString *repoOwnerString;
@property (nonatomic, retain) NSString *repoNameString;
@property (nonatomic, retain) NSString *branchNameString;
@property (nonatomic, retain) NSString *treesPath;

@property (nonatomic, retain) NSArray *fileList;
@property (nonatomic, retain) NSArray *commitList;

@property (nonatomic, assign) NSInteger viewMode; // File or Commit

@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;

@end
