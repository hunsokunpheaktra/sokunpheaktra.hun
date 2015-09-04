//
//  Section.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Section : NSObject {
    NSString *name;
    NSMutableArray *fields;
    BOOL _isGrouping;
}
@property (assign) BOOL isGrouping;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *fields;

- (id)initWithName:(NSString *)newName;

@end
