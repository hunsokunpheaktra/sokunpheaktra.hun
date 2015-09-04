//
//  DateSelectController.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 8/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "DateSelectController.h"

@implementation DateSelectController

@synthesize field, item, updateListener, datePicker;

- (id)init:(NSString *)newField item:(Item *)newItem updateListener:(NSObject<UpdateListener> *)newListener
{
    self = [super init];
    self.field = newField;
    self.item = newItem;
    self.updateListener = newListener;
    self.navigationItem.title = [FieldsManager read:self.item.entity field:field].displayName ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    return self;
}



#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIView *mainView = [[UIView alloc] init];
    self.datePicker = [[UIDatePicker alloc]init];
    
    //Set Date and DateTime Format for pickerView
    
    CRMField *crmField = [FieldsManager read:self.item.entity field:self.field];

    
    [UITools initDatePicker:self.datePicker value:[self.item.fields objectForKey:self.field] type:crmField.type];

    [mainView addSubview:self.datePicker];
    [mainView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,datePicker.frame.size.height, datePicker.frame.size.width, 40)];
    toolbar.items = [NSMutableArray arrayWithObject:[[UIBarButtonItem alloc]initWithTitle:@"Clear" style:UIBarButtonItemStyleDone target:self action:@selector(clear)]];
    [mainView addSubview:toolbar];
    [self setView:mainView];
}

- (void)clear{

    [self.item.fields setValue:@"" forKey:self.field];
    [self.updateListener mustUpdate];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)done {
    CRMField *crmField = [FieldsManager read:self.item.entity field:self.field];

    NSDateFormatter *formatter = [UITools getDateFormatter:crmField.type];
    [self.item.fields setValue:[formatter stringFromDate:[self.datePicker date]] forKey:self.field];
    
    //when start time > end time set : end time = start time + 1 hour
    if ([self.field isEqualToString:@"StartTime"]) {
        if (![ValidationTools dateTimeCheck:[self.item.fields objectForKey:@"StartTime"] end:[self.item.fields objectForKey:@"EndTime"]]) {
             [ self.item.fields setValue:[formatter stringFromDate:[NSDate dateWithTimeInterval:3600 sinceDate:[self.datePicker date]]] forKey:@"EndTime"];
            }
    
    }
    
    [self.updateListener mustUpdate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
