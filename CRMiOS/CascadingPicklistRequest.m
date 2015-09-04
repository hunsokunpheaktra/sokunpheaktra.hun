//
//  CascadingPicklistRequest.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/30/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "CascadingPicklistRequest.h"

@implementation CascadingPicklistRequest

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/odesabs/cascadingpicklist/:CascadingPicklistReadAll\"";
}
-(void)generateBody:(NSMutableString *)soapMessage{
     [soapMessage appendString:@"<CascadingPicklistReadAll_Input xmlns=\"urn:crmondemand/ws/odesabs/cascadingpicklist/\"/>"];
}
- (NSString *)getURLSuffix {
    return @"Services/cte/CascadingPicklistService";
}
- (ResponseParser *)getParser {
    return [[CascadingPicklistParser alloc] init];
}

- (int)getStep {
    return 7;
}

- (NSString *)getName {
    return NSLocalizedString(@"READING_CASCADING", @"READING_CASCADING");
}

- (BOOL)prepare {
    // do we sync the picklists ?
    return ([[PropertyManager read:@"syncPicklist"] isEqualToString:@"YES"]);
}

@end
