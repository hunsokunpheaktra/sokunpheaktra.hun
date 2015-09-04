//
//  CallSFMethodClass.h
//  Pactrac2me
//
//  Created by Hun Sokunpheaktra on 3/20/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "SalesforceAPIRequest.h"

@interface CallSFMethodRequest : SalesforceAPIRequest{
    
}

@property(nonatomic,retain)NSString *urlMapping;
@property(nonatomic,retain)NSString *userEmail;

-(id)initWithUrlMapping:(NSString*)urlMapping userEmail:(NSString*)userEmail;

@end
