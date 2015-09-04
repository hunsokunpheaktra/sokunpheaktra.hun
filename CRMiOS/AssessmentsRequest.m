//
//  AssessmentsRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "AssessmentsRequest.h"

@implementation AssessmentsRequest

- (id)initWithListener:(NSObject <SOAPListener> *)newListener{
    self = [super init:newListener];
    return  self;
}

-(NSString *)getSoapAction{
    return @"\"document/urn:crmondemand/ws/odesabs/SalesAssessmentTemplate/:SalesAssessmentTemplateReadAll\"";
}
- (NSString *)getURLSuffix {
    return @"Services/cte/SalesAssessmentTemplateService";
}
-(void)generateBody:(NSMutableString *)soapMessage{
    [soapMessage appendString:@"<SalesAssessmentTemplateReadAll_Input xmlns=\"urn:crmondemand/ws/odesabs/SalesAssessmentTemplate/\"/>"];
}

-(ResponseParser *)getParser{
    return [[AssessmentsResponseParser alloc]init];
}
-(NSString *)getName{
    return NSLocalizedString(@"READING_ASSESSMENTS", @"READING_ASSESSMENTS");
}
-(int)getStep{
    return 7;
}
@end
