//
//  ImportingWebServer.h
//  Vocabulary
//
//  Created by Heguang Miao on 18/01/2016.
//  Copyright © 2016 缪和光. All rights reserved.
//

#import <GCDWebServer/GCDWebServer.h>

@class ImportingWebServer;
@protocol ImportingWebServerDelegate<NSObject>

- (void)webServerBeginsImportingWords:(ImportingWebServer *)webSrver;
- (void)webServer:(ImportingWebServer *)webServer finishedImportingWithError:(NSError *)error;

@end

@interface ImportingWebServer : GCDWebServer

@property (nonatomic, weak) id<ImportingWebServerDelegate> importingDelegate;

@end
