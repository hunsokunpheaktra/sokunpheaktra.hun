//
//  AttachmentEntitymanager.m
//  Pactrac2me
//
//  Created by Sy Pauv on 1/24/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "AttachmentEntitymanager.h"
#import "DatabaseManager.h"

@implementation AttachmentEntitymanager

static NSMutableArray *fields;

+ (void)initTable{
    
    DatabaseManager *database = [DatabaseManager getInstance];
    fields = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    
    [fields addObject:@"local_id"];
    [types addObject:@"INTEGER PRIMARY KEY"];
    [fields addObject:@"Id"];
    [types addObject:@"TEXT"];
    [fields addObject:@"modified"];
    [types addObject:@"TEXT"];
    [fields addObject:@"deleted"];
    [types addObject:@"TEXT"];
    [fields addObject:@"error"];
    [types addObject:@"TEXT"];
    [fields addObject:@"body"];
    [types addObject:@"TEXT"];
    [fields addObject:@"ParentId"];
    [types addObject:@"TEXT"];
    [fields addObject:@"Description"];
    [types addObject:@"TEXT"];
    
    [database check:@"Attachment" columns:fields types:types];
    [database createIndex:@"Parcel" column:@"local_id" unique:true];
    
    [types release];
    
}

+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally {
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:item.fields];
    if(![[tmp valueForKey:@"modified"] isEqualToString:@"2"]){
        [tmp setValue:(modifiedLocally ? @"1" : @"0") forKey:@"modified"];
    }
    [[DatabaseManager getInstance] insert:item.entity item:tmp];
}

+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value{

    NSArray *results = [[DatabaseManager getInstance] select:entity fields:fields column:column value:value order:nil ascending:NO];
    Item *item = nil;
    if ([results count] > 0) {
        NSDictionary *itemFields = [results objectAtIndex:0];
        item = [[Item alloc] init:entity fields:itemFields];
    }
    [results release];
    return item;
}

+ (Item *)find:(NSString *)entity criterias:(NSDictionary *)criterias{
    return nil;
}

+ (NSMutableDictionary *)findAttachmentByParentId:(NSString *)pId{
    
    NSMutableDictionary* criteria = [[[NSMutableDictionary alloc] init] autorelease];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:pId] autorelease] forKey:@"ParentId"];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:@"deleted"];
    NSArray* list = [NSArray arrayWithArray:[self list:@"Attachment" criterias:criteria]];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    for (Item *item in list) {
        if ([item.fields objectForKey:@"Description"] != nil) {
            [dic setObject:item forKey:[item.fields objectForKey:@"Description"]];
        }
    }
    return dic;
}



+ (NSArray *)list:(NSString *)entity criterias:(NSDictionary *)criterias {
    
    NSMutableArray* listRecord = [[NSMutableArray alloc] init];
    NSArray *records = [[DatabaseManager getInstance] select:entity fields:fields criterias:criterias order:nil ascending:false];
    Item* item;
    for (NSDictionary*fields in records) {
        item = [[Item alloc] init:entity fields:fields];
        [listRecord addObject:item];
        [item release];
    }
    return listRecord;
}

+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    Item *itmp =[AttachmentEntitymanager find:item.entity column:@"local_id" value:[item.fields valueForKey:@"local_id"]];
    if(![[itmp.fields valueForKey:@"modified"] isEqualToString:@"2"]){
        [tmp setValue:(modifiedLocally ? @"1" : @"0") forKey:@"modified"];
    }
    [[DatabaseManager getInstance] update:item.entity item:tmp column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    [tmp release];
}

+ (void)remove:(Item *)item {
    
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    if ([tmp objectForKey:@"Id"] == Nil) {
        [[DatabaseManager getInstance] remove:item.entity column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    } else {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"id" value:[tmp objectForKey:@"id"]];
    }
    [tmp release];
}

+ (NSMutableDictionary *)newAttachment{
    NSArray *allValues = @[@"",@"",@"",@"",@"",@"",@""];
    NSArray *cols= @[ @"Id",@"modified",@"deleted",@"error",@"body",@"ParentId",@"Description"];
    return [NSMutableDictionary dictionaryWithObjects:allValues forKeys:cols];
}

@end
