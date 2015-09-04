//
//  DetailViewController.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "EntityInfo.h"

#define SETTING_HEADER_FONT_SIZE 16.0
#define SETTING_HEADER_HEIGHT 48.0
#define SETTING_HEADER_ROW_WIDTH 400.0

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    Item *detail;
    NSObject<EntityInfo> *entityInfo;
    NSMutableDictionary *layoutItems;
    
    UITableView *detailView;
    NSArray *sections;
}

@property (nonatomic, retain) Item *detail;
@property (nonatomic, retain) UITableView *detailView;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSMutableDictionary *layoutItems;

- (id)init:(Item*)item;
- (NSMutableArray *)fillSection:(int)section;

@end
