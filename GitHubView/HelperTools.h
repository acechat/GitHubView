//
//  HelperTools.h
//  GitHubView
//
//  Created by Sungju Kwon on 10/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelperTools : NSObject

+ (NSString *)AFBase64EncodedStringFromString:(NSString *)string;
+ (NSString *)getStringFor:(NSString *)key From:(NSDictionary *)dictonary;
+ (NSString *)getStringAt:(int)index From:(NSArray *)array;

NSInteger alphabeticBranchSort(id branch1, id branch2, void *reverse);


@end
