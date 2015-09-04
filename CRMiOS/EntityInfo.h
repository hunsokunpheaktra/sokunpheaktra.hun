//
//  EntityInfo.h
//  Orientation
//
//  Created by Sy Pauv Phou on 3/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@protocol EntityInfo <NSObject>

- (NSString *)name;
- (NSArray *)fields; 
- (NSArray *)getSubtypes;
- (NSString *)searchField;
- (NSString *)searchField2;
- (BOOL)enabled;
- (BOOL)canCreate;
- (BOOL)canDelete;
- (BOOL)canUpdate;
- (BOOL)hidden;
- (NSArray *)getSublists;
- (NSArray *)getSublistFields:(NSString *)sublistName;

@end
