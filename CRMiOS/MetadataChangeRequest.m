//
//  MetadataChangeRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "MetadataChangeRequest.h"


@implementation MetadataChangeRequest

- (id)initWithListener:(NSObject<SOAPListener> *)Newlistener{
    
    return [super init:Newlistener];

}

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/metadatachangesummary/:MetadataChangeSummaryQueryPage\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    [soapMessage appendString:@"<MetadataChangeSummaryQueryPage_Input xmlns='urn:crmondemand/ws/metadatachangesummary/'>"];
    [soapMessage appendString:@"<ListOfMetadataChangeSummary>"];
    [soapMessage appendString:@"<MetadataChangeSummary>"];
    [soapMessage appendString:@"<LOVLastUpdated/>"];
    [soapMessage appendString:@"</MetadataChangeSummary>"];
    [soapMessage appendString:@"</ListOfMetadataChangeSummary>"];
    [soapMessage appendString:@"</MetadataChangeSummaryQueryPage_Input>"];
}

- (ResponseParser *)getParser {
    return [[MetadataChangeResponseParser alloc] init];
}

- (NSString *)getName {
    return NSLocalizedString(@"READING_METADATA_CHANGE", @"READING_METADATA_CHANGE");
}

- (int)getStep {
    return 5;
}

@end
