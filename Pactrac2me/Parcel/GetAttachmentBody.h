//
//  GetAttachment.h
//  Pactrac2me
//
//  Created by Sy Pauv on 1/22/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "SalesforceAPIRequest.h"
#import "Item.h"

@interface GetAttachmentBody : SalesforceAPIRequest
@property (nonatomic, retain) Item *item;
-(id)initWithID:(Item *)attItem;
@end
