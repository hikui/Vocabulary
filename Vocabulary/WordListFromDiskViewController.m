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
    //在新线程中导入wordlist
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString*path =[paths objectAtIndex:0];
        for (NSString *fileName in self.fileList) {
            NSString *filePath = [path stringByAppendingFormat:@"/%@",fileName];
            NSError *readFileError = NULL;
            NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&readFileError];
            if (readFileError != NULL) {
                //faild
                continue;
            }
            
            NSArray *words = [content componentsSeparatedByString:@"\n"];
            NSSet *wordSet = [NSSet setWithArray:words]; //remove duplicates
            NSError *wordListCreatorError = NULL;
            [WordListCreator createWordListWithTitle:fileName wordSet:wordSet error:&wordListCreatorError];
            if (wordListCreatorError != NULL) {
                NSLog(@"%@",[wordListCreatorError localizedDescription]);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (IBAction)refreshButtonOnPress:(id)sender
{
    [self scanFiles];
    [self.tableView reloadData];
}

@end
