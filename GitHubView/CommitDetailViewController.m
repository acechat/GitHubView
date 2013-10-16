//
//  CommitDetailViewController.m
//  GitHubView
//
//  Created by Sungju Kwon on 16/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "CommitDetailViewController.h"
#import "ConfigHelper.h"
#import "AFNetworking.h"
#import "HelperTools.h"
#import "AccountViewController.h"
#import "FileContentViewController.h"

@interface CommitDetailViewController ()

@end

@implementation CommitDetailViewController

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
    self.title = @"Commit details";
    
    NSArray *firstSection = [[NSArray alloc] initWithObjects:@"name", @"login", @"email", @"date", nil];
    NSArray *secondSection = [[NSArray alloc] initWithObjects:@"name", @"login", @"email", @"date", nil];
    NSArray *thirdSection = [[NSArray alloc] initWithObjects:@"message", nil];
    
    self.titleOfCell = [[NSArray alloc] initWithObjects:firstSection, secondSection, thirdSection, nil];
    
    [self fetchCommittedFiles];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0: // Author
        case 1: // Committer
            return 4;
        case 2: // Message
            return 1;
        case 3: // Committed files
            return self.committedFileList.count;
    }
    return 0;
}


- (NSString *)titleOfCellAtRow:(int)row InSection:(int)section
{
    NSArray *data = nil;
    
    if (section == 3)
        return @"";
    
    data = [self.titleOfCell objectAtIndex:section];
    
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
    NSDictionary *commit = [self.commitInfo objectForKey:@"commit"];
    
    if (section == 0 || section == 1) {
        NSDictionary *user = nil;
        NSDictionary *fullUser = nil;
        
        if (section == 0) {
            user = [commit objectForKey:@"author"];
            fullUser = [self.commitInfo objectForKey:@"author"];
        } else {
            user = [commit objectForKey:@"committer"];
            fullUser = [self.commitInfo objectForKey:@"committer"];
        }
        
        if (row == 0 || row == 2) {
            data = [HelperTools getStringFor:title From:user];
        } else if (row == 1) {
            data = [HelperTools getStringFor:title From:fullUser];
        } else if (row == 3) {
            data = [self dateDiff:[user objectForKey:title]];
        }
    } else if (section == 2) {
        data = [HelperTools getStringFor:title From:commit];
    } else if (section == 3) {
        data = [HelperTools getStringFor:@"filename" From:self.committedFileList[row]];
    }
    if (data == nil || [data isKindOfClass:[NSNull class]])
        data = @"";
    
    return data;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommitDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    long section = indexPath.section;
    long row = indexPath.row;
    
    cell.textLabel.text = [self titleOfCellAtRow:row InSection:section];
    cell.detailTextLabel.text = [self dataOfCellAtRow:row InSection:section];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (section == 0 || section == 1) {
        if (row == 1 && cell.detailTextLabel.text.length > 0)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (section == 3) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"Author";
        case 1: return @"Committer";
        case 2: return @"Message";
        case 3: return @"Committed files";
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
    // Navigation logic may go here, for example:
    // Create the next view controller.
    long section = indexPath.section;
    long row = indexPath.row;
    
    if (section == 0 || section == 1) {
        NSString *data = [self dataOfCellAtRow:row InSection:section];
        if (row == 1 && data.length > 0) {
            AccountViewController *accountViewController = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil];
            accountViewController.userToView = data;
            [self.navigationController pushViewController:accountViewController animated:YES];
        }
    } else if (section == 3) {
        FileContentViewController *fileContentViewController = [[FileContentViewController alloc] initWithNibName:@"FileContentViewController" bundle:nil];
        fileContentViewController.fileName = [self dataOfCellAtRow:row InSection:section];
        fileContentViewController.htmlContent = [HelperTools getStringFor:@"patch" From:self.committedFileList[row]];
        
        [self.navigationController pushViewController:fileContentViewController animated:YES];
    }
}

#pragma mark - Fetching Committed File List

- (void)startNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)stopNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)fetchCommittedFiles
{
    NSDictionary *profileList = [ConfigHelper loadUserProfile];
    NSString *selectedUserID = [ConfigHelper loadSelectedUserID];
    NSDictionary *userProfile = [profileList valueForKey:selectedUserID];
    NSString *user_id = [userProfile valueForKey:@"user_id"];
    NSString *password = [userProfile valueForKey:@"password"];
    NSString *commitURL = [self.commitInfo objectForKey:@"url"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", user_id, password];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [HelperTools AFBase64EncodedStringFromString:basicAuthCredentials]] forHTTPHeaderField:@"Authorization"];
    
    
    [self startNetworkIndicator];
    [manager GET:commitURL parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Committed file list : %@", JSON);
        self.committedFileList = [JSON objectForKey:@"files"];
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
