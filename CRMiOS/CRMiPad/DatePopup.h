//
//  DatePopup.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Configuration.h"
#import "SelectionListener.h"
#import "CRMField.h"
#import "UITools.h"
#import "CurrentUserManager.h"
#import "ValidationTools.h"

@interface DatePopup : UIViewController {
    UIPopoverController *popoverController;
    CRMField *field;
    Item *item;
    NSObject <SelectionListener> *listener;
    NSTimeInterval duration;
    UIDatePicker *datePicker;

}
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) CRMField *field;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) NSObject <SelectionListener> *listener;
@property (assign) NSTimeInterval duration;
@property (nonatomic, retain) UIDatePicker *datePicker;

- (id)initWithField:(CRMField *)newField item:(Item *)newItem listener:(NSObject <SelectionListener> *)newListener;
- (void)show:(CGRect)rect parentView:(UIView *)parentView;
- (void)clear;

@end
