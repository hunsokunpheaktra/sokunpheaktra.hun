//
//  Action.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/21/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "EvaluateTools.h"


@interface Action : NSObject {
    NSString *name;
    NSString *entity;
    NSMutableDictionary *fields;
    BOOL clone;
    BOOL update;
}
@property (readwrite) BOOL update;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSMutableDictionary *fields;
@property (readwrite) BOOL clone;

- (id)initWithName:(NSString *)newName;
- (Item *)buildItem:(Item *)source;

@end
