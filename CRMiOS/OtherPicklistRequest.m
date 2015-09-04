//
//  OtherPicklistRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "OtherPicklistRequest.h"


@implementation OtherPicklistRequest


@synthesize entity,field;

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/picklist/:GetPicklistValues\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    
    [soapMessage appendString:@"<PicklistWS_GetPicklistValues_Input xmlns=\"urn:crmondemand/ws/picklist/\">"];
    [soapMessage appendString:@"<FieldName>"];
    [soapMessage appendString:field];
    [soapMessage appendString:@"</FieldName>"];
    [soapMessage appendString:@"<RecordType>"];
    [soapMessage appendString:[self fixEntity:self.entity]];
    [soapMessage appendString:@"</RecordType>"];
    [soapMessage appendString:@"</PicklistWS_GetPicklistValues_Input>"];

}


- (ResponseParser *)getParser {
    return [[OtherPicklistResponseParser alloc] initWithEntity:entity fields:field];
}

- (NSString *)getURLSuffix {
    return @"Services/Integration";
}

- (id)initWithEntity:(NSString *)newEntity field:(NSString *)newField listener:(NSObject <SOAPListener> *)newListener{
    self = [super init:newListener];
    self.entity = newEntity;
    self.field = newField;
    return self;
}



- (NSString *)getName {
    return [NSString stringWithFormat:NSLocalizedString(@"READING_PICKLISTS", @"READING_PICKLISTS"), self.field];
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
