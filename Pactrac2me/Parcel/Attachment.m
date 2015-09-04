//
//  AttachmentManager.m
//  Parcel
//
//  Created by Gaeasys on 1/7/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "Attachment.h"
#import "DatabaseManager.h"

@implementation Attachment

static NSMutableArray *columns;

+ (NSArray *)list:(NSString *)entity criterias:(NSDictionary *)criterias {
    
    NSMutableArray* listRecord = [[NSMutableArray alloc] init];
    NSArray *records = [[DatabaseManager getInstance] select:entity fields:columns criterias:criterias order:nil ascending:true];
    
    Item* item;
    for (NSDictionary*fields in records) {
        item = [[Item alloc] init:entity fields:fields];
        [listRecord addObject:item];
        [item release];
    }
    
    return listRecord;
}


+ (void)insert:(Item *)item modifiedLocally:(BOOL)modifiedLocally {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    
    if(![[tmp valueForKey:@"modified"] isEqualToString:@"2"]){
        [tmp setValue:(modifiedLocally ? @"1" : @"0") forKey:@"modified"];
    }
    
    [[DatabaseManager getInstance] insert:item.entity item:tmp];
    
}


+ (int)getCount:(NSString *)entity{
    int count = [[[DatabaseManager getInstance] select:entity fields:[NSArray arrayWithObject:@"local_id"] criterias:nil order:nil ascending:YES ] count];
    return count;
}

+ (Item *)find:(NSString *)entity column:(NSString *)column value:(NSString *)value{
    
    
    NSArray *results = [[DatabaseManager getInstance] select:entity fields:columns column:column value:value order:nil ascending:NO];
    
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


+ (void)update:(Item *)item modifiedLocally:(BOOL)modifiedLocally {
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithDictionary:item.fields];
    Item *itmp =[Attachment find:item.entity column:@"Id" value:[item.fields valueForKey:@"Id"]];
    
    if(![[itmp.fields valueForKey:@"modified"] isEqualToString:@"2"]){
        [tmp setValue:(modifiedLocally ? @"1" : @"0") forKey:@"modified"];
    }
    if ([tmp objectForKey:@"local_id"] != Nil) {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"local_id" value:[tmp objectForKey:@"local_id"]];
    } else {
        [[DatabaseManager getInstance] update:item.entity item:tmp column:@"Id" value:[tmp objectForKey:@"Id"]];
    }
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

+ (void)initData {
    
}

+ (void)initTable{
    
    DatabaseManager *database = [DatabaseManager getInstance];
    columns = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:1];
    
    [columns addObject:@"local_id"];
    [types addObject:@"INTEGER PRIMARY KEY"];
    [columns addObject:@"id"];
    [types addObject:@"TEXT"];
    [columns addObject:@"modified"];
    [types addObject:@"TEXT"];
    [columns addObject:@"deleted"];
    [types addObject:@"TEXT"];
    [columns addObject:@"error"];
    [types addObject:@"TEXT"];
    [columns addObject:@"parentEntity"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Name"];
    [types addObject:@"TEXT"];
    [columns addObject:@"Body"];
    [types addObject:@"TEXT"];
    [columns addObject:@"ParentId"];
    [types addObject:@"TEXT"];
    
    [database check:@"Attachment" columns:columns types:types];
    [database createIndex:@"Attachment" column:@"local_id" unique:true];
    
    [types release];
    
}



@end
