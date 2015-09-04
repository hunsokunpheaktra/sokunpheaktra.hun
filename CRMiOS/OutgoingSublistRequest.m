//
//  OutgoingSublistRequest.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 1/11/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "OutgoingSublistRequest.h"

@implementation OutgoingSublistRequest

@synthesize entity;
@synthesize sublist;
@synthesize item;

- (id)initWithEntity:(NSString *)newEntity sublist:(NSString *)newSublist listener:(NSObject <SOAPListener> *)newListener {
    self = [super init:newListener];
    self.entity = newEntity;
    self.sublist = newSublist;
    return self;
}


- (NSString *)getSoapAction {
    NSString *entityLowercase = [self.entity lowercaseString];	
    return [NSString stringWithFormat:@"\"document/urn:crmondemand/ws/ecbs/%@/:%@%@\"", entityLowercase, self.entity, [self getAction]];
}

- (void)generateBody:(NSMutableString *)soapMessage {

    
   	NSString *entityLowercase = [entity lowercaseString];	
    [soapMessage appendFormat:@"<%@%@_Input xmlns=\"urn:crmondemand/ws/ecbs/%@/\">", self.entity, [self getAction], entityLowercase];
    [soapMessage appendFormat:@"<ListOf%@>", self.entity];
    [soapMessage appendFormat:@"<%@>", self.entity];
    [soapMessage appendString:@"<Id>"];
    [soapMessage appendString:@"<![CDATA["];
    [soapMessage appendString:[self.item.fields objectForKey:@"parent_oid"]];
    [soapMessage appendString:@"]]>"];
    [soapMessage appendString:@"</Id>"];
    [soapMessage appendFormat:@"<ListOf%@>", self.sublist];
    [soapMessage appendFormat:@"<%@>", self.sublist];
    NSObject<EntityInfo> *info = [Configuration getInfo:self.entity];
    NSString *sublistCode = [NSString stringWithFormat:@"%@ %@", self.entity, self.sublist];
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[info getSublistFields:self.sublist]];
    for (NSString *field in fields) {
        if (![RelationManager isCalculated:sublistCode field:field]) {
            [soapMessage appendFormat:@"<%@>", field];
            NSString *value = [self.item.fields objectForKey:field];
            if (value != nil) {
                [soapMessage appendString:@"<![CDATA["];
                [soapMessage appendString:value];
                [soapMessage appendString:@"]]>"];
            }
            [soapMessage appendFormat:@"</%@>", field];
        }
    }
    [soapMessage appendFormat:@"</%@>", self.sublist];
    [soapMessage appendFormat:@"</ListOf%@>", self.sublist];   
    [soapMessage appendFormat:@"</%@>", self.entity];  
    [soapMessage appendFormat:@"</ListOf%@>", self.entity];
    [soapMessage appendFormat:@"</%@%@_Input>", self.entity, [self getAction]];
}

- (ResponseParser *)getParser {
    return [[OutgoingSublistParser alloc] initWithEntity:self.entity sublist:self.sublist item:self.item];
}

- (int)getStep {
    return 9;
}

- (NSString *)getName {
    return [NSString stringWithFormat:NSLocalizedString(@"SENDING_DATA", @"SENDING_DATA"), 
            [LocalizationTools getLocalizedName:self.sublist]];
}

- (BOOL)prepare {
    NSString *value = [PropertyManager read:[NSString stringWithFormat:@"sync%@", entity]];
    if (![value isEqualToString:@"true"]){
        return NO;
    }
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"modified" value:@"1"]];
    NSArray *list = [SublistManager list:self.entity sublist:self.sublist criterias:criterias];
    if ([list count] > 0) {
        self.item = [list objectAtIndex:0];
        return YES;
    } else {
        return NO;
    }
}



- (NSString *)getAction {
    if (![self.item updatable]) return @"Insert";
    NSString *oid = [self.item.fields objectForKey:@"Id"];
    return oid == nil ? @"Insert" : @"Update";
}



- (NSString *)requestEntity {
    return self.entity;
}

@end
