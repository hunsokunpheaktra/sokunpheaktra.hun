//
//  OutgoingEntityRequest.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "OutgoingEntityRequest.h"


@implementation OutgoingEntityRequest

@synthesize entity;
@synthesize item;
@synthesize isDelete;
@synthesize incomplete;

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject <SOAPListener> *)newListener isDelete:(BOOL)deleteItem {
    self = [super init:newListener];
    self.entity = newEntity;
    self.isDelete = [NSNumber numberWithBool:deleteItem];
    return self;
}

- (NSString *)getAction {
    if ([self.isDelete boolValue]) {
        return @"Delete";
    } else {
        NSString *oid = [self.item.fields objectForKey:@"Id"];
        return (oid == nil || [oid hasPrefix:@"#"]) ? @"Insert" : @"Update";
    } 
}


- (NSString *)getSoapAction {
    
    NSString *entityLowercase = [self.entity lowercaseString];	

    return [NSString stringWithFormat:@"\"document/urn:crmondemand/ws/ecbs/%@/:%@%@\"", entityLowercase, self.entity, [self getAction]];
}

- (void)generateBody:(NSMutableString *)soapMessage {
    
    NSString *action = [self getAction];
    
   	NSString *entityLowercase = [entity lowercaseString];	
    [soapMessage appendFormat:@"<%@%@_Input xmlns=\"urn:crmondemand/ws/ecbs/%@/\">", self.entity, action, entityLowercase];
    [soapMessage appendFormat:@"<ListOf%@>", self.entity];

    [soapMessage appendFormat:@"<%@>", self.entity];
    if ([isDelete boolValue]) {
        [soapMessage appendString:@"<Id>"];
        [soapMessage appendString:@"<![CDATA["];
        [soapMessage appendString:[self.item.fields objectForKey:@"Id"]];
        [soapMessage appendString:@"]]>"];
        [soapMessage appendString:@"</Id>"];
    } else {
        for (NSString *field in [[Configuration getInfo:entity] fields]) {
            if (![RelationManager isCalculated:entity field:field]
                && ![field isEqualToString:@"SalesStage"]) {
                [soapMessage appendFormat:@"<%@>", field];
                NSString *value = [self.item.fields objectForKey:field];
                if (value != nil) {
                    if (![field isEqualToString:@"Id"] && [value hasPrefix:@"#"]) {
                        // check if the corresponding object is not in error
                        BOOL otherIsError = NO;
                        for (Relation *relation in [Relation getEntityRelations:self.entity]) {
                            if ([relation.srcEntity isEqualToString:self.entity]) {
                                NSString *otherField = [relation destKey];
                                NSString *otherEntity = [relation destEntity];
                                Item *other = [EntityManager find:otherEntity column:otherField value:value];
                                if (other != nil) {
                                    if ([[other.fields objectForKey:@"error"] length] > 0) {
                                        otherIsError = YES;
                                    }
                                }
                            }
                        }
                        if (!otherIsError) {
                            self.incomplete = [NSNumber numberWithBool:YES];
                        }
                    } else {
                        [soapMessage appendString:@"<![CDATA["];
                        [soapMessage appendString:value];
                        [soapMessage appendString:@"]]>"];
                    }
                } else {
                    if ([field isEqualToString:@"OwnerId"]) {
                        NSDictionary *userInfo = [CurrentUserManager read];
                        if (userInfo != nil && [userInfo objectForKey:@"UserId"] != nil) {
                            [soapMessage appendString:[userInfo objectForKey:@"UserId"]];
                        }
                    }
                }
                [soapMessage appendFormat:@"</%@>", field];
            }
        }
    }    
    [soapMessage appendFormat:@"</%@>", self.entity];  


    [soapMessage appendFormat:@"</ListOf%@>", self.entity];
    [soapMessage appendFormat:@"</%@%@_Input>", self.entity, action];
    
}

- (ResponseParser *)getParser {
    return [[OutgoingResponseParser alloc] initWithEntity:self.entity item:self.item isDelete:[self.isDelete boolValue] incomplete:[self.incomplete boolValue]];
}

- (int)getStep {
    return 8;
}

- (NSString *)getName {
    NSString *entityName = [LocalizationTools getLocalizedName:self.entity];
    if ([self.isDelete boolValue]) {
        return [NSString stringWithFormat:NSLocalizedString(@"SENDING_DELETION", @"SENDING_DELETION"), entityName];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"SENDING_DATA", @"SENDING_DATA"), entityName];
    }
}


NSString *previousId;
NSTimeInterval delay = .01;


- (BOOL)prepare {
    NSString *value = [PropertyManager read:[NSString stringWithFormat:@"sync%@", entity]];
    if (![value isEqualToString:@"true"]){
        return NO;
    }
    NSMutableArray *filters = [[NSMutableArray alloc] initWithCapacity:1];
    if ([self.isDelete boolValue]) {
        [filters addObject:[ValuesCriteria criteriaWithColumn:@"deleted" value:@"1"]];
    } else {
        [filters addObject:[ValuesCriteria criteriaWithColumn:@"modified" value:@"1"]];
    }
    [filters addObject:[[IsNullCriteria alloc] initWithColumn:@"error"]];
    self.item = [EntityManager find:self.entity criterias:filters];
    NSString *gadgetId = [self.item.fields objectForKey:@"gadget_id"];
    if ([previousId isEqualToString:gadgetId]) {
        // Add delay so that the incomplete items are not repeated too often (bug #5098)
        if (delay < 1) delay = 2;
        else if (delay < 32) delay *= 2;
    } else {
        delay = .01;
        previousId = gadgetId;
    }
    self.incomplete = [NSNumber numberWithBool:NO];
    if (self.item != nil) {
        return YES;
    } else {
        return NO;
    }
}

- (NSTimeInterval)getDelay {
    return delay;
}

- (NSString *)requestEntity {
    return self.entity;
}

@end
