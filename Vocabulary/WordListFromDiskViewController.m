
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

@interface WordListFromDiskViewController ()

@property (nonatomic, strong) NSMutableSet *selectedIndexPath;

- (void)scanFiles;

@end

@implementation WordListFromDiskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:1000];
    toolbar.tintColor = RGBA(48, 16, 17, 1);
    self.fileList = [[NSMutableArray alloc]init];
    self.selectedIndexPath = [[NSMutableSet alloc]init];
    [self scanFiles];
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

- (IBAction)clearAllFiles:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString*path =[paths objectAtIndex:0];
    NSArray *directoryContent = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    
    for (NSString *fileName in directoryContent) {
        if ([fileName hasSuffix:@".txt"]) {
            NSString *fullPath = [path stringByAppendingPathComponent:fileName];
            BOOL removeSuccess = [fileManager removeItemAtPath:fullPath error:nil];
        }
    }
}

@end
