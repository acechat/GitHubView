//
//  RepoInfoViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 11/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepoInfoViewController : UITableViewController

@property (nonatomic, retain) NSDictionary *repoInfo;
@property (nonatomic, retain) NSString *repoURLString;

@property (nonatomic, retain) NSArray *titleOfCell;

@property (nonatomic, retain) NSMutableArray *branches;
@property (nonatomic, retain) NSMutableArray *branchNameList;
@property (nonatomic, retain) NSMutableArray *branchHashList;
@end
