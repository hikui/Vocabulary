
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
//  WordListFromDiskViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-11-3.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "WordListFromDiskViewController.h"
#import "WordListCreator.h"
#import "AppDelegate.h"
#import "GuideView.h"

@interface WordListFromDiskViewController ()

@property (nonatomic, strong) NSMutableSet *selectedIndexPath;

- (void)scanFiles;

@end

@implementation WordListFromDiskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fileList = [[NSMutableArray alloc]init];
    self.selectedIndexPath = [[NSMutableSet alloc]init];
    [self scanFiles];
}

- (void)viewDidAppear:(BOOL)animated
{
//    GuideViewController *gvc = [GuideViewController guideViewControllerForClass:[self class]];
//    if (gvc != nil) {
//        [self addChildViewController:gvc];
//        [self.view addSubview:gvc.view];
//        gvc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//        [gvc updateContentSize];
//        [gvc didMoveToParentViewController:self];
//    }
    GuideView *gv = [GuideView guideViewForClass:[self class]];
    if (gv != nil) {
        NSInteger guideVersion = gv.guide.guideVersion;
        NSInteger currGuideVersion = [[NSUserDefaults standardUserDefaults]integerForKey:gv.guide.guideName];
        if (guideVersion > currGuideVersion) {
            gv.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            gv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self.view addSubview:gv];
            [gv guideWillAppear];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileList.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"已上传的文件";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.fileList objectAtIndex:indexPath.row];
    if ([self.selectedIndexPath containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.selectedIndexPath containsObject:indexPath]) {
        //deselect
        [self.selectedIndexPath removeObject:indexPath];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        [self.selectedIndexPath addObject:indexPath];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
}

- (void)scanFiles
{
    [self.fileList removeAllObjects];
    [self.selectedIndexPath removeAllObjects];
    NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*path =[paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    
    for (NSString *fileName in directoryContent) {
        if ([fileName hasSuffix:@".txt"]) {
            [self.fileList addObject:fileName];
        }
        NSLog(@"%@",fileName);
    }
}

- (void)clearAllFiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*path =[paths objectAtIndex:0];
    NSArray *directoryContent = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    
    for (NSString *fileName in directoryContent) {
        if ([fileName hasSuffix:@".txt"]) {
            NSString *fullPath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:fullPath error:nil];
        }
    }
    [self refreshButtonOnPress:nil];
}

#pragma mark - actions
- (IBAction)finishButtonOnPress:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    __block int totalCount = self.selectedIndexPath.count;
    
    if (totalCount == 0) {
        [hud hide:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if (self.wordList != nil) {
        NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString*path =[paths objectAtIndex:0];
        for (NSIndexPath *selectedIndexPath in self.selectedIndexPath) {
            int row = selectedIndexPath.row;
            NSString *fileName = [self.fileList objectAtIndex:row];
            NSString *filePath = [path stringByAppendingFormat:@"/%@",fileName];
            NSError *readFileError = NULL;
            NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&readFileError];
            if (readFileError != NULL) {
                //faild
                continue;
            }
            
            NSArray *words = [content componentsSeparatedByString:@"\n"];
            NSSet *wordSet = [NSSet setWithArray:words]; //remove duplicates
            
            
            
            [WordListCreator addWords:wordSet toWordListId:self.wordList.objectID progressBlock:^(float progress) {
                hud.detailsLabelText = @"正在索引易混淆单词";
            } completion:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"%@",[error localizedDescription]);
                }
                [hud hide:YES];
                [((AppDelegate *)[UIApplication sharedApplication].delegate) refreshTodaysPlan];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }];
        }
    }else{
        NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString*path =[paths objectAtIndex:0];
        
        for (NSIndexPath *selectedIndexPath in self.selectedIndexPath) {
            int row = selectedIndexPath.row;
            NSString *fileName = [self.fileList objectAtIndex:row];
            NSString *filePath = [path stringByAppendingFormat:@"/%@",fileName];
            NSError *readFileError = NULL;
            NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&readFileError];
            if (readFileError != NULL) {
                //faild
                continue;
            }
            
            NSArray *words = [content componentsSeparatedByString:@"\n"];
            NSSet *wordSet = [NSSet setWithArray:words]; //remove duplicates
            
            NSString *wordListName = [fileName stringByDeletingPathExtension];
            
            
            [WordListCreator createWordListAsyncWithTitle:wordListName wordSet:wordSet progressBlock:^(float progress) {
                //            [hud setMode:MBProgressHUDModeAnnularDeterminate];
                //            hud.progress = progress;
                hud.detailsLabelText = @"正在索引易混淆单词";
                
            } completion:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"%@",[error localizedDescription]);
                }
                totalCount--;
                if (totalCount <= 0) {
                    [hud hide:YES];
//                    [((AppDelegate *)[UIApplication sharedApplication].delegate) refreshTodaysPlan];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kShouldRefreshTodaysPlanNotificationKey object:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }
}

- (IBAction)refreshButtonOnPress:(id)sender
{
    [self scanFiles];
    [self.tableView reloadData];
}

- (IBAction)clearAllFilesButtonPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"确定删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
}

- (IBAction)helpButtonPressed:(id)sender
{
    GuideView *gv = [GuideView guideViewForClass:[self class]];
    if (gv != nil) {
        gv.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        gv.alpha = 0;
        gv.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:gv];
        
        [gv guideWillAppear];
        [UIView animateWithDuration:0.5 animations:^{
            gv.alpha = 1;
        }];
    }
}


#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([btnTitle isEqualToString:@"确定"]) {
        [self clearAllFiles];
    }
}



@end
