//
//  HKVDefaultTableViewDelegate.m
//  Vocabulary
//
//  Created by 缪和光 on 3/01/2015.
//  Copyright (c) 2015 缪和光. All rights reserved.
//

#import "HKVDefaultTableViewModel.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation HKVTableViewCellConfig

- (id)copyWithZone:(NSZone *)zone {
    HKVTableViewCellConfig *dup = [[HKVTableViewCellConfig alloc]init];
    dup.className = self.className;
    dup.xibName = self.xibName;
    return dup;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _className = NSStringFromClass([UITableViewCell class]);
    }
    return self;
}

@end

@implementation HKVTableViewSectionConfig

- (id)copyWithZone:(NSZone *)zone {
    HKVTableViewSectionConfig *dup = [[HKVTableViewSectionConfig alloc]init];
    dup.cellConfig = self.cellConfig;
    dup.sectionFooterView = self.sectionFooterView;
    dup.sectionHeaderView = self.sectionHeaderView;
    dup.sectionFooterTitle = self.sectionFooterTitle;
    dup.sectionHeaderTitle = self.sectionHeaderTitle;
    return dup;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellConfig = [[HKVTableViewCellConfig alloc]init];
    }
    return self;
}

@end

@interface HKVDefaultTableViewModel()

@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *sectionDataArray;
@property (nonatomic, strong) NSMutableArray<HKVTableViewSectionConfig *> *sectionConfigArray;
@property (nonatomic, strong) HKVTableViewSectionConfig *defaultSectionConfig;

@end

@implementation HKVDefaultTableViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sectionDataArray = [[NSMutableArray alloc]init];
        _sectionConfigArray = [[NSMutableArray alloc]init];
        _defaultSectionConfig = [[HKVTableViewSectionConfig alloc]init];
        _defaultSectionConfig.cellConfig.className = NSStringFromClass([UITableViewCell class]);
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
}

- (void)addNewSectionConfig:(HKVTableViewSectionConfig *)config {
    [_sectionConfigArray addObject:config];
}
- (void)addSectionConfigs:(NSArray *)configObjs {
    for (HKVTableViewSectionConfig *config in configObjs) {
        if ([config isKindOfClass:[HKVTableViewSectionConfig class]]) {
            [_sectionConfigArray addObject:config];
        }
    }
}
- (void)resetSectionConfig {
    [_sectionConfigArray removeAllObjects];
}

- (void)appendData:(NSArray *)data inSection:(NSUInteger)sectionNum {
    if(sectionNum > _sectionDataArray.count) {
//        DDLogError(@"section number is invalid");
        return;
    }
    if (sectionNum == _sectionDataArray.count) {
        NSMutableArray *newSectionData = [[NSMutableArray alloc]init];
        [_sectionDataArray addObject:newSectionData];
    }
    NSMutableArray *sectionData = _sectionDataArray[sectionNum];
    [sectionData addObjectsFromArray:data];
    [self.tableView reloadData];
}
- (void)replaceData:(NSArray *)data inSection:(NSUInteger)sectionNum {
    if(sectionNum > _sectionDataArray.count) {
//        DDLogError(@"section number is invalid");
        return;
    }
    if (sectionNum == _sectionDataArray.count) {
        NSMutableArray *newSectionData = [[NSMutableArray alloc]init];
        [_sectionDataArray addObject:newSectionData];
    }
    NSMutableArray *sectionData = _sectionDataArray[sectionNum];
    [sectionData removeAllObjects];
    [sectionData addObjectsFromArray:data];
    [self.tableView reloadData];
}

- (void)appendDataAsNewSection:(NSArray *)data {
    [_sectionDataArray addObject:[data mutableCopy]]; // 确保是mutable
    [self.tableView reloadData];
}

- (void)removeDataAtSectionNum:(NSUInteger)sectionNum {
    if(sectionNum >= _sectionDataArray.count) {
//        DDLogError(@"section number is invalid");
        return;
    }
    [_sectionDataArray removeObjectAtIndex:sectionNum];
    [self.tableView reloadData];
}

- (void)clearData {
    [_sectionDataArray removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - UITableView delegate and data source

- (HKVTableViewSectionConfig *)_sectionConfigForSection:(NSInteger)section {
    // 如果有配置过section，则取配置，如果没有，则使用默认配置
    HKVTableViewSectionConfig *sectionConfig = section < _sectionConfigArray.count ? _sectionConfigArray[section] : _defaultSectionConfig;
    return sectionConfig;
}

- (HKVTableViewCellConfig *)_cellConfigForIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    // 如果有配置过section，则取配置，如果没有，则使用默认配置
    HKVTableViewCellConfig *cellConfig = ((HKVTableViewSectionConfig *)[self _sectionConfigForSection:section]).cellConfig;
    
    // 询问delegate是否要做调整
    if ([self.delegate respondsToSelector:@selector(tableViewModel:modifyCellConfigAtIndexPath:originalCellConfig:)]) {
        cellConfig = [self.delegate tableViewModel:self
                       modifyCellConfigAtIndexPath:indexPath
                                originalCellConfig:cellConfig];
    }
    // 容错处理
    if (!cellConfig) {
        cellConfig = _defaultSectionConfig.cellConfig;
    }
    return cellConfig;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate numberOfSectionsInTableView:tableView];
    }
    return _sectionDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView numberOfRowsInSection:section];
    }
    if(section >= _sectionDataArray.count) {
//        DDLogError(@"section number is invalid");
        return 0;
    }
    NSMutableArray *sectionData = _sectionDataArray[section];
    return sectionData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    HKVTableViewCellConfig *cellConfig = [self _cellConfigForIndexPath:indexPath];
    
    Class cellClass = NSClassFromString(cellConfig.className);
    if (!cellClass) {
//        DDLogError(@"class for name %@ doesn't exist", cellConfig.className);
        return nil; // 自然崩溃
    }
    NSString *reuseIdentifier = cellConfig.reuseIdentifier;
    if (reuseIdentifier == nil) {
        reuseIdentifier = [NSString stringWithFormat:@"$_%@",cellConfig.className];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        if (cellConfig.xibName) {
            cell = [[NSBundle mainBundle]loadNibNamed:cellConfig.xibName owner:nil options:nil][0];
        } else {
            cell = [[cellClass alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        if ([cell respondsToSelector:@selector(setModel:)]) {
            [cell performSelector:@selector(setModel:) withObject:self];
        }
    }
    id data = _sectionDataArray[section][row]; //如果越界，则自然崩溃
    if ([cell respondsToSelector:@selector(bindData:)]) {
        [cell performSelector:@selector(bindData:) withObject:data];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static CGFloat _defaultHeight = 44.0;
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    HKVTableViewCellConfig *cellConfig = [self _cellConfigForIndexPath:indexPath];
    
    Class<HKVDefaultTableViewModelCellProtocol> cellClass = NSClassFromString(cellConfig.className);
    if (!cellClass) {
//        DDLogError(@"class for name %@ doesn't exist", cellConfig.className);
        return _defaultHeight;
    }
    if ([((NSObject *)cellClass)respondsToSelector:@selector(heightForData:)]) {
        NSInteger row = indexPath.row;
        NSInteger section = indexPath.section;
        id data = _sectionDataArray[section][row];
        return [cellClass heightForData:data];
    };
    return _defaultHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    id data = _sectionDataArray[section][row];
    if ([self.delegate respondsToSelector:@selector(tableViewModel:didSelectRowData:atIndexPath:)]) {
        [self.delegate tableViewModel:self didSelectRowData:data atIndexPath:indexPath];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView titleForHeaderInSection:section];
    }
    HKVTableViewSectionConfig *sectionConfig = [self _sectionConfigForSection:section];
    return sectionConfig.sectionHeaderTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView titleForFooterInSection:section];
    }
    HKVTableViewSectionConfig *sectionConfig = [self _sectionConfigForSection:section];
    return sectionConfig.sectionFooterTitle;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView viewForHeaderInSection:section];
    }
    HKVTableViewSectionConfig *sectionConfig = [self _sectionConfigForSection:section];
    return sectionConfig.sectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView viewForFooterInSection:section];
    }
    HKVTableViewSectionConfig *sectionConfig = [self _sectionConfigForSection:section];
    return sectionConfig.sectionFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView heightForHeaderInSection:section];
    }
    UIView *headerView = [self tableView:tableView viewForHeaderInSection:section];
    if (!headerView) {
        return UITableViewAutomaticDimension;
    }
    return CGRectGetHeight(headerView.frame);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView heightForFooterInSection:section];
    }
    UIView *footerView = [self tableView:tableView viewForFooterInSection:section];
    if (!footerView) {
        return UITableViewAutomaticDimension;
    }
    return CGRectGetHeight(footerView.frame);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [(id<UITableViewDelegate,UITableViewDataSource>)self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

@end
