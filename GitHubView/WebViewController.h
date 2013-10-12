//
//  WebViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 12/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, retain) NSString *webURLString;

@end
