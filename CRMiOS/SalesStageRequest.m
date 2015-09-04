//
//  SalesStageRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "SalesStageRequest.h"


@implementation SalesStageRequest

- (id)initWithListener:(NSObject <SOAPListener> *)newListener{
    self = [super init:newListener];
    return  self;
}

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/salesproc/:SalesProcessQueryPage\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    
    [soapMessage appendString:@"<SalesProcessQueryPage_Input xmlns=\'urn:crmondemand/ws/salesproc/\'>"];
    [soapMessage appendString:@"<ListOfSalesProcess pagesize=\"50\">"];
    [soapMessage appendString:@"<SalesProcess>"];
    [soapMessage appendString:@"<Id />"];
    [soapMessage appendString:@"<Name />"];
    [soapMessage appendString:@"<Description/>"];
    [soapMessage appendString:@"<Default />"];
    
    [soapMessage appendString:@"<ListOfSalesStage>"];
    [soapMessage appendString:@"<SalesStage>"];
    [soapMessage appendString:@"<Id />"];
    [soapMessage appendString:@"<Name />"];
    [soapMessage appendString:@"<Order />"];
    [soapMessage appendString:@"<Probability />"];
    [soapMessage appendString:@"<SalesCategoryName />"];
    [soapMessage appendString:@"</SalesStage>"];
    [soapMessage appendString:@"</ListOfSalesStage>"];
    
    [soapMessage appendString:@"<ListOfOpportunityType>"];
    [soapMessage appendString:@"<OpportunityType>"];
    [soapMessage appendString:@"<Type/>"];
    [soapMessage appendString:@"</OpportunityType>"];
    [soapMessage appendString:@"</ListOfOpportunityType>"];
    
    [soapMessage appendString:@"</SalesProcess>"];
    [soapMessage appendString:@"</ListOfSalesProcess>"];
    [soapMessage appendString:@"</SalesProcessQueryPage_Input>"];

}

- (ResponseParser *)getParser {
    return [[SalesStageResponseParser alloc] init];
}

- (NSString *)getName {
    return NSLocalizedString(@"READING_SALESTAGE", @"READING_SALESTAGE");
}

- (int)getStep {
    return 6;
}


- (BOOL)prepare {
    // sync this every time
    return YES;
}

@end
