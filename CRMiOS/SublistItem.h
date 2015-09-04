//
//  SublistItem.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface SublistItem : Item {
    NSString *sublist;
}

@property (nonatomic, retain) NSString *sublist;

- (id)init:(NSString *)newEntity sublist:(NSString *)sublist fields:(NSDictionary *)newFields;
- (BOOL)updatable;
- (NSString *)unicityKey;

@end
