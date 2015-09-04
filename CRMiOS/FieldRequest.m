//
//  FieldRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "FieldRequest.h"


@implementation FieldRequest

@synthesize entity;

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject <SOAPListener> *)newListener{
    self = [super init:newListener];
    self.entity = newEntity;
    return  self;
}

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/mapping/:GetMapping\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    
    [soapMessage appendString:@"<MappingWS_GetMapping_Input xmlns='urn:crmondemand/ws/mapping/'>"];
    [soapMessage appendString:@"<ObjectName>"];

    [soapMessage appendString:[self fixEntity:self.entity]];
    [soapMessage appendString:@"</ObjectName>"];
    [soapMessage appendString:@"</MappingWS_GetMapping_Input>"];

}

- (ResponseParser *)getParser {
    return [[FieldResponseParser alloc] initWithEntity:entity];
}


- (int)getStep {
    return 7;
}

- (NSString *)getName {
    return [NSString stringWithFormat:NSLocalizedString(@"READING_FIELDS", @"READING_FIELDS"),
            [LocalizationTools getLocalizedName:self.entity]];
}

- (BOOL)prepare {
    
    // 1) do we sync the entity ?
    NSString *value = [PropertyManager read:[NSString stringWithFormat:@"sync%@", self.entity]];
    if ([value isEqualToString:@"false"]) return NO;
    
    // 2) do we sync the picklists ?
    return ([[PropertyManager read:@"syncPicklist"] isEqualToString:@"YES"]);
}


@end
