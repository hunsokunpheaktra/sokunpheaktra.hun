//
//  SelectRelatedItem.h
//  CRMiOS
//
//  Created by Sy Pauv on 7/18/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateListener.h"
#import "Item.h"
#import "RelationManager.h"
#import "Subtype.h"
#import "LikeCriteria.h"
#import "FilterManager.h"
#import "FieldsManager.h"


@interface SelectRelatedItem : UIViewController< UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate> {
    NSString *entity;
    NSString *code;
    Item *item;
    NSObject<UpdateListener> *updateListener;
    UITableView *myTableView;
    NSArray *listObject;
    NSString *filter;

}
@property(nonatomic, retain) NSString *filter;
@property(nonatomic, retain) NSArray *listObject;
@property(nonatomic, retain) UITableView *myTableView;
@property(nonatomic, retain) NSString *entity;
@property(nonatomic, retain) Item *item;
@property(nonatomic, retain) NSString *code;
@property(nonatomic, retain) NSObject<UpdateListener> *updateListener;

- (id)init:(NSString *)newField item:(Item *)newItem updateListener:(NSObject<UpdateListener> *)newListener;
- (void)searchItems;

@end
