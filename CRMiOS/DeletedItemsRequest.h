//
//  DeletedItemsRequest.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPRequest.h"
#import "Item.h"
#import "DeletedItemsResponseParser.h"
#import "PropertyManager.h"

@interface DeletedItemsRequest : SOAPRequest {
    NSNumber *startRow;
}
@property (nonatomic, retain) NSNumber *startRow;

- (id)initWithListener:(NSObject <SOAPListener> *)newListener;

@end
