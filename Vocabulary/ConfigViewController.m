
/*
 *  This file is part of 记词助手.
 *
 *	记词助手 is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License Version 2 as 
 *  published by the Free Software Foundation.
 *
 *	记词助手 is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with 记词助手.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  ConfigViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-11-1.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ConfigViewController.h"
#import "HelpViewController.h"
#import "ActionSheetPicker.h"
#import "ConfusingWordsIndexer.h"

@interface ConfigViewController ()

- (void)notificationEnablerDidChange:(id)sender;
- (void)soundEnablerDidChange:(id)sender;
- (void)autoIndexEnablerDidChange:(id)sender;
- (void)setTimeButtonOnTouch:(UIButton *)sender;
- (void)datePickerValueDidChange:(UIDatePicker *)sender;
- (NSString *)getTimeStringFromDate:(NSDate *)date;
- (void)setNotificationWithDate:(NSDate *)date;

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
    self.dayNotificationTime = [[NSUserDefaults standardUserDefaults]objectForKey:kDayNotificationTime];
    self.nightNotificationTime = [[NSUserDefaults standardUserDefaults]objectForKey:kNightNotificationTime];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm"];
    if (self.dayNotificationTime == nil) {
        self.dayNotificationTime = [format dateFromString:@"08:00"];
    }
    if (self.nightNotificationTime == nil) {
        self.nightNotificationTime = [format dateFromString:@"20:00"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
            return 6;
        }else{
            return 4;
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
        
        int offset = notificationEnabled?2:0;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"开启提醒";
            UISwitch *switcher = [[UISwitch alloc]initWithFrame:CGRectZero];
            switcher.on = notificationEnabled;
            [switcher addTarget:self action:@selector(notificationEnablerDidChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
        }else if (indexPath.row == 1 && notificationEnabled){
            cell.textLabel.text = @"早上提醒时间";
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btn setTitle:[self getTimeStringFromDate:self.dayNotificationTime] forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, 0, 90, 35);
            btn.tag = 1;
            [btn addTarget:self action:@selector(setTimeButtonOnTouch:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = btn;
        }else if (indexPath.row == 2 && notificationEnabled){
            cell.textLabel.text = @"晚上提醒时间";
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btn setTitle:[self getTimeStringFromDate:self.nightNotificationTime] forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, 0, 90, 35);
            btn.tag = 2;
            [btn addTarget:self action:@selector(setTimeButtonOnTouch:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = btn;
        }else if (indexPath.row == 1 + offset){
            BOOL enabledSound = [[NSUserDefaults standardUserDefaults]boolForKey:kPerformSoundAutomatically];
            cell.textLabel.text = @"浏览单词时自动发音";
            UISwitch *switcher = [[UISwitch alloc]initWithFrame:CGRectZero];
            switcher.on = enabledSound;
            [switcher addTarget:self action:@selector(soundEnablerDidChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
        }else if (indexPath.row == 3 + offset){
            cell.textLabel.text = @"重新索引易混淆单词";
        }else if (indexPath.row == 2 + offset){
            cell.textLabel.text = @"自动索引易混淆单词";
            BOOL autoIndex = [[NSUserDefaults standardUserDefaults]boolForKey:kAutoIndex];
            UISwitch *switcher = [[UISwitch alloc]initWithFrame:CGRectZero];
            switcher.on = autoIndex;
            [switcher addTarget:self action:@selector(autoIndexEnablerDidChange:) forControlEvents:UIControlEventValueChanged];
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BOOL notificationEnabled = [[NSUserDefaults standardUserDefaults]boolForKey:@"NotificationEnabled"];
    int offset = notificationEnabled?2:0;
    if (indexPath.section == 0) {
        if (indexPath.row == 3 + offset) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.detailsLabelText = @"正在索引";
            hud.mode = MBProgressHUDModeAnnularDeterminate;
            [ConfusingWordsIndexer reIndexForAllWithProgressCallback:^(float progress) {
                hud.progress = progress;
            } completion:^{
                [hud hide:YES];
            }];
        }
    }else if (indexPath.section == 1) {
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

#pragma mark - private methods

- (void)notificationEnablerDidChange:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if (theSwitch.isOn) {
        [self setNotificationWithDate:self.dayNotificationTime];
        [self setNotificationWithDate:self.nightNotificationTime];
    }
    [[NSUserDefaults standardUserDefaults]setBool:theSwitch.isOn forKey:@"NotificationEnabled"];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexes withRowAnimation:UITableViewRowAnimationFade];
}

- (void)soundEnablerDidChange:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults]setBool:theSwitch.isOn forKey:kPerformSoundAutomatically];
}

- (void)autoIndexEnablerDidChange:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults]setBool:theSwitch.isOn forKey:kAutoIndex];
}

- (void)setTimeButtonOnTouch:(UIButton *)sender
{
    NSDate *selectedTime = nil;
    if (sender.tag == 1) {
        selectedTime = self.dayNotificationTime;
    }else if (sender.tag == 2){
        selectedTime = self.nightNotificationTime;
    }
    ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeTime selectedDate:selectedTime target:self action:@selector(dateWasSelected:element:) origin:sender];
    picker.hideCancel = YES;
    [picker showActionSheetPicker];
}
- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    UIButton *btn = (UIButton *)element;
    if (btn.tag == 1) {
        self.dayNotificationTime = selectedDate;
        [[NSUserDefaults standardUserDefaults]setObject:selectedDate forKey:kDayNotificationTime];
    }else if (btn.tag == 2){
        self.nightNotificationTime = selectedDate;
        [[NSUserDefaults standardUserDefaults]setObject:selectedDate forKey:kNightNotificationTime];
    }
    [btn setTitle:[self getTimeStringFromDate:selectedDate] forState:UIControlStateNormal];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self setNotificationWithDate:self.dayNotificationTime];
    [self setNotificationWithDate:self.nightNotificationTime];
    
}

- (NSString *)getTimeStringFromDate:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm"];
    NSString *result = [format stringFromDate:date];
    return result;
}

- (void)setNotificationWithDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit )fromDate:now];
    
    NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit)fromDate:date];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    
    [dateComps setDay:[dateComponents day]];
    [dateComps setMonth:[dateComponents month]];
    [dateComps setYear:[dateComponents year]];
    
    [dateComps setHour:[timeComponents hour]];
    [dateComps setMinute:[timeComponents minute]];
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    
    localNotif.fireDate = itemDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    // Notification details
    localNotif.alertBody = @"背单词的时间到了";
    
    // Set the action button
    localNotif.alertAction = @"开始学习";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.repeatInterval = NSDayCalendarUnit;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
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
