//
//  VNavigationCommonURL.m
//  Vocabulary
//
//  Created by 缪和光 on 12/22/14.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "VNavigationRouteConfig.h"
#import "VNavigationManager.h"
#import <objc/runtime.h>
#import "ExamViewController.h"
#import "ShowWrongWordsViewController.h"
#import "ExamTypeChoiceViewController.h"
#import "CreateWordListViewController.h"
#import "ExistingWordListsViewController.h"
#import "LearningBackboneViewController.h"
#import "PlanningViewController.h"
#import "PreferenceViewController.h"
#import "SearchWordViewController.h"
#import "WordDetailViewController.h"
#import "WordListFromDiskViewController.h"
#import "WordListViewController.h"
#import "NoteViewController.h"
#import "EditWordDetailViewController.h"

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "@";
}

@interface VNavigationRouteConfig ()

@property (nonatomic, strong, readwrite) NSURL *examVC;
@property (nonatomic, strong, readwrite) NSURL *showWrongWordsVC;
@property (nonatomic, strong, readwrite) NSURL *examTypeChoiceVC;
@property (nonatomic, strong, readwrite) NSURL *learningBackboneVC;
@property (nonatomic, strong, readwrite) NSURL *planningVC;
@property (nonatomic, strong, readwrite) NSURL *createWordListVC;
@property (nonatomic, strong, readwrite) NSURL *exisingWordsListsVC;
@property (nonatomic, strong, readwrite) NSURL *PreferenceVC;
@property (nonatomic, strong, readwrite) NSURL *searchWordVC;
@property (nonatomic, strong, readwrite) NSURL *wordDetailVC;
@property (nonatomic, strong, readwrite) NSURL *wordListFromDiskVC;
@property (nonatomic, strong, readwrite) NSURL *wordListVC;
@property (nonatomic, strong, readwrite) NSURL *noteVC;
@property (nonatomic, strong, readwrite) NSURL *editWordDetailVC;

@end

@implementation VNavigationRouteConfig

+ (VNavigationRouteConfig *)sharedInstance {
    static VNavigationRouteConfig *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[VNavigationRouteConfig alloc]init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self urlWithPropertyName];
    }
    return self;
}

- (void)urlWithPropertyName {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithCString:propName
                                                        encoding:[NSString defaultCStringEncoding]];
            NSString *propertyType = [NSString stringWithCString:propType
                                                        encoding:[NSString defaultCStringEncoding]];
            if ([propertyType isEqualToString:NSStringFromClass([NSURL class])]) {
                NSString *urlStr = [NSString stringWithFormat:@"vocabulary://viewcontroller/%@",propertyName];
                NSURL *url = [NSURL URLWithString:urlStr];
                [self setValue:url forKey:propertyName];
            }
        }
    }
    free(properties);
}

- (NSDictionary *)route {
    return @{
             self.examVC:@{VNavigationConfigClassNameKey:NSStringFromClass([ExamViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             self.showWrongWordsVC:@{VNavigationConfigClassNameKey:NSStringFromClass([ShowWrongWordsViewController class]),VNavigationConfigXibNameKey:NSStringFromClass([WordListViewController class])},
             
             self.examTypeChoiceVC:@{VNavigationConfigClassNameKey:NSStringFromClass([ExamTypeChoiceViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             self.createWordListVC:@{VNavigationConfigClassNameKey:NSStringFromClass([CreateWordListViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             self.exisingWordsListsVC:@{VNavigationConfigClassNameKey:NSStringFromClass([ExistingWordListsViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             self.learningBackboneVC:@{VNavigationConfigClassNameKey:NSStringFromClass([LearningBackboneViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             self.planningVC:@{VNavigationConfigClassNameKey:NSStringFromClass([PlanningViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             self.PreferenceVC:@{VNavigationConfigClassNameKey:NSStringFromClass([PreferenceViewController class])},
             
             self.searchWordVC:@{VNavigationConfigClassNameKey:NSStringFromClass([SearchWordViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             self.wordDetailVC:@{VNavigationConfigClassNameKey:NSStringFromClass([WordDetailViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             self.wordListFromDiskVC:@{VNavigationConfigClassNameKey:NSStringFromClass([WordListFromDiskViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             self.wordListVC:@{VNavigationConfigClassNameKey:NSStringFromClass([WordListViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             self.noteVC:@{VNavigationConfigClassNameKey:NSStringFromClass([NoteViewController class])},
             
             self.editWordDetailVC:@{VNavigationConfigClassNameKey:NSStringFromClass([EditWordDetailViewController class]),VNavigationConfigXibNameKey:[NSNull null]},
             
             
             };
}

@end
