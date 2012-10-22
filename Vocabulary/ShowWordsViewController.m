//
//  ShowWordsViewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-20.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "ShowWordsViewController.h"
#import "Word.h"
#import "LearningBackboneViewController.h"
#import "LearningViewController.h"

@interface ShowWordsViewController ()

@end

@implementation ShowWordsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_wordsSet sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Word *wobj1 = (Word *)obj1;
        Word *wobj2 = (Word *)obj2;
        return [wobj1.key compare:wobj2.key];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.wordsSet.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Word *w = [self.wordsSet objectAtIndex:indexPath.row];
    cell.textLabel.text = w.key;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Word *w = [self.wordsSet objectAtIndex:indexPath.row];
    LearningViewController *lvc = [[LearningViewController alloc]initWithWord:w];
    [self.navigationController pushViewController:lvc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - tool bar actions
- (IBAction)btnBeginStudyOnPress:(id)sender
{
    LearningBackboneViewController *lvc = [[LearningBackboneViewController alloc]initWithWords:self.wordsSet];
    [self.navigationController pushViewController:lvc animated:YES];
}
- (IBAction)btnBeginTestOnPress:(id)sender
{
    
}
@end
