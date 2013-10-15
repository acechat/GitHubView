//
//  FileContentViewController.m
//  GitHubView
//
//  Created by Sungju Kwon on 15/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "FileContentViewController.h"
#import "ConfigHelper.h"
#import "AFNetworking.h"
#import "HelperTools.h"

@interface FileContentViewController ()

@end

@implementation FileContentViewController

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
    [self loadFileContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetching File Content

- (void)startNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)stopNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL)isImageType:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF: // JPEG
        case 0x89: // PNG
        case 0x47: // GIF
        case 0x49: // TIFF
        case 0x4D: // TIFF
            return YES;
    }
    return NO;
}

- (void)updateContentView
{
    NSString *originalContent = [HelperTools getStringFor:@"content" From:self.fileInfo];
    NSData *decodedData = [HelperTools Base64DecodedDataFromString:originalContent];
    NSString *stringVersion = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    NSString *content = nil;
    
    if ([self isImageType:decodedData]) {
        content = [NSString stringWithFormat:@"<img src='data:%@;base64,%@'>", @"image", originalContent];
    } else {
        content = [NSString stringWithFormat:@"<div id='content'><pre class='prettyprint'>%@</pre></div>", stringVersion];
    }
    NSString *htmlBody = [NSString stringWithFormat:@"<html><head>\
                          <meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'>\
                          <link rel='stylesheet' href='iphone.css' />\
                          <script type='text/javascript' charset='utf-8'>\
                          window.onload = function() {\
                          setTimeout(function(){window.scrollTo(0, 1);}, 100);\
                          }\
                          </script>\
                          <link href='%@' type='text/css' rel='stylesheet' />\
                          <script type='text/javascript' src='prettify.js'></script>\
                          <script type='text/javascript' src='general.js'></script>\
                          </head>\
                          <body onload='prettyPrint()'>\
                          %@</body></html>", [ConfigHelper getCurrentTheme], content];

    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSLog(@"HTML : %@", htmlBody);
    [self.webView loadHTMLString:htmlBody baseURL:baseURL];
    self.title = self.fileName;
}

- (void)loadFileContent
{
    NSString *path = nil;
    
    NSDictionary *profileList = [ConfigHelper loadUserProfile];
    NSString *selectedUserID = [ConfigHelper loadSelectedUserID];
    NSDictionary *userProfile = [profileList valueForKey:selectedUserID];
    NSString *user_id = [userProfile valueForKey:@"user_id"];
    NSString *password = [userProfile valueForKey:@"password"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user_id, password];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [HelperTools AFBase64EncodedStringFromString:basicAuthCredentials]] forHTTPHeaderField:@"Authorization"];
    
    [self startNetworkIndicator];

    path = self.url;
    
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"FILE INFO : %@", JSON);
        self.fileInfo = JSON;
        [self updateContentView];
        [self stopNetworkIndicator];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorMessage = path; //error.localizedDescription;
        [self stopNetworkIndicator];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

@end
