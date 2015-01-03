//
//  HKVDefaultTableViewDelegate.m
//  Vocabulary
//
//  Created by 缪和光 on 3/01/2015.
//  Copyright (c) 2015 缪和光. All rights reserved.
//

#import "HKVDefaultTableViewModel.h"

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

@property (nonatomic, strong) NSMutableArray *sectionDataArray; //Array<Array>
@property (nonatomic, strong) NSMutableArray *sectionConfigArray; //Array<SectionConfig>
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

- (void)appendData:(NSArray *)data atSectionNum:(NSUInteger)sectionNum {
    if(sectionNum > _sectionDataArray.count) {
        DDLogError(@"section number is invalid");
        return;
    }
    if (sectionNum == _sectionDataArray.count) {
        NSMutableArray *newSectionData = [[NSMutableArray alloc]init];
        [_sectionDataArray addObject:newSectionData];
    }
    NSMutableArray *sectionData = _sectionDataArray[sectionNum];
    [sectionData addObjectsFromArray:data];
}
- (void)replaceData:(NSArray *)data atSectionNum:(NSUInteger)sectionNum {
    if(sectionNum > _sectionDataArray.count) {
        DDLogError(@"section number is invalid");
        return;
    }
    if (sectionNum == _sectionDataArray.count) {
        NSMutableArray *newSectionData = [[NSMutableArray alloc]init];
        [_sectionDataArray addObject:newSectionData];
    }
    NSMutableArray *sectionData = _sectionDataArray[sectionNum];
    [sectionData removeAllObjects];
    [sectionData addObjectsFromArray:data];
}
- (void)removeDataAtSectionNum:(NSUInteger)sectionNum {
    if(sectionNum >= _sectionDataArray.count) {
        DDLogError(@"section number is invalid");
        return;
    }
    [_sectionDataArray removeObjectAtIndex:sectionNum];
}

- (void)clearData {
    [_sectionDataArray removeAllObjects];
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
        return [self.delegate numberOfSectionsInTableView:tableView];
    }
    return _sectionDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        return [self.delegate tableView:tableView numberOfRowsInSection:section];
    }
    if(section >= _sectionDataArray.count) {
        DDLogError(@"section number is invalid");
        return 0;
    }
    NSMutableArray *sectionData = _sectionDataArray[section];
    return sectionData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    HKVTableViewCellConfig *cellConfig = [self _cellConfigForIndexPath:indexPath];
    
    Class cellClass = NSClassFromString(cellConfig.className);
    if (!cellClass) {
        DDLogError(@"class for name %@ doesn't exist", cellConfig.className);
        return nil; // 自然崩溃
    }
    NSString *reuseIdentifier = [NSString stringWithFormat:@"$_%@",cellConfig.className];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[cellClass alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        if ([cell respondsToSelector:@selector(setMode:)]) {
            [cell performSelector:@selector(setMode:) withObject:self];
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
        return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    HKVTableViewCellConfig *cellConfig = [self _cellConfigForIndexPath:indexPath];
    
    Class cellClass = NSClassFromString(cellConfig.className);
    if (!cellClass || cellClass ) {
        DDLogError(@"class for name %@ doesn't exist", cellConfig.className);
        return _defaultHeight;
    }
    if ([((NSObject *)cellClass)respondsToSelector:@selector(heightForData:)]) {
        NSInteger row = indexPath.row;
        NSInteger section = indexPath.section;
        id data = _sectionDataArray[section][row];
        return [[((NSObject *)cellClass) performSelector:@selector(heightForData:) withObject:data]floatValue];
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
        return [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [self.delegate tableView:tableView titleForHeaderInSection:section];
    }
    HKVTableViewSectionConfig *sectionConfig = [self _sectionConfigForSection:section];
    return sectionConfig.sectionHeaderTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        return [self.delegate tableView:tableView titleForFooterInSection:section];
    }
    HKVTableViewSectionConfig *sectionConfig = [self _sectionConfigForSection:section];
    return sectionConfig.sectionFooterTitle;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.delegate tableView:tableView viewForHeaderInSection:section];
    }
    HKVTableViewSectionConfig *sectionConfig = [self _sectionConfigForSection:section];
    return sectionConfig.sectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.delegate tableView:tableView viewForFooterInSection:section];
    }
    HKVTableViewSectionConfig *sectionConfig = [self _sectionConfigForSection:section];
    return sectionConfig.sectionFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.delegate tableView:tableView heightForHeaderInSection:section];
    }
    UIView *headerView = [self tableView:tableView viewForHeaderInSection:section];
    if (!headerView) {
        return UITableViewAutomaticDimension;
    }
    return CGRectGetHeight(headerView.frame);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.delegate tableView:tableView heightForFooterInSection:section];
    }
    UIView *footerView = [self tableView:tableView viewForFooterInSection:section];
    if (!footerView) {
        return UITableViewAutomaticDimension;
    }
    return CGRectGetHeight(footerView.frame);
}

@end
