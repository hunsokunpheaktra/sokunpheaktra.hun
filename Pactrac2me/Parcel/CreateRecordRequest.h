//
//  CreateRecordRequest.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/6/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "SalesforceAPIRequest.h"
#import "Item.h"

@interface CreateRecordRequest : SalesforceAPIRequest

-(id)initWithItem:(Item*)item;

@property (nonatomic, retain) NSString *sobject;

@end
