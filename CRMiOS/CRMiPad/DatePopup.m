//
//  DatePopup.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DatePopup.h"

@implementation DatePopup

@synthesize popoverController;
@synthesize field;
@synthesize item;
@synthesize listener;
@synthesize duration;
@synthesize datePicker;

- (id)initWithField:(CRMField *)newField item:(Item *)newItem listener:(NSObject<SelectionListener> *)newListener {
    self = [super init];
    self.field = newField;
    self.item = newItem;
    self.listener = newListener;
    
    NSString *startTimeS = [self.item.fields objectForKey:@"StartTime"];
    NSString *endTimeS = [self.item.fields objectForKey:@"EndTime"];
    
    if (startTimeS.length > 0 && endTimeS.length > 0) {
        NSDate *startTime = [EvaluateTools dateFromString:startTimeS];
        NSDate *endTime = [EvaluateTools dateFromString:endTimeS];
        self.duration = [endTime timeIntervalSinceDate:startTime];
    } else {
        self.duration = 0;
    }
    return self;
}

- (void) show:(CGRect)rect parentView:(UIView *)parentView {
    if ([self.popoverController isPopoverVisible]) {
        //close the popover view if toolbar button was touched
        //again and popover is already visible
        
        [self.popoverController dismissPopoverAnimated:YES];
        [self release];
        return;
    }
    
    //build our custom popover view
    UINavigationController *popoverContent = [[UINavigationController alloc]
                                              initWithRootViewController:self];
    
    //resize the popover view shown
    //in the current view to the view's size
    
    self.title = self.field.displayName;
    self.contentSizeForViewInPopover = CGSizeMake(320, 220);
    UIView *mainView = [[UIView alloc] init];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 220)];

    [UITools initDatePicker:self.datePicker value:[self.item.fields objectForKey:field.code] type:self.field.type];
    [self.datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [mainView addSubview:self.datePicker];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DATE_CLEAR", @"Clear") style:UIBarButtonItemStyleDone target:self action:@selector(clear)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    [self setView:mainView];
    [mainView release];
    //create a popover controller
    self.popoverController = [[[UIPopoverController alloc]
                              initWithContentViewController:popoverContent] autorelease];
    
    //present the popover view non-modal with a
    //refrence to the toolbar button which was pressed
    [self.popoverController presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [popoverContent release];
    
}

- (void)changeDate:(id)sender {
    NSDateFormatter *formatter = [UITools getDateFormatter:field.type];
    NSString *dateString = [formatter stringFromDate:[self.datePicker date]];
    [listener didSelect:field.code valueId:dateString display:nil];
    //when start time > end time set : end time = start time + 1 hour
    if ([field.code isEqualToString:@"StartTime"] && self.duration > 0) {
        [listener didSelect:@"EndTime" valueId:[formatter stringFromDate:[NSDate dateWithTimeInterval:self.duration sinceDate:self.datePicker.date]] display:nil];
    }
}

- (void)clear {

    [listener didSelect:field.code valueId:@"" display:nil];
    [self.popoverController dismissPopoverAnimated:YES];
}

- (void)done {
    NSDateFormatter *formatter = [UITools getDateFormatter:field.type];
    NSString *dateString = [formatter stringFromDate:self.datePicker.date];
    [listener didSelect:field.code valueId:dateString display:nil];
    [self.popoverController dismissPopoverAnimated:YES];
}

@end
