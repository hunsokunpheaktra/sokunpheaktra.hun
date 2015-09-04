//
//  EntityDataGrid.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "DatagridListener.h"

@interface EntityDataGrid : UIViewController<DataModel,DatagridListener>{
    
    NSString *entity;
    NSArray *rows;
    NSArray *columnNames;
    NSArray *apiColumnNames;
    NSArray* fieldInfos;
    NSMutableArray* listEditRecord;
    
    NSMutableDictionary  *mapRefName;
    NSMutableDictionary  *tableNameExist;
    NSMutableDictionary  *mapListRefEntity;
    NSMutableDictionary  *mapFieldNamePicklist;

}

- (id)initWithEntity:(NSString*)newEntity;

@end
