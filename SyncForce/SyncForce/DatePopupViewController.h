//
//  DatePopupViewController.h
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditViewController.h"

@interface DatePopupViewController : UIViewController{
    
    UIDatePicker *datePicker;
    UIPopoverController *popover;
    NSString *fieldName;
    
    EditViewController *editController;
    NSString *fieldType;
    NSIndexPath *editPath;
}

@property (nonatomic,retain) NSIndexPath *editPath;
@property (nonatomic,retain) EditViewController *editController;
@property (nonatomic,retain) UIPopoverController *popover;
@property (nonatomic,retain) UIDatePicker *datePicker;

- (id)initWithDate:(NSString*)newDate fieldName:(NSString*)fName fieldType:(NSString*)type parentController:(EditViewController*)edit;
- (void)show:(UIView*)containView parentView:(UIView*)parent;
- (void)done;
- (void)clear;

@end
