//
//  SelectFieldViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "LayoutDetailViewController.h"
#import "FieldsManager.h"

@class LayoutDetailViewController;

@interface SelectFieldViewController : UITableViewController {
    NSString *entity;
    NSString *subtype;
    NSMutableArray *fields;
    LayoutDetailViewController *parent;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) NSMutableArray *fields;
@property (nonatomic, retain) LayoutDetailViewController *parent;

- (id)initWithEntity:(NSString *)newEntity subtype:(NSString *)newSubtype parent:(LayoutDetailViewController *)parent selected:(NSMutableArray *)selected;

@end
