//
//  FilterListPopup.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 10/6/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateListener.h"
#import "FilterManager.h"

@interface FilterListPopup : UIViewController<UITableViewDataSource, UITableViewDelegate>  {
    NSString *subtype;
    NSMutableArray *filters; 
    NSObject <UpdateListener> *listener;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *filters;
@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) NSObject <UpdateListener> *listener;

- (id)initPopup:(NSString *)subtype listener:(NSObject <UpdateListener> *)listener;
- (void) showList:(id)sender;

@end
