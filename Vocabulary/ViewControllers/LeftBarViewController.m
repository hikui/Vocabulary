//
//  LeftBarViewController.m
//  Vocabulary
//
//  Created by Hikui on 13-1-3.
//  Copyright (c) 2013年 缪和光. All rights reserved.
//

#import "LeftBarViewController.h"
#import "IIViewDeckController.h"
#import "PlanningViewController.h"
#import "WordListFromDiskViewController.h"
#import "WordListViewController.h"
#import "PreferenceViewController.h"
#import "CreateWordListViewController.h"
#import "VNavigationController.h"
#import "WordDetailViewController.h"

#import "AppDelegate.h"

@interface LeftBarViewController ()

@property (nonatomic, strong) NSArray *rows;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation LeftBarViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.rows = @[@"今日学习计划",@"添加词汇列表",@"已有词汇列表",@"低熟悉度词汇",@"设置"];
    self.searchResultTableView.hidden = YES;
    self.searcher = [[WordSearcher alloc]init];
    self.searchBar.backgroundColor = [UIColor clearColor];
//    self.searchResultTableView.backgroundView = nil;
    self.searchResultTableView.backgroundColor = RGBA(227, 227, 227, 1);
    self.searchResultTableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CellSeparator.png"]];
    for (UIView *subview in [self.searchBar subviews]) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subview removeFromSuperview];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)viewWillAppear:(BOOL)animated
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    });
    IIViewDeckController *viewDeck = ((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController;
    CGRect searchBarFrame = self.searchBar.frame;
    searchBarFrame.size.width = viewDeck.leftViewSize;
    self.searchBar.frame = searchBarFrame;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return self.rows.count;
    }else if(tableView == self.searchResultTableView){
        return self.searchResult.count;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    static NSString *ResultCellIdentifier = @"ResultCell";
    if (tableView == self.tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UIImage *cellBG = [[UIImage imageNamed:@"CellBG.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            UIImage *cellBGHighlighted = [[UIImage imageNamed:@"CellBGHighlighted.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc]initWithImage:cellBG];
            cell.selectedBackgroundView = [[UIImageView alloc]initWithImage:cellBGHighlighted];
            UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, cell.frame.size.width-20,cell.frame.size.height)];
            contentLabel.tag = 1000;
            contentLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.font = [UIFont boldSystemFontOfSize:15];
            contentLabel.textColor = [UIColor whiteColor];
            [cell.contentView addSubview:contentLabel];
        }
        UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:1000];
        contentLabel.text = self.rows[indexPath.row];
        return cell;
    }else if(tableView == self.searchResultTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ResultCellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ResultCellIdentifier];
        }
        cell.textLabel.text = ((Word *)self.searchResult[indexPath.row]).key;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return 44;
    }else if(tableView == self.searchResultTableView){
        return 60;
    }
    return 44;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (indexPath.row != 1) {
            self.selectedIndexPath = indexPath;
        }
        
        IIViewDeckController *viewDeckController = ((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController;
        if (indexPath.row == 0) {
            if ([[((VNavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[PlanningViewController class]]) {
                [viewDeckController closeLeftView];
            }else{
                PlanningViewController *pvc = [[PlanningViewController alloc]initWithNibName:@"PlanningViewController" bundle:nil];
                VNavigationController *npvc = [[VNavigationController alloc]initWithRootViewController:pvc];
                [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                    controller.centerController = npvc;
                }];
            }
        }else if (indexPath.row == 1) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [tableView selectRowAtIndexPath:self.selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择导入方式"
                                                                    delegate:self
                                                           cancelButtonTitle:@"取消"
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:@"批量输入",@"从iTunes上传", nil];
//            [actionSheet showInView:self.view];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [actionSheet showFromRect:CGRectMake(0, 0, 300, cell.bounds.size.height) inView:cell animated:YES];
        }else if (indexPath.row == 2) {
            if ([[((VNavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[ExistingWordListsViewController class]]) {
                [viewDeckController closeLeftView];
            }else{
                ExistingWordListsViewController *swlvc = [[ExistingWordListsViewController alloc]initWithNibName:@"ExistingWordListsViewController" bundle:nil];
                VNavigationController *nswlvc = [[VNavigationController alloc]initWithRootViewController:swlvc];
                [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                    controller.centerController = nswlvc;
                }];
            }
        }else if (indexPath.row == 3) {
            if ([[((VNavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[WordListViewController class]]) {
                [viewDeckController closeLeftView];
            }else{
                
                NSManagedObjectContext *ctx = [[CoreDataHelperV2 sharedInstance] mainContext];
                NSFetchRequest *request = [[NSFetchRequest alloc]init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:ctx];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastVIewDate != nil AND ((familiarity <= 5) OR (familiarity <10 AND (NONE wordLists.effectiveCount<6))))"];
                [request setEntity:entity];
                [request setPredicate:predicate];
                NSArray *result = [ctx executeFetchRequest:request error:nil];
                NSMutableArray *mResult = [[NSMutableArray alloc]initWithArray:result];
                
                WordListViewController *svc = [[WordListViewController alloc]initWithNibName:@"WordListViewController" bundle:nil];
                svc.wordArray = mResult;
                svc.topLevel = YES;
                svc.title = @"低熟悉度词汇";
                VNavigationController *nsvc = [[VNavigationController alloc]initWithRootViewController:svc];
                [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                    controller.centerController = nsvc;
                }];
            }
        }else if (indexPath.row == 4) {
            if ([[((VNavigationController *)viewDeckController.centerController).viewControllers lastObject] isKindOfClass:[PreferenceViewController class]]) {
                [viewDeckController closeLeftView];
            }else{
                PreferenceViewController *cvc = [[PreferenceViewController alloc]initWithStyle:UITableViewStyleGrouped];
                VNavigationController *ncvc = [[VNavigationController alloc]initWithRootViewController:cvc];
                [viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
                    controller.centerController = ncvc;
                }];
            }
        }
    }else if(tableView == self.searchResultTableView){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        WordDetailViewController *lvc = [[WordDetailViewController alloc]initWithWord:self.searchResult[indexPath.row]];
        VNavigationController *nlvc = [[VNavigationController alloc]initWithRootViewController:lvc];
        [self presentModalViewController:nlvc animated:YES];
    }
    
}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"批量输入"]) {
        CreateWordListViewController *vc = [[CreateWordListViewController alloc]initWithNibName:@"CreateWordListViewController" bundle:nil];
        [self presentModalViewController:vc animated:YES];
    }else if ([title isEqualToString:@"从iTunes上传"]){
        WordListFromDiskViewController *fdvc =[[WordListFromDiskViewController alloc]initWithNibName:@"WordListFromDiskViewController" bundle:nil];
        [self presentModalViewController:fdvc animated:YES];
    }
}

#pragma mark - search bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    IIViewDeckController *viewDeck = ((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController;
    viewDeck.leftSize = self.view.bounds.size.width;
    [UIView animateWithDuration:[viewDeck closeSlideAnimationDuration] animations:^{
        searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, self.view.frame.size.width, searchBar.frame.size.height);
        [searchBar setShowsCancelButton:YES animated:YES];
        [searchBar layoutSubviews];
        self.searchResultTableView.hidden = NO;
        self.searchResultTableView.alpha = 1;
    }];
    return YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    IIViewDeckController *viewDeck = ((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController;
    if (IS_IPAD) {
        viewDeck.leftSize = 300;
    }else{
        viewDeck.leftSize = 140;
    }
    [searchBar setShowsCancelButton:NO animated:NO];
    [UIView animateWithDuration:[viewDeck closeSlideAnimationDuration] animations:^{
        searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, viewDeck.leftViewSize, searchBar.frame.size.height);
        [searchBar layoutSubviews];
        self.searchResultTableView.alpha = 0;
        self.searchResultTableView.hidden = YES;
    }];
    self.searchResult = nil;
    [self.searchResultTableView reloadData];
    [searchBar resignFirstResponder];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if (searchText.length == 0) {
        self.searchResult = nil;
        [self.searchResultTableView reloadData];
        return;
    }
    
    [self.searcher searchWord:searchText completion:^(NSArray *words) {
        self.searchResult = words;
        [self.searchResultTableView reloadData];
    }];
}

#pragma mark - scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.searchResultTableView) {
        [self.searchBar resignFirstResponder];
        for(id subview in [self.searchBar subviews])
        {
            if ([subview isKindOfClass:[UIButton class]]) {
                [subview setEnabled:YES];
            }
        }
    }
}

@end
