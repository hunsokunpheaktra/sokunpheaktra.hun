//
//  ConfigEntity.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailLayout.h"
#import "EntityInfo.h"
#import "ConfigSubtype.h"
#import "Configuration.h"

@interface ConfigEntity : NSObject<EntityInfo> {
    NSString *searchField;
    NSString *searchFiled2;
    NSString *name;
    NSMutableArray *fields;
    BOOL _enabled;
    BOOL _canCreate;
    BOOL _canDelete;
    BOOL _canUpdate;
    BOOL _hidden;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *searchField;
@property (nonatomic, retain) NSString *searchField2;
@property (nonatomic, retain) NSMutableArray *fields;
@property (assign) BOOL enabled;
@property (assign) BOOL canCreate;
@property (assign) BOOL canDelete;
@property (assign) BOOL canUpdate;
@property (assign) BOOL hidden;

- (id)initWithEntity:(NSString *)newEntity;

@end
