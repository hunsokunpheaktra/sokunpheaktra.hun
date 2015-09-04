//
//  RelatedPopup.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectionListener.h"
#import "EntityManager.h"
#import "RelationManager.h"
#import "FieldsManager.h"
#import "LikeCriteria.h"
#import "OrCriteria.h"
#import "ContainsCriteria.h"
#import "FilterManager.h"

@interface RelatedPopup : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> { 
    NSString *subtype;
    NSString *code;
    NSString *value;
    UIPopoverController *popoverController;
    NSArray *values; 
    NSObject <SelectionListener> *listener;  
    NSString *otherEntity;
    NSString *nameFilter;
    Item *parentItem;
    BOOL seeAll;
}
@property (nonatomic, retain) NSString *nameFilter;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *otherEntity;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSObject <SelectionListener> *listener;
@property (nonatomic, retain) Item *parentItem;
@property (readwrite) BOOL seeAll;

- (id)initWithField:(NSString *)code subtype:(NSString *)subtype value:(NSString *)value parentItem:(Item *)parentItem listener:(NSObject <SelectionListener> *)listener;
- (void)show:(CGRect)rect parentView:(UIView *)parentView;
- (void)filterData;

@end
