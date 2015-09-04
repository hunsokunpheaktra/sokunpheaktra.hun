//
//  PharmaRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 11/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "PharmaRequest.h"


@implementation PharmaRequest

- (id)initWithListener:(NSObject <SOAPListener> *)newListener {
    return [super init:newListener];
}
- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/ecbs/activity/:ActivityQueryPage\"";
}


- (void)generateBody:(NSMutableString *)soapMessage {

    [soapMessage appendString:@"<ActivityQueryPage_Input xmlns='urn:crmondemand/ws/ecbs/activity/'>"];
    [soapMessage appendString:@"<ListOfActivity pagesize='2' startrownum='0'>"];
    [soapMessage appendString:@"<Activity>"];
    [soapMessage appendString:@"<ListOfProductsDetailed>"];
    [soapMessage appendString:@"<ProductsDetailed/>"];
    [soapMessage appendString:@"</ListOfProductsDetailed>"];
    [soapMessage appendString:@"</Activity>"];
    [soapMessage appendString:@"</ListOfActivity>"];
    [soapMessage appendString:@"</ActivityQueryPage_Input>"];
    
}
- (int)getStep {
    return 5;
}

- (NSString *)getName {
    return NSLocalizedString(@"TEST_PHARMA", nil);
}

- (ResponseParser *)getParser {
    return [[PharmaResponseParser alloc] init];
}
@end
