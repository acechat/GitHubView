//
//  FileContentViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 15/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSDictionary *fileInfo;

@end
