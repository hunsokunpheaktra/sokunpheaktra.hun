//
//  QueryRequest.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/5/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "SalesforceAPIRequest.h"

@interface QueryRequest : SalesforceAPIRequest

-(id)initWithSQL:(NSString *)s sobject:(NSString*)object;

@property (nonatomic,retain) NSString *sql;
@property (nonatomic,retain) NSString *sobject;

@end
