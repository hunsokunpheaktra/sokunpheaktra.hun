//
//  FieldManagementRequest.m
//  CRMiOS
//
//  Created by Arnaud on 1/11/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "FieldManagementRequest.h"

@implementation FieldManagementRequest

- (id)initWithListener:(NSObject <SOAPListener> *)newListener {
    self = [super init:newListener];
    return  self;
}

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/odesabs/FieldManagement/:FieldManagementReadAll\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    [soapMessage appendString:@"<FieldManagementReadAll_Input xmlns=\"urn:crmondemand/ws/odesabs/fieldmanagement/\"/>"];
}

- (ResponseParser *)getParser {
    return [[FieldManagementParser alloc] init];
}


- (int)getStep {
    return 7;
}

- (NSString *)getName {
    return NSLocalizedString(@"READING_FIELD_MGMT", @"READING_FIELD_MGMT");
}

- (BOOL)prepare {
    
    // 1) do we sync the picklists ?
    return ([[PropertyManager read:@"syncPicklist"] isEqualToString:@"YES"]);
}

- (NSString *)getURLSuffix {
    return @"Services/cte/FieldManagementService";
}

@end
