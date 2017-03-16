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

@interface ImportingWebServer()

@property (nonatomic, strong) NSBundle *siteBundle;

@end

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
    self.siteBundle = siteBundle;
    
    [self addGETHandlerForBasePath:@"/" directoryPath:[siteBundle resourcePath] indexFilename:@"index.html" cacheAge:3600 allowRangeRequests:NO];
    
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
    NSString *isYAML = request.arguments[@"isYAML"];
    
    if ([self.importingDelegate respondsToSelector:@selector(webServerBeginsImportingWords:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.importingDelegate webServerBeginsImportingWords:self];
        });
    }
    
    void (^completionBlock)(NSError *error) = ^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.importingDelegate respondsToSelector:@selector(webServer:finishedImportingWithError:)]) {
                [self.importingDelegate webServer:self finishedImportingWithError:error];
            }
            if (error) {
                respBlock([GCDWebServerDataResponse responseWithJSONObject:@{@"error":[error localizedDescription]}]);
            } else {
                NSString *successHTMLPath = [self.siteBundle pathForResource:@"success" ofType:@"html"];
                NSData *htmlData = [[NSFileManager defaultManager]contentsAtPath:successHTMLPath];
                NSString *html = [[NSString alloc]initWithData:htmlData encoding:NSUTF8StringEncoding];
                respBlock([GCDWebServerDataResponse responseWithHTML:html]);
            }
        });
    };

    
    if([isYAML isEqualToString:@"on"]) {
        [WordListManager createWordListAsyncWithTitle:title yamlContent:content progressBlock:nil completion:completionBlock];
    } else {
        NSSet *wordSet = [WordListManager wordSetFromContent:content];
        
        [WordListManager createWordListAsyncWithTitle:title wordSet:wordSet completion:completionBlock];
    }
    
    
}

@end
