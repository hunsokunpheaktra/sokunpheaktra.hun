//
//  KeyInformationView.h
//  SyncForce
//
//  Created by Gaeasys on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterFieldManager.h"
#import "EntityInfo.h"
#import "DataType.h"

@class ObjectDetailViewController;

@interface KeyInformationView :UITableViewController<UITableViewDelegate, UITableViewDataSource> {
    CGRect frame;
    UITableView * tableKey;
    Item* detailitem;
    NSArray* listFieldFilter;
    id parentClass;
    NSMutableDictionary* mapNameType;
    NSObject<EntityInfo> *entityInfo;
}


@property (nonatomic, retain) UITableView * tableKey;
@property (nonatomic, retain) NSArray* listFieldFilter;
@property (nonatomic, retain) NSMutableDictionary* mapNameType;

-(id)initWitFrame:(CGRect)rect data:(Item*)item parent:(id)parent;

@end
