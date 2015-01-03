//
//  HKVDefaultTableViewDelegate.h
//  Vocabulary
//
//  Created by 缪和光 on 3/01/2015.
//  Copyright (c) 2015 缪和光. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKVTableViewCellConfig : NSObject<NSCopying>

@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *xibName;

@end

@interface HKVTableViewSectionConfig : NSObject<NSCopying>

@property (nonatomic, copy) HKVTableViewCellConfig *cellConfig;
@property (nonatomic, copy) NSString *sectionHeaderTitle;
@property (nonatomic, strong) UIView *sectionHeaderView;
@property (nonatomic, copy) NSString *sectionFooterTitle;
@property (nonatomic, strong) UIView *sectionFooterView;

@end

@class HKVDefaultTableViewModel;
@protocol HKVDefaultTableViewModelDelegate <NSObject>

@optional
- (void)tableViewModel:(HKVDefaultTableViewModel *)model
      didSelectRowData:(id)rowModel
           atIndexPath:(NSIndexPath *)indexPath;

- (HKVTableViewCellConfig *)tableViewModel:(HKVDefaultTableViewModel *)model
               modifyCellConfigAtIndexPath:(NSIndexPath *)indexPath
                        originalCellConfig:(HKVTableViewCellConfig *)config;

@end

@protocol HKVDefaultTableViewModelCellProtocol <NSObject>

@optional
- (void)bindData:(id)data;
- (void)setModel:(HKVDefaultTableViewModel *)model;
+ (CGFloat)heightForData:(id)data;

@end

// 只对本工程用到的一些东西进行封装
@interface HKVDefaultTableViewModel : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id<HKVDefaultTableViewModelDelegate> delegate;

- (void)addNewSectionConfig:(HKVTableViewSectionConfig *)config;
- (void)addSectionConfigs:(NSArray *)configObjs; //Array<SectionConfig>
- (void)resetSectionConfig;

- (void)appendData:(NSArray *)data atSectionNum:(NSUInteger)sectionNum;
- (void)replaceData:(NSArray *)data atSectionNum:(NSUInteger)sectionNum;
- (void)appendDataAsNewSection:(NSArray *)data;
- (void)removeDataAtSectionNum:(NSUInteger)sectionNum;
- (void)clearData;

@end
