//
//  Item.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject {
    NSString *entity;
    NSMutableDictionary *fields;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSMutableDictionary *fields;

- (id)init:(NSString *)newEntity fields:(NSDictionary *)newFields;

@end
