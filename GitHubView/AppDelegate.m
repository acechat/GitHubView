//
//  AppDelegate.m
//  GitHubView
//
//  Created by Sungju Kwon on 19/09/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "AppDelegate.h"
#import "PKRevealController.h"
#import "LeftMenuViewController.h"
#import "NewsFeedViewController.h"
#import "StarsViewController.h"
#import "IssuesViewController.h"
#import "RepositoryViewController.h"
#import "UsersViewController.h"
#import "AccountViewController.h"
#import "SettingsViewController.h"

@implementation AppDelegate

@synthesize revealController;
@synthesize leftMenuController;

@synthesize menuTextList;
@synthesize menuControllerList;


@synthesize appConfiguration;
@synthesize themeList;

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"config.plist"];
}

- (void)saveConfig
{
    [self.appConfiguration writeToFile:[self dataFilePath] atomically:YES];
}

- (void)loadConfig
{
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        appConfiguration = [[NSMutableDictionary alloc] initWithContentsOfFile:[self dataFilePath]];
    } else {
        appConfiguration = [[NSMutableDictionary alloc] init];
        [appConfiguration writeToFile:filePath atomically:YES];
    }
}

- (BOOL)getStatusBarStatus
{
    NSMutableDictionary *data = [self.appConfiguration objectForKey:@"screen"];
    if (data == nil) return YES; // Show status bar
    
    NSNumber *statusBar = [data objectForKey:@"statusbar"];
    BOOL statusBarValue;
    
    if (statusBar == nil)
        statusBarValue = YES;
    else
        statusBarValue = [statusBar boolValue];
    
    return statusBarValue;
}

- (NSString *)getUsername
{
    NSMutableDictionary *userinfo = [self.appConfiguration objectForKey:@"login"];
    if (userinfo == nil) return @"";
    
    NSString *username = [userinfo objectForKey:@"username"];
    return username == nil ? @"" : username;
}

- (NSString *)getPassword
{
    NSMutableDictionary *userinfo = [self.appConfiguration objectForKey:@"login"];
    if (userinfo == nil) return @"";
    
    NSString *password = [userinfo objectForKey:@"password"];
    return password == nil ? @"" : password;
}

- (void)setThemeList
{
    NSDictionary *desert = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"Black", @"desc",
                            @"desert.css", @"path",
                            nil];
    NSDictionary *prettify = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"Clean", @"desc",
                              @"prettify.css", @"path",
                              nil];
    NSDictionary *sons = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Darker", @"desc",
                          @"sons.css", @"path",
                          nil];
    
    self.themeList = [[NSMutableArray alloc] initWithObjects:prettify, desert, sons, nil];
}

- (int)getThemeIndex
{
    NSNumber *number = [self.appConfiguration objectForKey:@"theme_index"];
    int themeIndex = [number intValue];
    
    if (themeIndex < 0) themeIndex = 0;
    
    if (themeIndex >= [self.themeList count])
        themeIndex = [self.themeList count] - 1;
    
    return themeIndex;
}

- (NSString *)getThemeFilename:(int)index
{
    return [[self.themeList objectAtIndex:index] objectForKey:@"path"];
}

- (NSString *)getCurrentTheme
{
    NSString *themePath = [self getThemeFilename:[self getThemeIndex]];
    if (themePath == nil)
        themePath = @"prettify.css";
    return themePath;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [self loadConfig];
    [self setThemeList];
    
    NSMutableArray *githubMenuTextList = [[NSMutableArray alloc] init];
    NSMutableArray *githubMenuControllerList = [[NSMutableArray alloc] init];
    
    NSMutableArray *accountMenuTextList = [[NSMutableArray alloc] init];
    NSMutableArray *accountMenuControllerList = [[NSMutableArray alloc] init];
    
    self.menuTextList = [[NSMutableArray alloc] initWithCapacity:2];
    self.menuControllerList = [[NSMutableArray alloc] initWithCapacity:2];
    self.menuHeaderList = [[NSMutableArray alloc] initWithCapacity:2];
    
    [githubMenuTextList addObject:@"News Feed"];
    [githubMenuControllerList addObject:[[UINavigationController alloc] initWithRootViewController:[[NewsFeedViewController alloc] init]]];
    
    [githubMenuTextList addObject:@"Stars"];
    [githubMenuControllerList addObject:[[UINavigationController alloc] initWithRootViewController:[[StarsViewController alloc] init]]];
    
    [githubMenuTextList addObject:@"Issues"];
    [githubMenuControllerList addObject:[[UINavigationController alloc] initWithRootViewController:[[IssuesViewController alloc] init]]];
    
    [githubMenuTextList addObject:@"Repository"];
    [githubMenuControllerList addObject:[[UINavigationController alloc] initWithRootViewController:[[RepositoryViewController alloc] init]]];
    
    [githubMenuTextList addObject:@"Users"];
    [githubMenuControllerList addObject:[[UINavigationController alloc] initWithRootViewController:[[UsersViewController alloc] init]]];
    
    [accountMenuTextList addObject:@"Account"];
    [accountMenuControllerList addObject:[[UINavigationController alloc]
                                   initWithRootViewController:[[AccountViewController alloc] init]]];
    
    [accountMenuTextList addObject:@"Settings"];
    [accountMenuControllerList addObject:[[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]]];

    
    [self.menuHeaderList addObject:@"GitHubView"];
    [self.menuTextList addObject:githubMenuTextList];
    [self.menuControllerList addObject:githubMenuControllerList];
    
    [self.menuHeaderList addObject:@"Account"];
    [self.menuTextList addObject:accountMenuTextList];
    [self.menuControllerList addObject:accountMenuControllerList];
    
    self.leftMenuController = [[LeftMenuViewController alloc] init];
    
    self.leftMenuController.menuHeaderList = self.menuHeaderList;
    self.leftMenuController.menuTextList = self.menuTextList;
    self.leftMenuController.menuControllerList = self.menuControllerList;
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:self.menuControllerList[0][0] leftViewController:self.leftMenuController options:nil];
    
    self.window.rootViewController = self.revealController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
