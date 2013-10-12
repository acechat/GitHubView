//
//  WebViewController.m
//  GitHubView
//
//  Created by Sungju Kwon on 12/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "WebViewController.h"

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
}

- (void)loadURL
{
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.webURLString]];
    [self.webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
