//
//  ConfigHelper.m
//  GitHubView
//
//  Created by Sungju Kwon on 2/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "ConfigHelper.h"
#import "AppDelegate.h"

@implementation ConfigHelper

+ (NSDictionary *)loadUserProfile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *profile_list = [defaults valueForKey:@"profile_list"];
    if (profile_list == nil)
        profile_list = [[NSMutableDictionary alloc] init];
    
    return profile_list;
}

+ (NSString *)loadSelectedUserID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedUserID = [defaults valueForKey:@"user_id"];
    
    return selectedUserID;
}

+ (void)saveUserProfile:(NSDictionary *)profileList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:profileList forKey:@"profile_list"];
    
    [defaults synchronize];
}

+ (void)saveSelectedUserID:(NSString *)userID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:userID forKey:@"user_id"];
    
    [defaults synchronize];
}

+ (NSString *)getCurrentTheme
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    NSNumber *themeNumber = [app.appConfiguration objectForKey:@"theme_index"];
    int themeIndex = [themeNumber intValue];

    return [app.themeList[themeIndex] valueForKey:@"path"];
}

@end
