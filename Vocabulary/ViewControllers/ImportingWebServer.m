//
//  ImportingWebServer.m
//  Vocabulary
//
//  Created by Heguang Miao on 18/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import "ImportingWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerURLEncodedFormRequest.h"
#import "WordListManager.h"

@implementation ImportingWebServer

- (instancetype)init {
    self = [super init];
    if (self) {
        if (![self configRoute]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)configRoute {
    NSBundle *siteBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]pathForResource:@"ImportingSite" ofType:@"bundle"]];
    if (siteBundle == nil) {
        return NO;
    }
    
    [self addGETHandlerForBasePath:@"/" directoryPath:[siteBundle resourcePath] indexFilename:nil cacheAge:3600 allowRangeRequests:NO];
    
    __weak typeof(self) weakSelf = self;
    
    [self addHandlerForMethod:@"POST" path:@"/wordlist/create" requestClass:[GCDWebServerURLEncodedFormRequest class] asyncProcessBlock:^(GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        [weakSelf POST_wordlist_create:(GCDWebServerURLEncodedFormRequest *)request respBlock:completionBlock];
    }];
    
    return YES;
}

- (void)POST_wordlist_create:(GCDWebServerURLEncodedFormRequest *)request respBlock:(GCDWebServerCompletionBlock)respBlock{
    DDLogDebug(@"%@",request.arguments);
//    respBlock([GCDWebServerDataResponse responseWithText:@"abcabc"]);
    NSString *title = request.arguments[@"title"];
    NSString *content = request.arguments[@"words"];
    NSSet *wordSet = [WordListManager wordSetFromContent:content];
    
    if ([self.importingDelegate respondsToSelector:@selector(webServerBeginsImportingWords:)]) {
        [self.importingDelegate webServerBeginsImportingWords:self];
    }
    
    
    
    [WordListManager createWordListAsyncWithTitle:title wordSet:wordSet completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.importingDelegate respondsToSelector:@selector(webServer:finishedImportingWithError:)]) {
                [self.importingDelegate webServer:self finishedImportingWithError:error];
            }
            if (error) {
                respBlock([GCDWebServerDataResponse responseWithJSONObject:@{@"error":[error localizedDescription]}]);
            } else {
                respBlock([GCDWebServerDataResponse responseWithJSONObject:@{@"error":[NSNull null]}]);
            }
        });
        
    }];
}

@end
