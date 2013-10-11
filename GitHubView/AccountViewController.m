//
//  AccountViewController.m
//  GitHubView
//
//  Created by Sungju Kwon on 27/09/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "AccountViewController.h"
#import "PKRevealController.h"
#import "AFNetworking.h"
#import "ConfigHelper.h"
#import "HelperTools.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

@synthesize userDetails;
@synthesize avatarImage;
@synthesize userToView = _userToView;

- (void)setUserToView:(NSString *)userToView
{
    _userToView = userToView;
    if (_userToView == nil)
        self.title = @"Account";
    else
        self.title = @"User details";
}

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
        self.userToView = nil;
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
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.userToView == nil) {
        UIImage *revealImagePortrait = [UIImage imageNamed:@"reveal_menu_icon_portrait"];
        UIImage *revealImageLandscape = [UIImage imageNamed:@"reveal_menu_icon_landscape"];
        
        if (self.navigationController.revealController.type & PKRevealControllerTypeLeft)
        {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:revealImageLandscape style:UIBarButtonItemStylePlain target:self action:@selector(showLeftMenu:)];
        }
    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating My details"];
    [refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.avatarImage = nil;
    
    [self pullToRefresh];
}

- (void) pullToRefresh
{
    [self refreshAccountDetails];
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:0];
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [self.userDetails valueForKey:@"login"];
            if (self.avatarImage == nil) {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^(void) {
                    self.avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.userDetails valueForKey:@"avatar_url"]]]];
                    if (self.avatarImage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (cell.tag == indexPath.row) {
                                cell.imageView.image = self.avatarImage;
                                [cell setNeedsLayout];
                            }
                        });
                    }
                });
            }
            cell.imageView.image = self.avatarImage;
            break;
        case 1:
            cell.textLabel.text = [HelperTools getStringFor:@"name" From:self.userDetails];
            break;
        case 2:
            cell.textLabel.text = [HelperTools getStringFor:@"company" From:self.userDetails];            break;
        case 3:
            cell.textLabel.text = [HelperTools getStringFor:@"email" From:self.userDetails];
            break;
        default:
            break;
    }
    
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
#pragma mark - Fetching User Details

- (void)startNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)stopNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)refreshAccountDetails
{
    NSString *hostAddr = @"https://api.github.com";
    NSString *path = nil;
    
    if (self.userToView == nil) {
        path = @"/user";
    } else {
        path = [NSString stringWithFormat:@"/users/%@", self.userToView];
    }
    
    NSDictionary *profileList = [ConfigHelper loadUserProfile];
    NSString *selectedUserID = [ConfigHelper loadSelectedUserID];
    NSDictionary *userProfile = [profileList valueForKey:selectedUserID];
    NSString *user_id = [userProfile valueForKey:@"user_id"];
    NSString *password = [userProfile valueForKey:@"password"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user_id, password];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [HelperTools AFBase64EncodedStringFromString:basicAuthCredentials]] forHTTPHeaderField:@"Authorization"];
    
    [self startNetworkIndicator];
    [manager GET:[NSString stringWithFormat:@"%@%@", hostAddr, path] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"JSON: %@", JSON);
        userDetails = JSON;
        [self.tableView reloadData];
        [self stopNetworkIndicator];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
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

@end
