//
//  WebViewController.m
//  GitHubView
//
//  Created by Sungju Kwon on 12/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "WebViewController.h"
#import "AFNetworking.h"
#import "ConfigHelper.h"
#import "HelperTools.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize webURLString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadURL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self buttonCheckForGo];
}

- (void)loadURL
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.webURLString]];
    
    if ([urlRequest.URL.host hasSuffix:@"github.com"]) {
        NSString *hostAddr = @"https://api.github.com/authorizations";
        
        NSDictionary *profileList = [ConfigHelper loadUserProfile];
        NSString *selectedUserID = [ConfigHelper loadSelectedUserID];
        NSDictionary *userProfile = [profileList valueForKey:selectedUserID];
        NSString *user_id = [userProfile valueForKey:@"user_id"];
        NSString *password = [userProfile valueForKey:@"password"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user_id, password];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [HelperTools AFBase64EncodedStringFromString:basicAuthCredentials]] forHTTPHeaderField:@"Authorization"];
        
        [manager GET:hostAddr parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
#ifdef DEBUG
            NSLog(@"Authorization: %@", JSON);
#endif
            NSString *authToken = nil;
            for (NSDictionary *entry in JSON) {
                NSArray *scopes = [entry valueForKey:@"scopes"];
                if (scopes.count > 0) {
                    authToken = [entry valueForKey:@"token"];
                    break;
                }
            }
            if (authToken != nil && authToken.length > 0) {
                [urlRequest addValue:[NSString stringWithFormat:@"token %@", authToken] forHTTPHeaderField:@"Authorization"];
            }
            [self.webView loadRequest:urlRequest];
#ifdef DEBUG
            NSLog(@"html: %@", [self.webView stringByEvaluatingJavaScriptFromString:
                                 @"document.getElementsByTagName('html')[0].outerHTML"]);
#endif
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.webView loadRequest:urlRequest];
        }];
    } else {
        [self.webView loadRequest:urlRequest];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    [self.webView goBack];
}

- (IBAction)goForward:(id)sender {
    [self.webView goForward];
}

- (IBAction)reloadURL:(id)sender {
    [self.webView stopLoading];
    [self.webView reload];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Sent email" delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
        
        // Create the perform selector method with alert view object and time-period
        [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:0.7];
    }
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}

// Dismiss the alert view after time-Period
-(void)dismissAlertView:(UIAlertView *)alert
{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
    
}

- (void)emailLink
{
    NSString *bodyText = [NSString stringWithFormat:@"%@ - %@",
                          self.navigationItem.title,
                          self.webView.request.URL.absoluteString];
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObjects:nil]];
    [controller setSubject:@"Check this link"];
    [controller setMessageBody:bodyText isHTML:NO];
    if (controller)
        [self presentViewController:controller animated:YES completion:^{
        }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: // Open in safari
            [[UIApplication sharedApplication] openURL:[self.webView.request URL]];
            break;
        case 1: // e-mail this link
            [self emailLink];
            break;
            
    }
}

- (IBAction)doBrowseAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:self.webView.request.URL.absoluteString
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Open in Safari", @"e-mail this link", nil];
    [actionSheet showInView:self.view];
}

- (void)buttonCheckForGo
{
    self.goBackButton.enabled = self.webView.canGoBack;
    self.goForwardButton.enabled = self.webView.canGoForward;
    self.reloadURLButton.enabled = !self.webView.loading;
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.navigationItem.title = @"Loading...";
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) webViewDidFinishLoad:(UIWebView *) webView {
    self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self buttonCheckForGo];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self buttonCheckForGo];
    
    if ([error code] != NSURLErrorCancelled) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Failed to load a web page."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil];
        [alertView show];
        self.navigationItem.title = @"ERROR";
    }
}


@end
