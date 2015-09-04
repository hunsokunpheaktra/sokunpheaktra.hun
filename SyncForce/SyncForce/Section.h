//
//  Section.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Section : NSObject {
    NSString *name;
    NSMutableArray *fields;
    NSNumber *isGrouping;
}
@property (nonatomic, retain) NSNumber *isGrouping;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *fields;

- (id)initWithName:(NSString *)newName;

@end
