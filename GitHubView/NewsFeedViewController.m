//
//  NewsFeedViewController.m
//  GitHubView
//
//  Created by Sungju Kwon on 19/09/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "NewsFeedViewController.h"
#import "PKRevealController.h"
#import "ConfigHelper.h"
#import "AFNetworking.h"
#import "NewsFeedChannel.h"
#import "NewsFeedPost.h"
#import "HelperTools.h"

#define kFeederReloadCompletedNotification  @"feedChanged"

#define kFeedElementName @"feed"
#define kItemElementName @"entry"

@interface NewsFeedViewController ()

@end

@implementation NewsFeedViewController

@synthesize webView;
@synthesize feedChannel;
@synthesize feedPosts;
@synthesize userIconDictionary;
@synthesize currentElement;
@synthesize currentElementData;

- (void)showLeftMenu:(id)sender
{
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController)
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedChanged:) name:kFeederReloadCompletedNotification object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *revealImagePortrait = [UIImage imageNamed:@"reveal_menu_icon_portrait"];
    UIImage *revealImageLandscape = [UIImage imageNamed:@"reveal_menu_icon_landscape"];
    
    if (self.navigationController.revealController.type & PKRevealControllerTypeLeft)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:revealImageLandscape style:UIBarButtonItemStylePlain target:self action:@selector(showLeftMenu:)];
    }
    self.title = @"News Feed";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating News Feed"];
    [refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    self.feedPosts = [[NSMutableArray alloc] init];
    self.userIconDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    [self pullToRefresh];
}

- (void) pullToRefresh
{
    [self refreshNewsFeed];
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:2];
}

- (void)updateTable
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.feedPosts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NewsFeedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NewsFeedPost *post = self.feedPosts[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", post.name, post.content];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

#pragma mark - Fetching News Feed

- (void)startNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)stopNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)refreshNewsFeed
{
    NSString *hostAddr = @"https://github.com";
    NSString *path = nil;
    
    NSDictionary *profileList = [ConfigHelper loadUserProfile];
    NSString *selectedUserID = [ConfigHelper loadSelectedUserID];
    NSDictionary *userProfile = [profileList valueForKey:selectedUserID];
    NSString *user_id = [userProfile valueForKey:@"user_id"];
    NSString *password = [userProfile valueForKey:@"password"];
    
    path = [NSString stringWithFormat:@"/%@.private.atom", selectedUserID];

    //NSURLCredential *credential = [NSURLCredential credentialWithUser:[userProfile valueForKey:@"user_id"] password:[userProfile valueForKey:@"password"] persistence:NSURLCredentialPersistenceForSession];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager setCredential:credential];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user_id, password];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [HelperTools AFBase64EncodedStringFromString:basicAuthCredentials]] forHTTPHeaderField:@"Authorization"];
    
    NSSet *mySet = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", @"application/atom+xml", nil];
    manager.responseSerializer.acceptableContentTypes = mySet; // Adding custom content-type is not working so far.

    [self startNetworkIndicator];
    [manager GET:[NSString stringWithFormat:@"%@%@", hostAddr, path] parameters:nil success:^(AFHTTPRequestOperation *operation, NSXMLParser *XMLParser) {
        [self performSelectorOnMainThread:@selector(parseXMLNewsFeed:)
                               withObject:XMLParser
                            waitUntilDone:NO];
        [self stopNetworkIndicator];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorMessage = error.localizedDescription;
        [self stopNetworkIndicator];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}


- (void)parseXMLNewsFeed:(NSXMLParser *)xmlParser
{
    [feedPosts removeAllObjects];
    
    xmlParser.delegate = self;
    
    if ([xmlParser parse]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFeederReloadCompletedNotification object:nil];
    } else {
        NSString *errorMessage = @"Parsing failed";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:kFeedElementName]) {
        NewsFeedChannel *channel = [[NewsFeedChannel alloc] init];
        self.feedChannel = channel;
        self.currentElement = channel;
        return;
    }
    
    if ([elementName isEqualToString:kItemElementName]) {
        NewsFeedPost *post = [[NewsFeedPost alloc] init];
        [feedPosts addObject:post];
        self.currentElement = post;
        return;
    }
    
    if ([elementName isEqualToString:@"media:thumbnail"]) {
        [currentElement setValue:[attributeDict objectForKey:@"url"] forKey:@"media"];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (currentElementData == nil) {
        self.currentElementData = [[NSMutableString alloc] init];
    }
    
    [currentElementData appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    SEL selectorName = NSSelectorFromString(elementName);
    if ([currentElement respondsToSelector:selectorName]) {
        [currentElement setValue:currentElementData forKey:elementName];
    }
    
    self.currentElementData = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"ERR: %@", parseError);
}

- (void)feedChanged:(NSNotification *)notification {
    [self.tableView reloadData];
    /*
    NSMutableString *htmlBody = [[NSMutableString alloc] init];
    
    [htmlBody appendString:@"<html><head>\
     <meta name='viewport' content='width=device-width; initial-scale=0.9; maximum-scale=0.9;'>\
     <link rel='stylesheet' href='iphone.css' />\
     <script type='text/javascript' charset='utf-8'>\
     window.onload = function() {\
     setTimeout(function(){window.scrollTo(0, 1);}, 100);\
     }\
     </script></head>\
     <body><div id='content'><table cellspacing=0 cellpading=0 class='nomargintable'>"];
    
    int count = 0;
    
    for (NewsFeedPost *feedPost in feedPosts) {
        NSMutableString *msg = [[NSMutableString alloc] init];
        [msg appendString:feedPost.content];
        
        if (msg != nil) {
            [[[[[msg stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;amp;"]
                stringByReplacingOccurrencesOfString: @"\"" withString: @"&amp;quot;"]
               stringByReplacingOccurrencesOfString: @"'" withString: @"&amp;#39;"]
              stringByReplacingOccurrencesOfString: @">" withString: @"&amp;gt;"]
             stringByReplacingOccurrencesOfString: @"<" withString: @"&amp;lt;"];
        } else {
            msg = [[NSMutableString alloc] initWithString:@""];
        }
        
        NSMutableString *name = [[NSMutableString alloc] init];
        [name appendString:feedPost.name];
        
        if (name != nil) {
            [[[[[name stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;amp;"]
                stringByReplacingOccurrencesOfString: @"\"" withString: @"&amp;quot;"]
               stringByReplacingOccurrencesOfString: @"'" withString: @"&amp;#39;"]
              stringByReplacingOccurrencesOfString: @">" withString: @"&amp;gt;"]
             stringByReplacingOccurrencesOfString: @"<" withString: @"&amp;lt;"];
        } else {
            name = [[NSMutableString alloc] initWithString:@""];
        }

        [htmlBody appendFormat:@"<tr><td colspan=2>%@</td></tr><tr valign='top'><td><b>%@</b><br/>%@</td></tr>",
         count != 0 ? @"<hr>": @"", feedPost.title, msg];
        
        msg = nil;
        name = nil;
        
        count++;
    }
    
    [htmlBody appendString:@"</table></div></body></html>"];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.webView loadHTMLString:htmlBody baseURL:baseURL];
     */
}

@end
