//
//  DeletedSublistRequest.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/28/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "DeletedSublistRequest.h"

@implementation DeletedSublistRequest


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
    return [NSString stringWithFormat:@"\"document/urn:crmondemand/ws/ecbs/%@/:%@Delete\"", entityLowercase, self.entity];
}

- (void)generateBody:(NSMutableString *)soapMessage {
    
    
   	NSString *entityLowercase = [entity lowercaseString];	
    [soapMessage appendFormat:@"<%@Delete_Input xmlns=\"urn:crmondemand/ws/ecbs/%@/\">", self.entity, entityLowercase];
    [soapMessage appendFormat:@"<ListOf%@>", self.entity];
    [soapMessage appendFormat:@"<%@>", self.entity];
    [soapMessage appendString:@"<Id>"];
    [soapMessage appendString:@"<![CDATA["];
    [soapMessage appendString:[self.item.fields objectForKey:@"parent_oid"]];
    [soapMessage appendString:@"]]>"];
    [soapMessage appendString:@"</Id>"];
    [soapMessage appendFormat:@"<ListOf%@>", self.sublist];
    [soapMessage appendFormat:@"<%@>", self.sublist];
    [soapMessage appendFormat:@"<Id>%@</Id>", [self.item.fields objectForKey:@"Id"]];
    [soapMessage appendFormat:@"</%@>", self.sublist];
    [soapMessage appendFormat:@"</ListOf%@>", self.sublist];   
    [soapMessage appendFormat:@"</%@>", self.entity];  
    [soapMessage appendFormat:@"</ListOf%@>", self.entity];
    [soapMessage appendFormat:@"</%@Delete_Input>", self.entity];
}

- (ResponseParser *)getParser {
    return [[DeletedSublistParser alloc] initWithEntity:self.entity sublist:self.sublist item:self.item];
}

- (int)getStep {
    return 9;
}

- (NSString *)getName {
    return [NSString stringWithFormat:NSLocalizedString(@"SENDING_DELETION", @"SENDING_DELETION"), 
            [LocalizationTools getLocalizedName:self.sublist]];
}

- (BOOL)prepare {
    NSString *value = [PropertyManager read:[NSString stringWithFormat:@"sync%@", entity]];
    if (![value isEqualToString:@"true"]){
        return NO;
    }
    NSMutableArray *criterias = [[NSMutableArray alloc] initWithCapacity:1];
    [criterias addObject:[ValuesCriteria criteriaWithColumn:@"deleted" value:@"1"]];
    NSArray *list = [SublistManager list:self.entity sublist:self.sublist criterias:criterias];
    if ([list count] > 0) {
        self.item = [list objectAtIndex:0];
        return YES;
    } else {
        return NO;
    }
}



- (NSString *)requestEntity {
    return self.entity;
}

@end
