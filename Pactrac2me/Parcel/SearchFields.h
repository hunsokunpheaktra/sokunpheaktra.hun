//
//  SearchFields.h
//  Parcel
//
//  Created by Gaeasys on 12/14/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"
@interface SearchFields : NSObject


+ (void)initTable;
+ (void)initDatas;
+ (void)save:(NSString *)value;
+ (NSArray *)read;

@end
