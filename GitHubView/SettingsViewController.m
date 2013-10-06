//
//  SettingsViewController.m
//  GitHubView
//
//  Created by Sungju Kwon on 1/10/13.
//  Copyright (c) 2013 Sungju Kwon. All rights reserved.
//

#import "SettingsViewController.h"
#import "PKRevealController.h"
#import "AppDelegate.h"
#import "ConfigHelper.h"
#import "HelpViewController.h"
#import "AboutViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize screenInfo;
@synthesize aboutList;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize singleTap;

@synthesize themeList;
@synthesize themeLastIndexPath;
@synthesize themeIndex;

@synthesize delegate;
@synthesize selector;

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
    self.title = @"Settings";
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                   target:self
                                   action:@selector(saveConfig)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.aboutList = [[NSArray alloc] initWithObjects:@"About this app", @"Help", nil];

    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 179, 30)];
    self.usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameTextField.returnKeyType = UIReturnKeyNext;
    self.usernameTextField.delegate = self;
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 179, 30)];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;
    
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    self.singleTap.numberOfTouchesRequired = 1;
    self.singleTap.numberOfTapsRequired = 1;
    [self.singleTap setDelaysTouchesBegan:YES];
    [self.singleTap setDelaysTouchesEnded:YES];
    self.singleTap.delegate = self;
    
    [self loadConfig];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration

- (void)saveConfig
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *profileList = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *userinfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSString *userName = self.usernameTextField.text == nil ? @"" : self.usernameTextField.text;
    NSString *password = self.passwordTextField.text == nil ? @"" : self.passwordTextField.text;
    
    [userinfo setValue:userName forKey:@"user_id"];
    [userinfo setValue:password forKey:@"password"];
    [profileList setValue:userinfo forKey:userName];
    
    [ConfigHelper saveSelectedUserID:userName];
    [ConfigHelper saveUserProfile:profileList];
    
    [app.appConfiguration setObject:[NSNumber numberWithInt:themeLastIndexPath.row] forKey:@"theme_index"];
    
    [app saveConfig];
    
    [self singleTapAction:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Saved changes" delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [alert show];
    
    // Create the perform selector method with alert view object and time-period
    [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:0.7];
}

// Dismiss the alert view after time-Period
-(void)dismissAlertView:(UIAlertView *)alert
{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
    
}
- (void)loadConfig
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    NSString *userName = [ConfigHelper loadSelectedUserID];
    NSDictionary *profileList = [ConfigHelper loadUserProfile];
    NSDictionary *userInfo = nil;
    if (userName != nil)
        userInfo = [profileList valueForKey:userName];
    NSString *password = @"";
    if (userInfo != nil)
        password = [userInfo valueForKey:@"password"];
    
    self.usernameTextField.text = userName;
    self.passwordTextField.text = password;
    
    NSNumber *themeNumber = [app.appConfiguration objectForKey:@"theme_index"];
    themeIndex = [themeNumber intValue];
    
    self.themeList = app.themeList;
}


#pragma mark - User Interaction

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView addGestureRecognizer:self.singleTap];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.tableView removeGestureRecognizer:self.singleTap];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField)
        [self.passwordTextField becomeFirstResponder];
    else if (textField == self.passwordTextField)
        [self.usernameTextField becomeFirstResponder];
    
    return YES;
}

- (void)singleTapAction:(id)sender
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2; // Username and password
        case 1:
            return [self.themeList count];
        case 2:
            return [self.aboutList count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConfigCell";
    NSUInteger section = [indexPath section];
    
    UITableViewCell *cell = nil;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    cell.accessoryView = nil;
    
    NSDictionary *dict;
    NSUInteger newRow = [indexPath row];
    NSUInteger oldRow;
    
    switch (section) {
        case 0:
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.accessoryView = newRow == 0 ? usernameTextField : passwordTextField;
            cell.textLabel.text = newRow == 0 ? @"Username:" : @"Password:";
            break;
        case 1:
            dict = [self.themeList objectAtIndex:newRow];
            
            oldRow = [self.themeLastIndexPath row];
            cell.detailTextLabel.text = @"";
            cell.textLabel.text = [dict objectForKey:@"desc"];
            
            cell.accessoryType = (newRow == oldRow && self.themeLastIndexPath != nil) ?
            UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            
            if (self.themeLastIndexPath == nil && newRow == themeIndex) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.themeLastIndexPath = indexPath;
            }
            break;
        case 2:
            cell.textLabel.text = [self.aboutList objectAtIndex:newRow];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
    }
    
    // Configure the cell.
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"Login";
        case 1: return @"Theme for code";
        case 2: return @"About";
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


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    int newRow = indexPath.row;
    int oldRow = -1;

    AboutViewController *aboutViewController;
    HelpViewController *helpViewController;
    
    switch (section) {
        case 0:
            break;
        case 1:
            oldRow = (self.themeLastIndexPath != nil) ? [self.themeLastIndexPath row] : -1;
            if (newRow != oldRow) {
                UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
                newCell.accessoryType = UITableViewCellAccessoryCheckmark;
                UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:self.themeLastIndexPath];
                oldCell.accessoryType = UITableViewCellAccessoryNone;
                
                self.themeLastIndexPath = indexPath;
            }
            break;
        case 2:
            switch (newRow) {
                case 0:
                    aboutViewController = [[AboutViewController alloc]
                                           initWithNibName:@"AboutViewController" bundle:nil];
                    
                    
                    [self.navigationController pushViewController:aboutViewController animated:YES];
                    break;
                case 1:
                    helpViewController = [[HelpViewController alloc]
                                          initWithNibName:@"HelpViewController" bundle:nil];
                    
                    [self.navigationController pushViewController:helpViewController animated:YES];
                    break;
            }
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
