//
//  StarsViewController.m
//  GitHubView
//
//  Created by Sungju Kwon on 1/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "StarsViewController.h"
#import "PKRevealController.h"
#import "ConfigHelper.h"
#import "AFNetworking.h"
#import "HelperTools.h"
#import "RepoInfoViewController.h"
#import "UIAlertView+Block.h"

@interface StarsViewController ()

@end

@implementation StarsViewController

@synthesize starringList;


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
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *revealImagePortrait = [UIImage imageNamed:@"reveal_menu_icon_portrait"];
    UIImage *revealImageLandscape = [UIImage imageNamed:@"reveal_menu_icon_landscape"];
    
    if (self.navigationController.revealController.type & PKRevealControllerTypeLeft)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:revealImageLandscape style:UIBarButtonItemStylePlain target:self action:@selector(showLeftMenu:)];
    }
    self.title = @"Stars";

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating Starraing"];
    [refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.starringList = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self pullToRefresh];
}

- (void) pullToRefresh
{
    [self refreshStarring];
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
    return self.starringList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StarsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *star = self.starringList[indexPath.row];
    cell.textLabel.text = [HelperTools getStringFor:@"full_name" From:star];
    cell.detailTextLabel.text = [HelperTools getStringFor:@"description" From:star];
    
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

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    RepoInfoViewController *repoInfoViewController = [[RepoInfoViewController alloc] initWithNibName:@"RepoInfoViewController" bundle:nil];

    NSDictionary *repo = self.starringList[indexPath.row];
    repoInfoViewController.repoURLString = [HelperTools getStringFor:@"url" From:repo];
    
    // Push the view controller.
    [self.navigationController pushViewController:repoInfoViewController animated:YES];
}
 
#pragma mark - Fetching Starring

- (void)startNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)stopNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)refreshStarring
{
    NSString *hostAddr = @"https://api.github.com";
    NSString *path = @"/user/starred";
    
    NSDictionary *profileList = [ConfigHelper loadUserProfile];
    NSString *selectedUserID = [ConfigHelper loadSelectedUserID];
    NSDictionary *userProfile = [profileList valueForKey:selectedUserID];
    NSString *user_id = [userProfile valueForKey:@"user_id"];
    NSString *password = [userProfile valueForKey:@"password"];
    
    if (user_id == nil || user_id.length == 0 || password == nil || password.length == 0) {
        UIAlertView *alertView = [UIAlertView alertViewWithTitle:@"No login details"
                                                         message:@"Please set your login details in 'Settings' menu" cancelButtonTitle:@"Close" otherButtonTitles:nil onDismiss:nil onCancel:^{
                                                                     [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
                                                         }];
        
        [alertView show];

        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user_id, password];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [HelperTools AFBase64EncodedStringFromString:basicAuthCredentials]] forHTTPHeaderField:@"Authorization"];

    [self startNetworkIndicator];
    [manager GET:[NSString stringWithFormat:@"%@%@", hostAddr, path] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
#ifdef DEBUG
        NSLog(@"JSON: %@", JSON);
#endif
        [self.starringList removeAllObjects];
        [self.starringList addObjectsFromArray:JSON];
        [self.tableView reloadData];
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


@end
