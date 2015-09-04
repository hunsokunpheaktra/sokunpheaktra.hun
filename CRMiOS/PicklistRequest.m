//
//  PicklistRequest.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/9/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PicklistRequest.h"


@implementation PicklistRequest

@synthesize entity;

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/odesabs/Picklist/:PicklistRead\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    [soapMessage appendString:@"<PicklistRead_Input xmlns=\"urn:crmondemand/ws/odesabs/picklist/\">"];
    [soapMessage appendString:@"<PicklistSet xmlns=\"urn:/crmondemand/xml/picklist/query\">"];
    [soapMessage appendString:@"<ObjectName>"];
    [soapMessage appendString:[self fixEntity:self.entity]];
    [soapMessage appendString:@"</ObjectName>"];
    [soapMessage appendString:@"</PicklistSet>"];
    [soapMessage appendString:@"</PicklistRead_Input>"];
}


- (ResponseParser *)getParser {
    return [[PicklistResponseParser alloc] init];
}

- (NSString *)getURLSuffix {
    return @"Services/cte/PicklistService";
}

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject <SOAPListener> *)newListener {
    self = [super init:newListener];
    self.entity = newEntity;
    return self;
}


- (NSString *)getName {
    return [NSString stringWithFormat:NSLocalizedString(@"READING_PICKLISTS", @"READING_PICKLISTS"),
           [LocalizationTools getLocalizedName:self.entity]];
}

- (int)getStep {
    return 7;
}


- (BOOL)prepare {
    // 1) do we sync the entity ?
    NSString *value = [PropertyManager read:[NSString stringWithFormat:@"sync%@", self.entity]];
    if ([value isEqualToString:@"false"]) return NO;
    
    // 2) do we sync the picklists ?
    return ([[PropertyManager read:@"syncPicklist"] isEqualToString:@"YES"]);
}

@end
