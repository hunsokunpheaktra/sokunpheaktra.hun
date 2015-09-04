//
//  LayoutDetailViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "EntityInfo.h"

#import "SelectFieldViewController.h"
#import "FieldsManager.h"
#import "LayoutFieldManager.h"
#import "ConfigEntity.h"

@interface LayoutDetailViewController : UITableViewController <UIAlertViewDelegate> {
    NSMutableArray *fields;
    NSString *entity;
    NSString *subtype;
}

@property (nonatomic, retain) NSArray *fields;
@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *subtype;

- (id)initWithEntity:(NSString *)entity subtype:(NSString *)subtype;
- (void)addField:(NSString *)field;
- (IBAction)reset;

@end
