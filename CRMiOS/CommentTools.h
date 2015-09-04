//
//  CommentTools.h
//  CRMiOS
//
//  Created by Sy Pauv on 3/29/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentTools : NSObject
+ (NSArray *)splitLines:(NSString *)text offset:(int)offset width:(int)width;
+ (NSArray *)splitLinesWithNL:(NSString *)text offset:(int)offset width:(int)width;
@end
