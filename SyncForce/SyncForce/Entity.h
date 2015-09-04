//
//  Entity.h
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityInfo.h"
#import "Item.h"

@interface Entity : NSObject <EntityInfo> {
    NSArray *fieldsInfo;
    Item *entityInfo;
}
@property (nonatomic, retain) NSArray *fieldsInfo;
@property (nonatomic, retain) Item *entityInfo;

-(id)initWithEntityName:(NSString *)entityname;
-(id)initWithEntityInfo:(Item *)entityInfo;

+ (NSArray *) getFieldsCreateable:(NSString *)entity;
+ (NSArray *) getFieldsUpdateable:(NSString *)entity;

@end
