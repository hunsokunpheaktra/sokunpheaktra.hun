//
//  TestRelatedList.h
//  SyncForce
//
//  Created by Gaeasys on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <Foundation/Foundation.h>
#import "DatagridListener.h"
#import "DataModel.h"


@interface TestRelatedList : UIViewController <DataModel,DatagridListener> {
    NSArray *rows;
    NSArray *columnNames;
    NSArray *apiColumnNames;
    NSArray* fieldInfos;
    NSString* entityName;
    NSString* parentId;
    NSString* parentField;
    NSString* childType;
    NSMutableArray* listEditRecord;

    
    NSMutableDictionary  *mapRefName;
    NSMutableDictionary  *tableNameExist;
    NSMutableDictionary  *mapListRefEntity;
    NSMutableDictionary  *mapFieldNamePicklist;
}

@property (nonatomic,retain) NSArray* rows;
@property (nonatomic,retain) NSArray* columnNames;
@property (nonatomic,retain) NSArray* apiColumnNames;
@property (nonatomic,retain) NSArray* fieldInfos;
@property (nonatomic,retain) NSString* entityName;
@property (nonatomic,retain) NSString* parentId;
@property (nonatomic,retain) NSString* parentField;

-(id)init;
-(id)initWithDatas:(NSString*)entity colNames:(NSArray*)colNames apiColName:(NSArray*)apiColNames rows:(NSArray*)tRows parentId:(NSString*)pId parentField:(NSString*)pField cType:(NSString*)cType;

@end