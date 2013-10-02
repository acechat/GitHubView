//
//  ConfigHelper.h
//  GitHubView
//
//  Created by Sungju Kwon on 2/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigHelper : NSObject

+ (NSDictionary *)loadUserProfile;
+ (void)saveUserProfile:(NSDictionary *)profileList;
+ (NSString *)loadSelectedUserID;
+ (void)saveSelectedUserID:(NSString *)userID;

@end
