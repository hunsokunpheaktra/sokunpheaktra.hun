//
//  CompanyRequest.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/30/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "CompanyRequest.h"

@implementation CompanyRequest

- (id)initWithListener:(NSObject <SOAPListener> *)newListener {
    return [super init:newListener];
}

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/odesabs/CurrentOrganization/:CurrentOrganizationRead\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    [soapMessage appendString:@"<CurrentOrganizationRead_Input xmlns=\"urn:crmondemand/ws/odesabs/CurrentOrganization/\">"];
    [soapMessage appendString:@"<CurrentOrganization xmlns=\"urn:/crmondemand/xml/CurrentOrganization/Data\"/>"];
    [soapMessage appendString:@"</CurrentOrganizationRead_Input>"];
}

- (ResponseParser *)getParser {
    return [[CompanyResponseParser alloc] init];
}

- (int)getStep {
    return 6;
}

- (NSString *)getName {
    return NSLocalizedString(@"READING_COMPANY", @"READING_COMPANY");
}


- (NSString *)getURLSuffix {
    return @"Services/cte/CurrentOrganizationService";
}

@end
