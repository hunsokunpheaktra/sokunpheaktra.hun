//
//  ConfigFilter.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 10/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Criteria.h"

@interface ConfigFilter : NSObject {
    NSObject <Criteria> *criteria;
    BOOL optional;
    NSString *name;
}

@property (nonatomic, retain) NSObject <Criteria> *criteria;
@property (nonatomic, retain) NSString *name;
@property (readwrite) BOOL optional;

- (id)initWithName:(NSString *)newName;

@end
