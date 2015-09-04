//
//  DatePopupViewController.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DatePopupViewController.h"
#import "DatetimeHelper.h"

@implementation DatePopupViewController

@synthesize datePicker,popover,editController,editPath;

- (id)initWithDate:(NSString*)newDate fieldName:(NSString*)fName fieldType:(NSString*)type parentController:(EditViewController *)edit{
    self = [super init];

    newDate = newDate == nil ?@"":newDate;
    
    fieldName = fName;
    fieldType = type;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.editController = edit;
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 400, 180)];
    
    NSDate *d;
    
    if([type isEqualToString:@"date"]){
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        d = [DatetimeHelper stringToDate:[newDate isEqualToString:@""]?[DatetimeHelper serverDate:[NSDate date]]:newDate];
    }else{
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        d = [DatetimeHelper stringToDateTime:[newDate isEqualToString:@""]?[DatetimeHelper serverDateTime:[NSDate date]]:newDate];
    }

    [datePicker setDate:d animated:NO];
    [self.view addSubview:datePicker];
    [datePicker release];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", Nil) style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLEAR", Nil) style:UIBarButtonItemStyleDone target:self action:@selector(clear)];
    
    return self;
}

-(void)dealloc{
    [datePicker release];
    [super dealloc];
}

- (void)done{
    
    if([fieldType isEqualToString:@"date"]){
       // [dateFormatter setDateFormat:@"yyyy-MM-dd"];
       // NSString *strDate = [dateFormatter stringFromDate:datePicker.date];
        [editController done:[DatetimeHelper serverDate:datePicker.date] editPath:editPath];
    }else{
       // [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'000Z'"];
       // NSString *strDate = [dateFormatter stringFromDate:datePicker.date];
        [editController done:[DatetimeHelper serverDateTime:datePicker.date] editPath:editPath];
    }
    [self.popover dismissPopoverAnimated:YES];
}

- (void)clear{
    [editController clear:editPath];
    [self.popover dismissPopoverAnimated:YES];
}

- (void)show:(UIView*)containView parentView:(UIView*)parent{
    
    if([popover isPopoverVisible]){
        [popover dismissPopoverAnimated:YES];
        [popover release];
        [self release];
        return;
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    self.contentSizeForViewInPopover = datePicker.frame.size;
    self.popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [nav release];
    
    CGRect rect = [containView.superview convertRect:containView.frame fromView:parent];
    
    [self.popover presentPopoverFromRect:rect inView:parent permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}


@end
