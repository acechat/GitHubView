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
#import "WebViewController.h"
#import "RepoInfoViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

@synthesize userDetails;
@synthesize avatarImage;
@synthesize userToView = _userToView;
@synthesize repoList;
@synthesize titleOfCell;

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
    
    NSArray *firstSection = [[NSArray alloc] initWithObjects:@"login", @"name", @"email", @"company", @"location", @"blog", nil];
    NSArray *secondSection = [[NSArray alloc] initWithObjects:@"followers", @"following", @"created_at", @"updated_at", @"disk_usage", nil];
    self.titleOfCell = [[NSArray alloc] initWithObjects:firstSection, secondSection, nil];
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        case 1: return [self.titleOfCell[section] count];
        case 2: return [self.repoList count];
    }
    return 0;
}

- (NSString *)titleOfCellAtRow:(long)row InSection:(long)section
{
    if (section == 2) {
        NSDictionary *dic = [self.repoList objectAtIndex:row];
        return [dic objectForKey:@"name"];
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
    if(ti < 1) {
        return origDate;
    } else      if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
        return [NSString stringWithFormat:@"%@", [self shortDateString:convertedDate]];
    }
}

- (NSString *)dataOfCellAtRow:(long)row InSection:(long)section
{
    NSString *data = nil;
    if (section == 1) {
        if (row == 0 || row == 1) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            
            data = [NSString stringWithFormat:@"%@ Users", [formatter stringFromNumber:[NSNumber numberWithInt:[[self.userDetails objectForKey:[self titleOfCellAtRow:row InSection:section]] intValue]]]];
        } else if (row == 2 || row == 3) {
            data = [NSString stringWithFormat:@"%@", [self dateDiff:[self.userDetails objectForKey:[self titleOfCellAtRow:row InSection:section]]]];
        } else if (row == 4) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [formatter setDecimalSeparator:@","];

            NSNumber *usage = [self.userDetails objectForKey:[self titleOfCellAtRow:row InSection:section]];
            if (usage == nil)
                usage = 0;
            data = [formatter stringFromNumber:usage];
        }
    } else if (section == 0) {
        data = [HelperTools getStringFor:[self titleOfCellAtRow:row InSection:section] From:self.userDetails];
    }
    if (data == nil || [data isKindOfClass:[NSNull class]] || data.length == 0)
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.imageView.image = nil;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 10;
    
    long section = indexPath.section;
    long row = indexPath.row;
    
    // Configure the cell...
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
    if (section == 0 || section == 1) { // Basic, Additional
        if (section == 0 && row == 0) {
                cell.textLabel.text = @"";
                cell.detailTextLabel.text = [HelperTools getStringFor:@"login" From:self.userDetails];
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
        } else {
            cell.textLabel.text = [self changeUnderscore:[self titleOfCellAtRow:row InSection:section]];
            cell.detailTextLabel.text = [self dataOfCellAtRow:row InSection:section];
        }
        if (section == 0 && (row == 2 || row == 5) && cell.detailTextLabel.text.length > 0)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
    } else if (section == 2) {
        NSDictionary *repo = self.repoList[row];
        cell.textLabel.text = [HelperTools getStringFor:@"name" From:repo];
        cell.detailTextLabel.text = [HelperTools getStringFor:@"description" From:repo];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"Basic";
        case 1: return @"Additional";
        case 2: return @"Repositories";
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

- (void)sendEMail:(NSString *)recipient
{
    NSString *bodyText = [NSString stringWithFormat:@"Hello %@,\n", [self dataOfCellAtRow:1 InSection:0]];
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObjects:recipient, nil]];
    [controller setSubject:@"Hello"];
    [controller setMessageBody:bodyText isHTML:NO];
    if (controller)
        [self presentViewController:controller animated:YES completion:^{
        }];
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    long section = indexPath.section;
    long row = indexPath.row;
    
    if (section == 0) { // Basic
        if (row == 2) { // email
            NSString *recipient = [self dataOfCellAtRow:2 InSection:0];
            if (recipient != nil && recipient.length > 0)
                [self sendEMail:recipient];
        } else if (row == 5) { // Blog URL
            NSString *url = [self dataOfCellAtRow:row InSection:section];
            if (url != nil && url.length > 0) {
                WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
                webViewController.webURLString = url;
                [self.navigationController pushViewController:webViewController animated:YES];
            }
        }
    } else if (section == 2) { // Repo Info
        RepoInfoViewController *repoInfoViewController = [[RepoInfoViewController alloc] initWithNibName:@"RepoInfoViewController" bundle:nil];
        
        NSDictionary *repo = self.repoList[indexPath.row];
        repoInfoViewController.repoURLString = [HelperTools getStringFor:@"url" From:repo];
        
        [self.navigationController pushViewController:repoInfoViewController animated:YES];
    }
}

#pragma mark - Fetching User Details

- (void)startNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)stopNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)refreshRepoList
{
    NSString *repoPath = [HelperTools getStringFor:@"repos_url" From:self.userDetails];
    
    NSDictionary *profileList = [ConfigHelper loadUserProfile];
    NSString *selectedUserID = [ConfigHelper loadSelectedUserID];
    NSDictionary *userProfile = [profileList valueForKey:selectedUserID];
    NSString *user_id = [userProfile valueForKey:@"user_id"];
    NSString *password = [userProfile valueForKey:@"password"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user_id, password];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [HelperTools AFBase64EncodedStringFromString:basicAuthCredentials]] forHTTPHeaderField:@"Authorization"];
    
    [self startNetworkIndicator];
    [manager GET:repoPath parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        self.repoList = JSON;
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
        
        [self refreshRepoList];
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
