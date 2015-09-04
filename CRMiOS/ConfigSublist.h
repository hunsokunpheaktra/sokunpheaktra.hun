//
//  ConfigSublist.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 10/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Relation.h"
#import "Sublist.h"

@interface ConfigSublist : NSObject<Sublist> {
    NSString *name;
    NSMutableArray *fields;
    NSString *displayText;
    NSString *icon;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *fields;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *displayText;


- (id)initWithName:(NSString *)newName icon:(NSString *)newIcon displayText:(NSString *)newDisplayText;

@end
