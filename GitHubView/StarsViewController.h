//
//  StarsViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 1/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarsViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *starringList;
@property (nonatomic, retain) NSString *loginUserID;

@end
