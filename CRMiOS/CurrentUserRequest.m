//
//  CurrentUserRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CurrentUserRequest.h"


@implementation CurrentUserRequest

- (id)initWithListener:(NSObject <SOAPListener> *)newListener {
    return [super init:newListener];
}

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/currentuser/:CurrentUserQueryPage\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    
    [soapMessage appendString:@"<CurrentUserWS_CurrentUserQueryPage_Input xmlns='urn:crmondemand/ws/currentuser/'>"];
    [soapMessage appendString:@"<ListOfCurrentUser>"];
    [soapMessage appendString:@"<CurrentUser>"];
    [soapMessage appendString:@"<UserId/>"];
    [soapMessage appendString:@"<Alias/>"];
    [soapMessage appendString:@"<UserSignInId/>"];
    [soapMessage appendString:@"</CurrentUser>"];
    [soapMessage appendString:@"</ListOfCurrentUser>"];
    [soapMessage appendString:@"</CurrentUserWS_CurrentUserQueryPage_Input>"];
}

- (ResponseParser *)getParser {
    
    return [[CurrentUserResponseParser alloc]init];
    
}
- (int)getStep {
    return 1;
}

- (NSString *)getName {
    return NSLocalizedString(@"READING_CURRENT_USER", @"READING_CURRENT_USER");
}

@end
