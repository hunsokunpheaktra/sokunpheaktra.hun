//
//  OutgoingResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "OutgoingResponseParser.h"


@implementation OutgoingResponseParser

@synthesize entity;
@synthesize currentItem;
@synthesize item;
@synthesize isDelete;
@synthesize incomplete;

- (id)initWithEntity:(NSString *)newEntity item:(Item *)newItem isDelete:(BOOL)newIsDelete incomplete:(BOOL)newIncomplete {
    self = [super init];
    self.entity = newEntity;
    self.item = newItem;
    self.isDelete = [NSNumber numberWithBool:newIsDelete];
    self.incomplete = [NSNumber numberWithBool:newIncomplete];
    self.currentItem = [[NSMutableDictionary alloc] initWithCapacity:1];
    self.lastPage = NO;
    return self;
}

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    if (level==5 && [tag isEqualToString:entity]) {
        [self oneMoreItem];
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithCapacity:1];
        [tmp setObject:[item.fields objectForKey:@"gadget_id"] forKey:@"gadget_id"];
        [tmp setObject:[self.currentItem objectForKey:@"Id"] forKey:@"Id"];
        [tmp setObject:[NSNull null] forKey:@"Error"];
        Item *tmpItem = [[Item alloc] init:entity fields:tmp];
        if ([self.isDelete boolValue]) {
        
            [[Database getInstance] remove:entity column:@"Id" value:[self.currentItem objectForKey:@"Id"]];
    
        } else {
            
            NSString *previousId = [item.fields objectForKey:@"Id"];
            [EntityManager update:tmpItem modifiedLocally:[self.incomplete boolValue] ? YES : NO];
            if ([previousId hasPrefix:@"#"]) {
                // update the id for related items
                for (Relation *relation in [Relation getEntityRelations:self.entity]) {
                    if ([relation.destEntity isEqualToString:self.entity]) {
                        NSString *otherField = [relation srcKey];
                        NSString *otherEntity = [relation srcEntity];
                        NSString *newId = [self.currentItem objectForKey:@"Id"];
                        [[Database getInstance] execSql:[NSString stringWithFormat:@"UPDATE %@ SET %@ = ? WHERE %@ = ?", otherEntity, otherField, otherField, nil] params:[NSArray arrayWithObjects:newId, previousId, nil]];
                    }
                }
                
                // update the parent_oid for sublist item   
                for (NSString *sublist in [[Configuration getInfo:entity] getSublists]){
                    NSString *newParentId = [self.currentItem objectForKey:@"Id"];
                       [[Database getInstance] execSql:[NSString stringWithFormat:@"UPDATE %@_%@ SET parent_oid = ? WHERE parent_oid = ?", self.entity, sublist, nil] params:[NSArray arrayWithObjects:newParentId, previousId, nil]];
                }
            }
        }
        [tmpItem release];
        [tmp release];
        [self.currentItem removeAllObjects];
    }
    if (level==6) {
        [self.currentItem setObject:value forKey:tag];
    }
}

- (void) dealloc
{
    [self.currentItem release];
    [super dealloc];
}


@end
