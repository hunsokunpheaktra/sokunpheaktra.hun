//
//  Group.h
//  Orientation
//
//  Created by Sy Pauv Phou on 3/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Group : NSObject {
    NSString *name;
    NSString *shortName;
    NSMutableArray *items;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *shortName;
@property (nonatomic, retain) NSMutableArray *items;


@end
