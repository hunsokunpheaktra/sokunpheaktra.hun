//
//  PlaceholderPopup.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 8/23/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectionListener.h"
#import "EntityManager.h"
#import "RelationManager.h"
#import "FieldsManager.h"
#import "LikeCriteria.h"
#import "FilterManager.h"

@interface WholesalerPopup : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> { 
    NSString *subtype;
    NSString *code;
    NSString *value;
    UIPopoverController *popoverController;
    NSArray *values; 
    NSObject <SelectionListener> *listener;  
    NSString *otherEntity;
    NSString *catalogFilter;
    NSString *stateFilter;
    
}

@property (nonatomic, retain) NSString *catalogFilter;
@property (nonatomic, retain) NSString *stateFilter;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *otherEntity;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSObject <SelectionListener> *listener;

- (id)initWithField:(NSString *)code subtype:(NSString *)subtype value:(NSString *)value listener:(NSObject <SelectionListener> *)listener;
- (void) show:(CGRect)rect parentView:(UIView *)parentView;
- (void)filterData;

@end

