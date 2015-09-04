//
//  DateSelectController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 8/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRMField.h"
#import "Item.h"
#import "UpdateListener.h"
#import "FieldsManager.h"
#import "ValidationTools.h"
#import "UITools.h"

@interface DateSelectController : UIViewController {
    UIDatePicker *datePicker;
    NSString *field;
    Item *item;
    NSObject<UpdateListener> *updateListener;
}

@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) NSString *field;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) NSObject<UpdateListener> *updateListener;

- (id)init:(NSString *)newField item:(Item *)newItem updateListener:(NSObject<UpdateListener> *)newListener;
- (void)done;
- (void)clear;

@end
