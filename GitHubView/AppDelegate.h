//
//  AppDelegate.h
//  GitHubView
//
//  Created by Sungju Kwon on 19/09/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKRevealController.h"
#import "LeftMenuViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readwrite) PKRevealController *revealController;

@property (nonatomic, strong) LeftMenuViewController *leftMenuController;

@property (nonatomic, strong) NSMutableArray *menuTextList;
@property (nonatomic, strong) NSMutableArray *menuControllerList;
@property (nonatomic, strong) NSMutableArray *menuHeaderList;

@property (nonatomic, retain) NSMutableDictionary *appConfiguration;
@property (nonatomic, retain) NSMutableArray *themeList;

// Configuration
- (NSString *)dataFilePath;
- (void)saveConfig;
- (void)loadConfig;
- (BOOL)getStatusBarStatus;
- (NSString *)getUsername;
- (NSString *)getPassword;

- (void)setThemeList;
- (int)getThemeIndex;
- (NSString *)getThemeFilename:(int)index;
- (NSString *)getCurrentTheme;


@end
