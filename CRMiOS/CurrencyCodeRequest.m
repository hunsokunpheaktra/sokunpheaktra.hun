//
//  CurrencyCodeRequest.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/30/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CurrencyCodeRequest.h"


@implementation CurrencyCodeRequest

- (id)initWithListener:(NSObject <SOAPListener> *)newListener {
    return [super init:newListener];
}

- (NSString *)getSoapAction {
    return @"\"document/urn:crmondemand/ws/odesabs/Currency/:CurrencyReadAll\"";
}

- (void)generateBody:(NSMutableString *)soapMessage {
    
    [soapMessage appendString:@"<CurrencyReadAll_Input xmlns='urn:crmondemand/ws/odesabs/currency/'/>"];

}

- (ResponseParser *)getParser {
    return [[CurrencyCodeParser alloc] init];
}

- (NSString *)getName {
    return NSLocalizedString(@"READING_CURRENCY_PICKLIST", @"READING_CURRENCY_PICKLIST");
}

- (int)getStep {
    return 6;
}

- (NSString *)getURLSuffix {
    return @"Services/cte/CurrencyService";
}

- (BOOL)prepare {
    // do we sync the picklists ?
    return ([[PropertyManager read:@"syncPicklist"] isEqualToString:@"YES"]);
}


@end
