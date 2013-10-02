//
//  SettingsViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 1/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, retain) NSMutableDictionary *screenInfo;
@property (nonatomic, retain) NSArray *aboutList;
@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, retain) UITapGestureRecognizer *singleTap;

@property (nonatomic, retain) NSArray *themeList;
@property (nonatomic, retain) NSIndexPath *themeLastIndexPath;
@property (assign) int themeIndex;

@property (nonatomic, retain) id delegate;
@property (nonatomic, assign) SEL selector;

- (void)saveConfig;
- (void)loadConfig;

@end
