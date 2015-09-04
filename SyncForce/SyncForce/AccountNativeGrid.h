//
//  AccountGrid.h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatagridListener.h"
#import "DataModel.h"

@interface AccountNativeGrid : UIViewController <DataModel,DatagridListener> {
    NSArray *rows;
    NSArray *columnNames;
    NSArray *apiColumnNames;
    NSArray* fieldInfos;
    NSMutableDictionary    *rowDataMassAdd;
}

@property (nonatomic,retain) NSArray* rows;
@property (nonatomic,retain) NSArray* columnNames;
@property (nonatomic,retain) NSArray* apiColumnNames;
@property (nonatomic,retain) NSArray* fieldInfos;
@property (nonatomic,retain) NSMutableDictionary *rowDataMassAdd;

-(id)init;

@end
