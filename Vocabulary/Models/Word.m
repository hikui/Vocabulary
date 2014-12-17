//
//  Word.m
//  Vocabulary
//
//  Created by 缪和光 on 2/11/2014.
//  Copyright (c) 2014 缪和光. All rights reserved.
//

#import "Word.h"
#import "Note.h"
#import "PronunciationData.h"
#import "Word.h"
#import "WordList.h"
#import "NSMutableString+HTMLEscape.h"


@implementation Word

@dynamic acceptation;
@dynamic familiarity;
@dynamic hasGotDataFromAPI;
@dynamic key;
@dynamic lastVIewDate;
@dynamic psEN;
@dynamic psUS;
@dynamic sentences;
@dynamic pronunciation;
@dynamic similarWords;
@dynamic wordLists;
@dynamic note;
@dynamic manuallyInput;

- (NSAttributedString *)attributedWordDetail {
    if (![self.hasGotDataFromAPI boolValue] && ![self.manuallyInput boolValue]) {
        return nil;
    }
    
    NSMutableString *confusingWordsStr = [[NSMutableString alloc]init];
    for (Word *aConfusingWord in self.similarWords) {
        [confusingWordsStr appendFormat:@"%@ ",aConfusingWord.key];
    }
    NSMutableString *jointStr = [[NSMutableString alloc]init];
    if (self.psEN.length != 0) {
        [jointStr appendFormat:@"英[%@]\n",self.psEN];
    }
    if (self.psUS.length != 0) {
        [jointStr appendFormat:@"美[%@]\n",self.psUS];
    }
    if (self.similarWords.count != 0) {
        [jointStr appendFormat:@"\n易混淆单词: %@\n\n",confusingWordsStr];
    }
    if (self.acceptation.length != 0) {
        [jointStr appendFormat:@"%@\n",self.acceptation];
    }
    if (self.sentences.length != 0) {
        [jointStr appendFormat:@"%@\n",self.sentences];
    }
//    if (self.similarWords.count == 0) {
//        jointStr = [[NSMutableString alloc]initWithFormat:@"英[%@]\n美[%@]\n%@%@",self.psEN,self.psUS,self.acceptation,self.sentences];
//    }else{
//        jointStr = [[NSMutableString alloc]initWithFormat:@"英[%@]\n美[%@]\n\n易混淆单词: %@\n\n%@%@",self.psEN,self.psUS,confusingWordsStr,self.acceptation,self.sentences];
//    }
    
    [jointStr htmlUnescape];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:jointStr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    if (self.note.textNote.length != 0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle]mutableCopy];
        paragraphStyle.lineSpacing = 10;
        NSAttributedString *noteTitle = [[NSAttributedString alloc]initWithString:@"\n我的笔记\n" attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle}];
        [attr appendAttributedString:noteTitle];
        NSAttributedString *attributedNotes = [[NSAttributedString alloc]initWithString:self.note.textNote attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        [attr appendAttributedString:attributedNotes];
    }
    return attr;
}

@end
