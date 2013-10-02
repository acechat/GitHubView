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

/*
@property (nonatomic, strong) UINavigationController *newsFeedController;
@property (nonatomic, strong) UINavigationController *starsController;
@property (nonatomic, strong) UINavigationController *issuesController;
@property (nonatomic, strong) UINavigationController *repositoryController;
@property (nonatomic, strong) UINavigationController *usersController;
@property (nonatomic, strong) UINavigationController *accountViewController;
@property (nonatomic, strong) UINavigationController *settingsController;
 */

@end
