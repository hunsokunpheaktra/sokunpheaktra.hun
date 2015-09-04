//
//  DeleteRecordRequest.h
//  Parcel
//
//  Created by Sy Pauv on 1/15/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "SalesforceAPIRequest.h"
@interface DeleteRecordRequest : SalesforceAPIRequest
@property (nonatomic, retain) NSString *sObject;
@property (nonatomic, retain) NSString *recId;
-(id)initWithSObject:(NSString *)name id:(NSString *)rId;
-(id)initWithItem:(Item*)item;

@end
