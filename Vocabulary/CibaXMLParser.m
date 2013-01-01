
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
    str = [str stringByReplacingOccurrencesOfString:@"&" withString:@" "]; //不进行这个转义有一定几率出错
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc]init];
    NSError *parseError = nil;
    CXMLDocument *document = [[CXMLDocument alloc]initWithXMLString:str options:0 error:&parseError];
    if (parseError != nil) {
        NSLog(@"parse Error!");
        return nil;
    }
    
    NSArray *posArray = [document nodesForXPath:@"//pos" error:nil];
    NSArray *acceptationArray = [document nodesForXPath:@"//acceptation" error:nil];
    if (acceptationArray.count == 0) {
        return nil; //没有解释
    }
    NSMutableString *jointAcceptation = [[NSMutableString alloc]init];
    for (int i=0; i<posArray.count; i++) {
        NSString *tmpPos = [[posArray objectAtIndex:i]stringValue];
        NSString *tmpAcceptation = [[acceptationArray objectAtIndex:i]stringValue];
        [jointAcceptation appendFormat:@"%@ %@",tmpPos,tmpAcceptation];
    }
    [resultDict setObject:jointAcceptation forKey:@"acceptation"];
    
    NSArray *keyArray = [document nodesForXPath:@"//key" error:nil];
    [resultDict setObject:[[keyArray objectAtIndex:0]stringValue] forKey:@"key"];
    NSArray *psArray = [document nodesForXPath:@"//ps" error:nil];
    if (psArray.count>0) {
        [resultDict setObject:[[psArray objectAtIndex:0]stringValue] forKey:@"psEN"];
        if (psArray.count>1) {
            [resultDict setObject:[[psArray objectAtIndex:1]stringValue] forKey:@"psUS"];
        }   
    }
    
    NSArray *voiceArray = [document nodesForXPath:@"//pron" error:nil];
    if (voiceArray.count>0) {
        [resultDict setObject:[[voiceArray objectAtIndex:0]stringValue] forKey:@"pronounceEN"];
        if (voiceArray.count>1) {
            [resultDict setObject:[[voiceArray objectAtIndex:1]stringValue] forKey:@"pronounceUS"];
        }
    }
    
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

+ (void)fillWord:(Word *)word withResultDict:(NSDictionary *)resultDict
{
    Word *targetWord = word;
    if (resultDict == nil) {
        // error on parsing
        return;
    }
    targetWord.acceptation = [resultDict objectForKey:@"acceptation"];
    targetWord.psEN = [resultDict objectForKey:@"psEN"];
    targetWord.psUS = [resultDict objectForKey:@"psUS"];
    targetWord.sentences = [resultDict objectForKey:@"sentence"];
}


@end
