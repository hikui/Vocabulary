//
//  CibaXMLParser.m
//  Vocabulary
//
//  Created by 缪 和光 on 12-10-19.
//  Copyright (c) 2012年 缪和光. All rights reserved.
//

#import "CibaXMLParser.h"
#import "TouchXML.h"

@implementation CibaXMLParser

/**
 result format:
 {
 key:@"word",
 psEN:@"xxx", //音标
 psUS:@"yyy",
 pronounceEN:@"xxxxx",
 pronounceUS:@"yyyyy",
 acceptation:@"adj.\nxxxxx\nadv.\ndddddd",
 sentence:@"xxxxx\n中文解释\nyyyyy\n中文解释2"
 }
 */
+ (NSDictionary *)parseWithXMLString:(NSString *)str
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc]init];
    CXMLDocument *document = [[CXMLDocument alloc]initWithXMLString:str options:0 error:nil];
    NSArray *keyArray = [document nodesForXPath:@"//key" error:nil];
    [resultDict setObject:[[keyArray objectAtIndex:0]stringValue] forKey:@"key"];
    NSArray *psArray = [document nodesForXPath:@"//ps" error:nil];
    [resultDict setObject:[[psArray objectAtIndex:0]stringValue] forKey:@"psEN"];
    [resultDict setObject:[[psArray objectAtIndex:1]stringValue] forKey:@"psUS"];
    NSArray *voiceArray = [document nodesForXPath:@"//pron" error:nil];
    [resultDict setObject:[[voiceArray objectAtIndex:0]stringValue] forKey:@"pronounceEN"];
    [resultDict setObject:[[voiceArray objectAtIndex:1]stringValue] forKey:@"pronounceUS"];
    NSArray *posArray = [document nodesForXPath:@"//pos" error:nil];
    NSArray *acceptationArray = [document nodesForXPath:@"//acceptation" error:nil];
    NSMutableString *jointAcceptation = [[NSMutableString alloc]init];
    for (int i=0; i<posArray.count; i++) {
        NSString *tmpPos = [[posArray objectAtIndex:i]stringValue];
        NSString *tmpAcceptation = [[acceptationArray objectAtIndex:i]stringValue];
        [jointAcceptation appendFormat:@"%@ %@",tmpPos,tmpAcceptation];
    }
    [resultDict setObject:jointAcceptation forKey:@"acceptation"];
    //例句
    NSArray *sentenceOriArray = [document nodesForXPath:@"//sent/orig" error:nil];
    NSArray *transArray = [document nodesForXPath:@"//sent/trans" error:nil];
    NSMutableString *jointSentence = [[NSMutableString alloc]init];
    for (int i=0; i<sentenceOriArray.count; i++) {
        NSString *tmpSencenceOri = [[sentenceOriArray objectAtIndex:i]stringValue];
        NSString *tmpTrans = [[transArray objectAtIndex:i]stringValue];
        [jointSentence appendFormat:@"%@%@",tmpSencenceOri,tmpTrans];
    }
    [resultDict setObject:jointSentence forKey:@"sentence"];
    return resultDict;
}

@end
