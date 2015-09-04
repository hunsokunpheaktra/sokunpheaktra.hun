//
//  CustomRecordTypeRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/15/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CustomRecordTypeRequest.h"

@implementation CustomRecordTypeRequest


- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/odesabs/customrecordtype/:CustomRecordTypeReadAll\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {

    [soapMessage appendString:@"<CustomRecordTypeReadAll_Input xmlns=\"urn:crmondemand/ws/odesabs/customrecordtype/\"/>"];
    
}

- (ResponseParser *)getParser {
    return [[CustomRecordTypeResponseParser alloc] init];
}

- (NSString *)getURLSuffix {
    return @"Services/cte/CustomRecordTypeService";
}

- (id)initListener:(NSObject <SOAPListener> *)newListener{
    self = [super init:newListener];
    return self;
}


- (NSString *)getName {
    return NSLocalizedString(@"READING_CUSTOM_RECORD", @"READING_CUSTOM_RECORD");
}

- (int)getStep {
    return 6;
}


@end
