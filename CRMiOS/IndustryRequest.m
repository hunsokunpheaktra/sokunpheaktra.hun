//
//  IndustryRequest.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "IndustryRequest.h"


@implementation IndustryRequest

- (id)initWithListener:(NSObject <SOAPListener> *)newListener {
    return [super init:newListener];
}

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/odesabs/industry/:IndustryReadAll\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    
    [soapMessage appendString:@"<IndustryReadAll_Input xmlns='urn:crmondemand/ws/odesabs/industry/'/>"];
    
}

- (ResponseParser *)getParser {
    return [[IndustryResponseParser alloc] init];
}

- (NSString *)getName {
    return NSLocalizedString(@"READING_INDUSTRY_PICKLIST", @"READING_INDUSTRY_PICKLIST");
}

- (int)getStep {
    return 6;
}

- (NSString *)getURLSuffix {
    return @"Services/cte/IndustryService";
}


- (BOOL)prepare {
    // do we sync the picklists ?
    return ([[PropertyManager read:@"syncPicklist"] isEqualToString:@"YES"]);
}

@end
