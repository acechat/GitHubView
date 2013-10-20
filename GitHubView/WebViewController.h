//
//  WebViewController.h
//  GitHubView
//
//  Created by Sungju Kwon on 12/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, retain) NSString *webURLString;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *goBackButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goForwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadURLButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doActionButton;


- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)reloadURL:(id)sender;
- (IBAction)doBrowseAction:(id)sender;


@end
