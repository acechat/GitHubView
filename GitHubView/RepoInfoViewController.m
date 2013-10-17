//
//  RepoInfoViewController.m
//  GitHubView
//
//  Created by Sungju Kwon on 11/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "RepoInfoViewController.h"
#import "ConfigHelper.h"
#import "AFNetworking.h"
#import "HelperTools.h"
#import "AccountViewController.h"
#import "WebViewController.h"
#import "BranchViewController.h"

@interface RepoInfoViewController ()

@end

@implementation RepoInfoViewController

@synthesize repoInfo;
@synthesize repoURLString;
@synthesize titleOfCell;
@synthesize branches;
@synthesize branchHashList;
@synthesize branchNameList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)changeStarring:(id)sender
{
    UIBarButtonItem *button = sender;
    
    UIColor *currentColor = button.tintColor;
    if (currentColor == [UIColor grayColor]) {
        [button setTintColor:[UIColor redColor]];
    } else {
        [button setTintColor:[UIColor grayColor]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Repo Info";
    
    UIImage *starImage = [UIImage imageNamed:@"unstar.png"];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:starImage style:UIBarButtonItemStyleBordered target:self action:@selector(changeStarring:)];

    [rightButton setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating News Feed"];
    [refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.branches = [[NSMutableArray alloc] initWithCapacity:10];
    self.branchNameList = [[NSMutableArray alloc] initWithCapacity:10];
    self.branchHashList = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSArray *firstSection = [[NSArray alloc] initWithObjects:@"name", @"description", @"owner", nil];
    NSArray *secondSection = [[NSArray alloc] initWithObjects:@"html_url", @"homepage", @"created_at", @"pushed_at", @"watchers", @"size", nil];
    self.titleOfCell = [[NSArray alloc] initWithObjects:firstSection, secondSection, nil];
    
    [self pullToRefresh];
}

- (void) pullToRefresh
{
    [self refreshRepoInfo];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 2) {
        return [self.branches count];
    }
    
    NSArray *data = [self.titleOfCell objectAtIndex:section];
    return [data count];
}

- (NSString *)titleOfCellAtRow:(int)row InSection:(int)section
{
    if (section == 2) {
        return [HelperTools getStringAt:row From:self.branchNameList];
    }
    
    NSArray *data = [self.titleOfCell objectAtIndex:section];
    
    return [data objectAtIndex:row];
}

- (NSString *)shortDateString:(NSDate *)origDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *theDate = [dateFormat stringFromDate:origDate];
    
    return theDate;
}

-(NSString *)dateDiff:(NSString *)origDate {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *convertedDate = [df dateFromString:origDate];
    
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    NSString *result = @"";
    if(ti < 1) {
        result = origDate;
    } else if (ti < 60) {
        result = @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        result = [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        result = [NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        result = [NSString stringWithFormat:@"%d days ago", diff];
    } else {
        result = [NSString stringWithFormat:@"%@", [self shortDateString:convertedDate]];
    }
    return result;
}

- (NSString *)dataOfCellAtRow:(int)row InSection:(int)section
{
    NSString *data = nil;
    NSString *title = [self titleOfCellAtRow:row InSection:section];
    
    if (section == 1) {
        if (row == 0) {
            data = [HelperTools getStringFor:title From:self.repoInfo];
        } else if (row == 2 || row == 3) {
            data = [self dateDiff:[repoInfo objectForKey:[self titleOfCellAtRow:row InSection:section]]];
        } else if (row == 4) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            
            data = [NSString stringWithFormat:@"%@ Users  ", [formatter stringFromNumber:[NSNumber numberWithInt:[[repoInfo objectForKey:[self titleOfCellAtRow:row InSection:section]] intValue]]]];
        } else if (row == 5) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            
            data = [NSString stringWithFormat:@"%@ Bytes  ", [formatter stringFromNumber:[NSNumber numberWithInt:[[repoInfo objectForKey:[self titleOfCellAtRow:row InSection:section]] intValue]]]];
        } else {
            data = [repoInfo objectForKey:[self titleOfCellAtRow:row InSection:section]];
        }
    } else if (section == 2) {
        data = [self.branchHashList objectAtIndex:row];
    } else {
        if (row == 2)
            data = [HelperTools getStringFor:@"login" From:[self.repoInfo valueForKey:title]];
        else
            data = [repoInfo objectForKey:title];
    }
    if (data == nil || [data isKindOfClass:[NSNull class]])
        data = @"";
    
    return data;
}

- (NSString *)changeUnderscore:(NSString *)data
{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [str appendString:data];
    [str replaceOccurrencesOfString:@"_" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [str length])];
    
    return str;
}

#define BRANCH_SECTION  2

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RepoInfoCell";
    static NSString *BranchCellIdentifier = @"RepoInfoBranchCell";
    long section = indexPath.section;
    long row = indexPath.row;
    
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:
            (section == BRANCH_SECTION) ? BranchCellIdentifier : CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(section == BRANCH_SECTION) ? UITableViewCellStyleDefault : UITableViewCellStyleValue2
                                      reuseIdentifier:(section == BRANCH_SECTION) ? BranchCellIdentifier : CellIdentifier];
    }
    
    // Configure the cell...
    
    if (section == BRANCH_SECTION) { // Branches
        cell.textLabel.text = [self titleOfCellAtRow:row InSection:section];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = [self changeUnderscore:[self titleOfCellAtRow:row InSection:section]];
        cell.detailTextLabel.text = [self dataOfCellAtRow:row InSection:section];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (cell.detailTextLabel.text.length > 0) {
            if ((section == 0 && row == 2) || ((section == 1 && (row == 0 || row == 1)))) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"Basic";
        case 1: return @"Details";
        case 2: return @"Branches";
    }
    return @"";
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
    long section = indexPath.section;
    long row = indexPath.row;
    
    if (section == 0 && row == 2) { // Selected owner info
        NSString *user = [HelperTools getStringFor:@"login" From:[self.repoInfo valueForKey:@"owner"]];
        if (user != nil && user.length > 0) {
            AccountViewController *userDetailViewController = [[AccountViewController alloc]
                                                                  initWithNibName:@"AccountViewController" bundle:nil];
            
            userDetailViewController.userToView = user;
            
            [self.navigationController pushViewController:userDetailViewController animated:YES];
        }
    } else if (section == 1) { // Details
        if (row == 0 || row == 1) { // Repo URL or HomePage
            NSString *url = [self dataOfCellAtRow:row InSection:section];
            if (url != nil && url.length > 0) {
                WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
                webViewController.webURLString = url;
                [self.navigationController pushViewController:webViewController animated:YES];
            }
        }
    } else if (section == 2) { // Branches
        NSString *repoOwner = [HelperTools getStringFor:@"login" From:[self.repoInfo valueForKey:@"owner"]];
        NSString *repoName = [HelperTools getStringFor:@"name" From:self.repoInfo];
        NSString *branchName = [self titleOfCellAtRow:row InSection:section];
        NSString *treeHash = [NSString stringWithFormat:@"/%@", self.branchHashList[row]];
        NSString *treesPath = [[HelperTools getStringFor:@"trees_url" From:self.repoInfo] stringByReplacingOccurrencesOfString:@"{/sha}" withString:treeHash];
        
        BranchViewController *branchViewController = [[BranchViewController alloc] initWithNibName:@"BranchViewController" bundle:nil];

        branchViewController.repoOwnerString = repoOwner;
        branchViewController.repoNameString = repoName;
        branchViewController.branchNameString = branchName;
        branchViewController.treesPath = treesPath;
        [self.navigationController pushViewController:branchViewController animated:YES];
    }
}

#pragma mark - Fetching Repo Info

- (void)startNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)stopNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)refreshRepoInfo
{
    NSDictionary *profileList = [ConfigHelper loadUserProfile];
    NSString *selectedUserID = [ConfigHelper loadSelectedUserID];
    NSDictionary *userProfile = [profileList valueForKey:selectedUserID];
    NSString *user_id = [userProfile valueForKey:@"user_id"];
    NSString *password = [userProfile valueForKey:@"password"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user_id, password];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [HelperTools AFBase64EncodedStringFromString:basicAuthCredentials]] forHTTPHeaderField:@"Authorization"];
    
    [self startNetworkIndicator];
    [manager GET:self.repoURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"REPOINFO : %@", JSON);
        self.repoInfo = JSON;
        [self getCheckStatus];
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

    [manager GET:[NSString stringWithFormat:@"%@/branches", repoURLString] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"BRANCHES : %@", JSON);        
        NSMutableArray *branchList = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in JSON) {
            [branchList addObject:dic];
        }
        BOOL reverseSort = NO;
        self.branches = [[branchList sortedArrayUsingFunction:alphabeticBranchSort context:&reverseSort] mutableCopy];
        
        [self.branchHashList removeAllObjects];
        [self.branchNameList removeAllObjects];
        
        NSMutableDictionary *data;
        for (int i = 0; i < self.branches.count; i++) {
            data = self.branches[i];
            [self.branchNameList addObject:[data valueForKey:@"name"]];
            [self.branchHashList addObject:[[data valueForKey:@"commit"] valueForKey:@"sha"]];
        }
        
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


- (void) getCheckStatus
{
    NSString *hostAddr = @"https://api.github.com";
    NSString *path = nil;
    
    NSDictionary *profileList = [ConfigHelper loadUserProfile];
    NSString *selectedUserID = [ConfigHelper loadSelectedUserID];
    NSDictionary *userProfile = [profileList valueForKey:selectedUserID];
    NSString *user_id = [userProfile valueForKey:@"user_id"];
    NSString *password = [userProfile valueForKey:@"password"];
    
    NSString *repoOwner = [self.repoInfo valueForKey:@"owner"];
    NSString *repoName = [self.repoInfo valueForKey:@"name"];
    
    path = [NSString stringWithFormat:@"/user/starred/%@/%@", repoOwner, repoName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user_id, password];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [HelperTools AFBase64EncodedStringFromString:basicAuthCredentials]] forHTTPHeaderField:@"Authorization"];
    
    [self startNetworkIndicator];
    [manager GET:[NSString stringWithFormat:@"%@%@", hostAddr, path] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"STARRRED : %@", JSON);
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

/*
- (void) saveCheckStatus
{
    NSString *hostAddr = @"https://api.github.com";
    NSString *path = nil;
    
    path = [NSString stringWithFormat:@"/user/starred/%@/%@", self.ownerName, self.repoName];
    
    NSDictionary *profileList = [ConfigHelper loadUserProfile];
    NSString *selectedUserID = [ConfigHelper loadSelectedUserID];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", hostAddr, path]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *userProfile = [profileList valueForKey:selectedUserID];
    [httpClient setAuthorizationHeaderWithUsername:[userProfile valueForKey:@"user_id"] password:[userProfile valueForKey:@"password"]];
    
    NSURLRequest *request = [httpClient requestWithMethod:(self.isChecked ? @"PUT" : @"DELETE") path:path parameters:nil];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self setTopTitle];
        [self stopLoading];
        self.isChecked = !self.isChecked;
        self.checkImage.hidden = !self.isChecked;
    }];
    
    [operation start];
}
 */

@end
