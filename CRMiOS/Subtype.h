//
//  Subtype.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/15/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "SublistItem.h"
#import "Sublist.h"

@class Page;

@protocol Subtype <NSObject>

- (NSArray *)sublists;
- (NSString *)getGroupName:(Item *)item;
- (NSString *)getGroupShortName:(Item *)item;
- (NSString *)iconName;
- (NSString *)getDisplayText:(Item *)item;
- (NSString *)getDetailText:(Item *)item;
- (NSString *)getIcon:(Item *)item;
- (BOOL)isMandatory:(NSString *)field;
- (NSArray *)actions;
- (NSString *)getOrderField;
- (BOOL)orderAscending;
- (NSString *)filterField;
- (NSArray *)getFilters:(BOOL)isIphone;
- (NSString *)localizedName;
- (NSString *)localizedPluralName;
- (NSString *)entity;
- (NSString *)name;
- (NSArray *)getCriterias;
- (void)fillItem:(Item *)item;
- (NSObject<Sublist> *)getSublist:(NSString *)sublist;
- (NSArray *)listFields;
- (BOOL)isReadonly:(NSString *)field;
- (NSString *)customName:(NSString *)field;
- (Page *)pdfLayout;
- (BOOL)canCreate;
- (BOOL)enabledRelation:(NSString *)field;

@end
