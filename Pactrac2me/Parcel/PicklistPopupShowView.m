//
//  PicklistPopupShowView.m
//  Thing
//
//  Created by Hun Sokunpheaktra on 9/25/12.
//
//

#import "PicklistPopupShowView.h"
#import "ManualReminderInput.h"

@implementation PicklistPopupShowView

@synthesize listItems,updateListener,fieldName;

-(id)initWithListDatas:(NSArray*)listDatas frame:(CGRect)frame mainView:(UIView*)mainView selectedVal:(NSString*)val type:(NSString*)type{
    
    self = [super init];
    self.listItems = listDatas;
    
    selectedValue = val==nil ? @"" : val;
    parentView = mainView;
    fieldType = type;
    
    self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    isiPhone = [[UIDevice currentDevice].model rangeOfString:@"iPhone"].location != NSNotFound || [[UIDevice currentDevice].model rangeOfString:@"iPod"].location != NSNotFound;
    CGRect rect = mainView.frame;
    
    if(isiPhone){
        self.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        self.view.center = CGPointMake(rect.size.width/2, rect.size.height+200);
        
        UIView *background = [[[UIView alloc] initWithFrame:rect] autorelease];
        background.backgroundColor = [UIColor blackColor];
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        background.alpha = 0.7;
        [self.view addSubview:background];
        
        if([type isEqualToString:@"date"] || [type isEqualToString:@"longdate"]){
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            formatter.dateFormat = [type isEqualToString:@"date"]? @"yyyy-MMM-dd":@"yyyy-MMM-dd HH:mm";
            
            datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, rect.size.height-170, rect.size.width, 170)];
            datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            datePicker.datePickerMode = [type isEqualToString:@"date"] ?UIDatePickerModeDate:UIDatePickerModeDateAndTime;
            datePicker.date = val != nil ? [formatter dateFromString:val] : [NSDate date];
            [formatter release];
            [self.view addSubview:datePicker];
            [datePicker release];
            
        }else{
            picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, rect.size.height-170, rect.size.width, 170)];
            picker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            picker.showsSelectionIndicator = YES;
            picker.dataSource = self;
            picker.delegate = self;
            if(![selectedValue isEqualToString:@""]){
                [picker selectRow:[listItems indexOfObject:selectedValue] inComponent:0 animated:NO];
            }
            [self.view addSubview:picker];
            [picker release];
        }
        
        UIToolbar *toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, rect.size.height-214, rect.size.width, 44)] autorelease];
        toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        toolBar.barStyle = UIBarStyleBlackOpaque;
        
        UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
        UIBarButtonItem *cancel = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
        UIBarButtonItem *clear = [[[UIBarButtonItem alloc] initWithTitle:MSG_CLEAR style:UIBarButtonItemStyleBordered target:self action:@selector(clear)] autorelease];
        UIBarButtonItem *done=nil;
        
        if ([type isEqualToString:@"longdate"]) { 
            done= [[[UIBarButtonItem alloc]initWithTitle:EXPORT_CALENDAR style:UIBarButtonItemStyleDone target:self action:@selector(done)]autorelease];
        }else{
            done = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
        }
        
        toolBar.items = [NSArray arrayWithObjects:cancel,space,clear,done, nil];
        [self.view addSubview:toolBar];
        
        [self.view removeFromSuperview];
        [parentView.superview addSubview:self.view];
    }else{
        
        UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:self] autorelease];
        popover = [[UIPopoverController alloc] initWithContentViewController:nav];
        
        if([type isEqualToString:@"date"]|| [type isEqualToString:@"longdate"]){
            
            popover.popoverContentSize = CGSizeMake(400, 216);
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = [type isEqualToString:@"date"]? @"yyyy-MMM-dd":@"yyyy-MMM-dd HH:mm";
            
            if([type isEqualToString:@"longdate"] && val.length == 11){
                val = [val stringByAppendingString:@" 00:00"];
            }
            
            datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 400, 216)];
            datePicker.datePickerMode = [type isEqualToString:@"date"] ?UIDatePickerModeDate:UIDatePickerModeDateAndTime;
            datePicker.date = val != nil ? [formatter dateFromString:val] : [NSDate date];
            [formatter release];
            [self.view addSubview:datePicker];
            [datePicker release];
            
            self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
            
            UIBarButtonItem *barClear = [[[UIBarButtonItem alloc] initWithTitle:MSG_CLEAR style:UIBarButtonItemStyleBordered target:self action:@selector(clear)] autorelease];
            UIBarButtonItem *barDone;
            
            if ([type isEqualToString:@"longdate"]) {
                barDone = [[[UIBarButtonItem alloc]initWithTitle:EXPORT_CALENDAR style:UIBarButtonItemStyleDone target:self action:@selector(done)]autorelease];
            }else{
                barDone = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
            }
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:barDone,barClear, nil];
            
        }else{
            popover.popoverContentSize = CGSizeMake(400, listItems.count * 40 + 40);
            
            tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
            tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            tableView.delegate = self;
            tableView.dataSource = self;
            [self.view addSubview:tableView];
            [tableView release];
            
        }
        
    }
    
    
    return self;
}

-(void)done{
    
    NSString *value;
    if([fieldType isEqualToString:@"date"] || [fieldType isEqualToString:@"longdate"]){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =[fieldType isEqualToString:@"date"]? @"yyyy-MMM-dd":@"yyyy-MMM-dd HH:mm";
        value = [formatter stringFromDate:datePicker.date];
        
        [formatter release];
        
    }else{
        value = [listItems objectAtIndex:[picker selectedRowInComponent:0]];
    }
    
    [updateListener didUpdate:self.fieldName value:value];
    [self hide];
}
-(void)clear{
    [updateListener didUpdate:self.fieldName value:@""];
    [self hide];
}
-(void)cancel{
    [self hide];
}

-(void)show:(UIView*)mainView{
    
    CGRect frame = parentView.frame;
    if(isiPhone){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        self.view.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        
        [UIView commitAnimations];
    }else{
        
        CGRect rect = [parentView convertRect:parentView.frame fromView:mainView];
        [popover presentPopoverFromRect:rect inView:parentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}

-(void)hide{
    
    CGRect frame = parentView.frame;
    if(isiPhone){
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        self.view.center = CGPointMake(frame.size.width/2, frame.size.height*5);
        
        [UIView commitAnimations];
        
    }else{
        [popover dismissPopoverAnimated:YES];
    }
    [self.view removeFromSuperview];
}

#pragma UITableView datasurce

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *value = [listItems objectAtIndex:indexPath.row];
    
    if([selectedValue isEqualToString:value]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = value;

    return cell;
}

#pragma UITableView delegate

-(void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *value = [listItems objectAtIndex:indexPath.row];
    selectedValue = value;
    [updateListener didUpdate:self.fieldName value:value];
    [tv reloadData];
    [popover dismissPopoverAnimated:YES];
    
}

#pragma UIPickerView datasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return listItems.count;
}

#pragma UIPickerView delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *value = [listItems objectAtIndex:row];
    value = value;
    return value;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

@end
