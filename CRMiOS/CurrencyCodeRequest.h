//
//  CurrencyCodeRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/30/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "CurrencyCodeParser.h"

@interface CurrencyCodeRequest : SOAPRequest {
    
}
- (id)initWithListener:(NSObject <SOAPListener> *)newListener ;

@end
