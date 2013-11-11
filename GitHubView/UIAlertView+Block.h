//
//  UIAlertView+Block.h
//  GitHubView
//
//  Created by Sungju Kwon on 11/11/2013.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DismissBlock)(int buttonIndex);
typedef void (^CancelBlock)();


@interface UIAlertView (Block) <UIAlertViewDelegate>
+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message;

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle;

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                          onDismiss:(DismissBlock) dismissed
                           onCancel:(CancelBlock) cancelled;

@property (nonatomic, copy) DismissBlock dismissBlock;
@property (nonatomic, copy) CancelBlock cancelBlock;


@end
