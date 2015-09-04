//
//  DataModel.h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol DataModel <NSObject>
    
- (NSString *) getEntityName;
- (int) getRowCount;
- (int) getColumnCount;
- (NSString *) getColumnName:(int) columnIndex;
- (NSString *) getApiColumnName:(int) columnIndex;
- (int) getColumType:(int) columnIndex;

- (NSString *) getValueAt:(int) rowIndex columnIndex:(int) columnIndex;
- (void) setValueAt:(int)rowIndex columnIndex:(int)columnIndex  oldValue:(NSString*)oldValue newValue:(NSString*)newValue;

- (BOOL) isEditable:(int)columnIndex;

- (void) populate;

- (NSString *) getIdColumn;

@end
