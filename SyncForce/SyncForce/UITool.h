//
//  UITool.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "DataModel.h"
#import "DataType.h"
#import "EntityInfo.h"
#import <QuartzCore/QuartzCore.h>

@interface UITool : NSObject

+ (void)setupEditCell:(UITableViewCell *)cell fieldsInfo:(Item *)fieldsInfo value:(NSString *)value tag:(int)tag delegate:(NSObject <UITextFieldDelegate> *)delegate isMadatory:(BOOL)madatory;

+ (NSString *)formatDateTime:(Item *)fieldsInfo value:(NSString *)value shortStyle:(BOOL)shortStyle;
+ (void)setupRow:(UITableViewCell*)cell dataModel:(NSObject<DataModel>*)model tag:(int)tag delegate:(NSObject <UITextFieldDelegate> *)delegate;


@end
