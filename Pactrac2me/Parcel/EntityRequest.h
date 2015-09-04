//
//  EntityRequest.h
//  Parcel
//
//  Created by Gaeasys on 12/27/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFRequest.h"
#import "SyncListener.h"

@interface EntityRequest : NSObject <SFRequest>


- (id)initWithEntity:(NSString *)newEntity listener:(NSObject<SyncListener>*)newListener;

@end
