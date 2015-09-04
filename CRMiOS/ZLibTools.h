//
//  ZLibTools.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 6/18/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <zlib.h>

@interface ZLibTools : NSObject

+ (NSData *)zlibInflate:(NSData *)src;
+ (NSData *)zlibDeflate:(NSData *)src;

@end
