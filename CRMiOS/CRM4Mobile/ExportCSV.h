//
//  ExportCSV.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 3/21/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "Subtype.h"
#import "LayoutPageManager.h"
#import "UITools.h"

@interface ExportCSV : NSObject
+(void)writeFile:(NSString *)fullPath Data:(NSArray *)data type:(NSObject <Subtype>*)type ;
+ (NSArray *)reloadData:(NSArray *)datas;
@end
