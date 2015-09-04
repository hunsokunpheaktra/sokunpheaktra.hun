//
//  UpdateListener.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@protocol UpdateListener <NSObject>
    
- (void)didUpdate:(Item*)newItem;
- (void)updateFieldDisplay:(NSString*)newValue index:(int)index;
- (void)mustUpdate:(NSString *)val;

@end
