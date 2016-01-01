
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
//  PlanningVIewController.m
//  Vocabulary
//
//  Created by 缪和光 on 12-10-25.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "PlanningViewController.h"
#import "WordListViewController.h"
#import "AppDelegate.h"
#import "PureColorImageGenerator.h"
#import "PlanMaker.h"
#import "NSDate+VAdditions.h"
#import "HKVBasicTableViewCell.h"

@interface PlanningViewControllerCell : HKVBasicTableViewCell

@end

@implementation PlanningViewControllerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (void)bindData:(id)data {
    [super bindData:data];
    NSDate *todaysDateWithoutTime = [[NSDate date]hkv_dateWithoutTime];
    WordList *wl = (WordList *)data;
    self.textLabel.text = [wl.title description];
    NSString *detailTxt = [NSString stringWithFormat:@"复习次数:%@",[wl.effectiveCount description]];
    if ([wl.lastReviewTime compare:todaysDateWithoutTime] == NSOrderedDescending) {
        self.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Check"]];
    }else{
        self.accessoryView = nil;
    }
    self.detailTextLabel.text = detailTxt;
}

+ (CGFloat)heightForData:(id)data {
    return 44.0;
}

@end

@interface PlanningViewController ()<HKVDefaultTableViewModelDelegate>

@property (nonatomic, strong) HKVDefaultTableViewModel *tableModel;

- (void)refreshHintView;

@end

@implementation PlanningViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    
    menuButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [menuButton setImage:[PureColorImageGenerator generateMenuImageWithTint:RGBA(255, 255, 255, 0.9)] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(revealLeftSidebar:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc]initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = menuBarButton;
    
    self.title = @"记词助手";
    
    //用于提示已经完成所有计划
    self.hintView = [[UILabel alloc]initWithFrame:self.view.frame];
    self.hintView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.hintView.font = [UIFont boldSystemFontOfSize:20];
    self.hintView.backgroundColor = GlobalBackgroundColor;
    self.hintView.shadowColor = [UIColor whiteColor];
    self.hintView.shadowOffset = CGSizeMake(0, 1);
    self.hintView.textColor = RGBA(140, 140, 140, 1);
    self.hintView.numberOfLines = 0;
    self.hintView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.hintView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldRefreshPlan:) name:kShouldRefreshTodaysPlanNotificationKey object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.todaysPlan = [[PlanMaker sharedInstance]todaysPlan];
    [self configTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configTableView {
    [self refreshHintView];
    _tableModel = [[HKVDefaultTableViewModel alloc]init];
    _tableModel.tableView = self.tableView;
    _tableModel.delegate = self;
    self.tableView.delegate = _tableModel;
    self.tableView.dataSource = _tableModel;
    
    HKVTableViewCellConfig *cellConfig = [[HKVTableViewCellConfig alloc]init];
    cellConfig.className = NSStringFromClass([PlanningViewControllerCell class]);
    if (self.todaysPlan.learningPlan) {
        HKVTableViewSectionConfig *sectionLearningConfig = [[HKVTableViewSectionConfig alloc]init];
        sectionLearningConfig.cellConfig = cellConfig;
        sectionLearningConfig.sectionHeaderTitle = @"今日学习计划";
        [_tableModel addNewSectionConfig:sectionLearningConfig];
        [_tableModel appendDataAsNewSection:@[self.todaysPlan.learningPlan]];
    }
    if (self.todaysPlan.reviewPlan.count > 0) {
        HKVTableViewSectionConfig *sectionReviewingConfig = [[HKVTableViewSectionConfig alloc]init];
        sectionReviewingConfig.cellConfig = cellConfig;
        sectionReviewingConfig.sectionHeaderTitle = @"今日复习计划";
        [_tableModel addNewSectionConfig:sectionReviewingConfig];
        [_tableModel appendDataAsNewSection:self.todaysPlan.reviewPlan.array];
    }
}

- (void)tableViewModel:(HKVDefaultTableViewModel *)model didSelectRowData:(WordList *)wl atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *params = nil;
    params = @{@"wordList":wl};
    [self.navigationController.v_navigationManager commonPushURL:[HKVNavigationRouteConfig sharedInstance].wordListVC params:params animate:YES];
}

#pragma mark - actions
- (void)revealLeftSidebar:(id)sender {
    [((AppDelegate *)[UIApplication sharedApplication].delegate).viewDeckController toggleLeftViewAnimated:YES];
}

- (void)refreshHintView
{
    NSUInteger wordListCount = [WordList MR_countOfEntities];
    
    
    self.view.hidden = NO;
    if (wordListCount == 0) {
        self.hintView.text = @"还没有词汇列表哦~\n点击左上角按钮选择添加词汇列表即可添加!";
    }else if (self.todaysPlan.learningPlan == nil && self.todaysPlan.reviewPlan.count == 0) {
        self.hintView.text = @"恭喜你已经完成今日计划了!";
    }else{
        self.hintView.hidden = YES;
    }
}

- (void)shouldRefreshPlan:(NSNotification *)notification
{
    self.todaysPlan = [[PlanMaker sharedInstance]todaysPlan];
    [self configTableView];
}



@end
