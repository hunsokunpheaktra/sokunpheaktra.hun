//
//  CommentTools.m
//  CRMiOS
//
//  Created by Sy Pauv on 3/29/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "CommentTools.h"
#define FEED_FONT_SIZE 14

@implementation CommentTools
+ (NSArray *)splitLinesWithNL:(NSString *)text offset:(int)offset width:(int)width {
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:1];
    if (text == nil) {
        return lines;
    }
    while (YES) {
        NSRange rNewline = [text rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet]];
        if (rNewline.location == NSNotFound) {
            break;
        }
        [lines addObjectsFromArray:[CommentTools splitLines:[text substringToIndex:rNewline.location] offset:offset width:width]];
        text = [text substringFromIndex:rNewline.location + 1];
    }
    [lines addObjectsFromArray:[CommentTools splitLines:text offset:(int)offset width:width]];
    return lines;
}

+ (NSArray *)splitLines:(NSString *)text offset:(int)offset width:(int)width {
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:1];
    if (text == nil) {
        return lines;
    }
    NSCharacterSet *wordSeparators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange rPrevious = NSMakeRange(0, 0);
    while (YES) {
        // determine the next whitespace word separator position
        NSRange rWhitespace = [text rangeOfCharacterFromSet: wordSeparators options:NSCaseInsensitiveSearch range:NSMakeRange(rPrevious.location + rPrevious.length, [text length] - rPrevious.location - rPrevious.length)];
        NSString *textTest;
        if (rWhitespace.location == NSNotFound) {
            textTest = text;
        } else {
            textTest = [[text substringToIndex:rWhitespace.location] stringByTrimmingCharactersInSet:wordSeparators];
        }
        CGSize sizeTest = [textTest sizeWithFont:[UIFont systemFontOfSize:FEED_FONT_SIZE] forWidth: 4000 lineBreakMode: UILineBreakModeWordWrap];
        if (sizeTest.width + offset > width) {
            if (rPrevious.length == 0) {
                // case of a very long word that has to be cut
                while (YES) {
                    textTest = [textTest substringToIndex:[textTest length] - 1];
                    sizeTest = [textTest sizeWithFont:[UIFont systemFontOfSize:FEED_FONT_SIZE] forWidth: 4000 lineBreakMode: UILineBreakModeWordWrap];
                    if (sizeTest.width + offset <= width || [textTest length] == 0) {
                        [lines addObject:textTest];
                        text = [text substringFromIndex:[textTest length]];
                        rPrevious = NSMakeRange(0, 0);
                        offset = 0;
                        break;
                    }
                }
            } else {
                [lines addObject:[[text substringToIndex:rPrevious.location] stringByTrimmingCharactersInSet:wordSeparators]];
                text = [[text substringFromIndex:rPrevious.location] stringByTrimmingCharactersInSet:wordSeparators];
                rPrevious = NSMakeRange(0, 0);
                offset = 0;
            }
        } else {
            rPrevious = rWhitespace;
        }
        if (rPrevious.location == NSNotFound) {
            break;
        }
    }
    
    [lines addObject: [text stringByTrimmingCharactersInSet:wordSeparators]];
    
    return lines;
}

@end
