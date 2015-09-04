//
//  UpsertAttachmentRequest.h
//  Pactrac2me
//
//  Created by Sy Pauv on 1/24/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "SalesforceAPIRequest.h"

@interface UpsertAttachmentRequest : SalesforceAPIRequest
-(id)initWithItem:(Item*)item;
@property (nonatomic,retain) NSString *sobject;
@end
