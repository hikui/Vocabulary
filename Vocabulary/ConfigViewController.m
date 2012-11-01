//
//  ConfigViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-11-1.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ConfigViewController.h"
#import "HelpViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface ConfigViewController ()

- (void)notificationEnablerDidChange:(id)sender;
- (void)soundEnablerDidChange:(id)sender;
- (void)setTimeButtonOnTouch:(UIButton *)sender;
- (void)datePickerValueDidChange:(UIDatePicker *)sender;

@end

@implementation ConfigViewController

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
    self.title = @"设置";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        BOOL notificationEnabled = [[NSUserDefaults standardUserDefaults]boolForKey:@"NotificationEnabled"];
        if (notificationEnabled) {
            return 4;
        }else{
            return 2;
        }
    }else{
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    BOOL notificationEnabled = [[NSUserDefaults standardUserDefaults]boolForKey:@"NotificationEnabled"];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"开启提醒";
            UISwitch *switcher = [[UISwitch alloc]initWithFrame:CGRectZero];
            switcher.on = notificationEnabled;
            [switcher addTarget:self action:@selector(notificationEnablerDidChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
        }else if (indexPath.row == 1 && notificationEnabled){
            cell.textLabel.text = @"早上提醒时间";
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btn setTitle:@"1:30" forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, 0, 90, 35);
            btn.tag = 1;
            [btn addTarget:self action:@selector(setTimeButtonOnTouch:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = btn;
        }else if (indexPath.row == 1 && !notificationEnabled){
            BOOL enabledSound = [[NSUserDefaults standardUserDefaults]boolForKey:kPerformSoundAutomatically];
            cell.textLabel.text = @"浏览单词时自动发音";
            UISwitch *switcher = [[UISwitch alloc]initWithFrame:CGRectZero];
            switcher.on = enabledSound;
            [switcher addTarget:self action:@selector(soundEnablerDidChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"晚上提醒时间";
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btn setTitle:@"1:30" forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, 0, 90, 35);
            btn.tag = 2;
            [btn addTarget:self action:@selector(setTimeButtonOnTouch:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = btn;
        }else if (indexPath.row == 3){
            BOOL enabledSound = [[NSUserDefaults standardUserDefaults]boolForKey:kPerformSoundAutomatically];
            cell.textLabel.text = @"浏览单词时自动发音";
            UISwitch *switcher = [[UISwitch alloc]initWithFrame:CGRectZero];
            switcher.on = enabledSound;
            [switcher addTarget:self action:@selector(soundEnablerDidChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"帮助";
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"反馈";
        }
        
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            HelpViewController *hvc = [[HelpViewController alloc]initWithNibName:@"HelpViewController" bundle:nil];
            hvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentModalViewController:hvc animated:YES];
        }else if (indexPath.row == 1){
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
                controller.mailComposeDelegate = self;
                [controller setSubject:@"词汇小助手反馈"];
                [controller setToRecipients:@[@"hikuimiao@gmail.com"]];
                //[controller setMessageBody:@"Hello there." isHTML:NO];
                if (controller) {
                    [self presentModalViewController:controller animated:YES];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"你的设备不支持发送邮件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

- (void)notificationEnablerDidChange:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults]setBool:theSwitch.isOn forKey:@"NotificationEnabled"];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexes withRowAnimation:UITableViewRowAnimationFade];
}

- (void)soundEnablerDidChange:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults]setBool:theSwitch.isOn forKey:kPerformSoundAutomatically];
}

- (void)setTimeButtonOnTouch:(UIButton *)sender
{

}
- (void)datePickerValueDidChange:(UIDatePicker *)sender
{
    
}

#pragma mark - mail delegate 
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
