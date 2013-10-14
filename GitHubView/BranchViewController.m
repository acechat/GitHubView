//
//  BranchViewController.m
//  GitHubView
//
//  Created by Sungju Kwon on 13/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "BranchViewController.h"
#import "ConfigHelper.h"
#import "AFNetworking.h"
#import "HelperTools.h"

@interface BranchViewController ()

@property (nonatomic, retain) UIImage *folderImage;
@property (nonatomic, retain) UIImage *textImage;
@property (nonatomic, retain) UIImage *audioImage;
@property (nonatomic, retain) UIImage *execImage;
@property (nonatomic, retain) UIImage *imageImage;
@property (nonatomic, retain) UIImage *videoImage;

@property (nonatomic, assign) int directoryDepth;
@property (nonatomic, retain) NSMutableArray *directoryPath;
@property (nonatomic, retain) NSMutableArray *directoryList;

@end

@implementation BranchViewController

@synthesize repoOwnerString;
@synthesize repoNameString;
@synthesize branchNameString;
@synthesize treesPath;
@synthesize viewMode;

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
    self.viewMode = 0;
    self.directoryDepth = 0;
    self.directoryPath = [[NSMutableArray alloc] init];
    self.directoryList = [[NSMutableArray alloc] init];
    
    self.headerView = [[UIView alloc] init];
    NSArray *itemArray = [NSArray arrayWithObjects: @"File Tree", @"Commits", nil];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    [self.segmentedControl setEnabled:YES];
    self.segmentedControl.backgroundColor = [UIColor whiteColor]; //
    [self.segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    
    [self.headerView addSubview:self.segmentedControl];
    
    self.folderImage = [UIImage imageNamed:@"folder.png"];
    self.textImage = [UIImage imageNamed:@"mime_text.png"];
    self.audioImage = [UIImage imageNamed:@"mime_audio.png"];
    self.execImage = [UIImage imageNamed:@"mime_exec.png"];
    self.videoImage = [UIImage imageNamed:@"mime_video.png"];
    self.imageImage = [UIImage imageNamed:@"mime_image.png"];

    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating News Feed"];
    [refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    [self pullToRefresh];
}

- (void) pullToRefresh
{
    [self refreshBranchFileList];
    [self refreshCommitList];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateTable];
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
    return [self.directoryList count];
}

- (UIImage *)imageForType:(NSString *)type WithPath:(NSString *)path
{
    NSArray *textTypeList = [[NSArray alloc] initWithObjects:@".jpg",
                             @".rb", @".txt", @".c", @".md", nil];
    NSArray *imageTypeList = [[NSArray alloc] initWithObjects:@".jpg",
                              @".png", @".jpeg", nil];
    
    if ([type isEqualToString:@"tree"])
        return self.folderImage;
    
    for (NSString *fileType in textTypeList) {
        if ([path hasSuffix:fileType])
            return self.textImage;
    }
    
    for (NSString *fileType in imageTypeList) {
        if ([path hasSuffix:fileType])
            return self.imageImage;
    }
    
    return self.execImage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FileListCellIdentifier = @"FileListCell";
    static NSString *CommitsCellIdentifier = @"CommitsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(self.viewMode == 0) ? FileListCellIdentifier : CommitsCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(self.viewMode == 0) ? FileListCellIdentifier : CommitsCellIdentifier];
    }
    
    // Configure the cell...
    long row = indexPath.row;
    cell.imageView.image = nil;
    if (self.viewMode == 0) {
        NSDictionary *file = self.directoryList[row];
        NSString *path = [HelperTools getStringFor:@"path" From:file];
        NSString *type = [HelperTools getStringFor:@"type" From:file];
        cell.textLabel.text = path;
        cell.imageView.image = [self imageForType:type WithPath:path];
    } else {
        NSDictionary *commitInfo = self.commitList[row];
        NSDictionary *commit = [commitInfo valueForKey:@"commit"];
        cell.textLabel.text = [HelperTools getStringFor:@"message" From:commit];
    }
    return cell;
}

- (void)changeView:(id)sender
{
    self.viewMode = ((UISegmentedControl *)sender).selectedSegmentIndex;
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [self.segmentedControl setFrame:CGRectMake(0.0, 0, self.tableView.frame.size.width, 40.0)];
    [self.segmentedControl setSelectedSegmentIndex:self.viewMode];

    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
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
    if (self.viewMode == 0) {
        NSDictionary *file = self.directoryList[indexPath.row];
        
        NSString *fileType = [file objectForKey:@"type"];
        if ([fileType isEqualToString:@"tree"]) {
            NSString *fileName = [file objectForKey:@"path"];
            if ([fileName isEqualToString:@".."]) {
                self.directoryDepth--;
                [self.directoryPath removeObjectAtIndex:self.directoryDepth];
            } else {
                self.directoryDepth++;
                [self.directoryPath addObject:file];
            }
            [self refreshBranchFileList];
        } else {
        }
    }
}

#pragma mark - Fetching Branch Info

- (void)startNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)stopNetworkIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)refreshBranchFileList
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
    
    //path = [NSString stringWithFormat:@"/repos/%@/%@/branches/%@", self.repoOwnerString, self.repoNameString, self.branchNameString];
    
    if (self.directoryDepth > 0) {
        NSDictionary *file = self.directoryPath[self.directoryDepth - 1];
        path = [file valueForKey:@"url"];
    } else {
        path = treesPath;
    }

    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"BRANCH INFO : %@", JSON);

        self.fileList = JSON;
        [self.directoryList removeAllObjects];
        if (self.directoryDepth > 0) {
            NSMutableDictionary *parent = [[NSMutableDictionary alloc] init];
            [parent setObject:@".." forKey:@"path"];
            [parent setObject:@"tree" forKey:@"type"];
            NSDictionary *parentData = [self.directoryPath objectAtIndex:self.directoryDepth - 1];
            NSLog(@"directoryPath : %@", self.directoryPath);
            NSLog(@"parentData : %@", parentData);
            [parent setObject:[parentData valueForKey:@"url"] forKey:@"url"];
            [parent setObject:[parentData valueForKey:@"sha"] forKey:@"sha"];
            
            [self.directoryList addObject:parent];
        }
        NSMutableArray *tree = [self.fileList valueForKey:@"tree"];
        [self.directoryList addObjectsFromArray:tree];
        
        if (self.viewMode == 0) {
            [self.tableView reloadData];
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
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

- (void)refreshCommitList
{
    NSString *hostAddr = @"https://api.github.com";
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
    path = [NSString stringWithFormat:@"/repos/%@/%@/commits", self.repoOwnerString, self.repoNameString];
    [manager GET:[NSString stringWithFormat:@"%@%@", hostAddr, path] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        //NSLog(@"COMMITS : %@", JSON);
        self.commitList = JSON;
        if (self.viewMode == 1) {
            [self.tableView reloadData];
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
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
