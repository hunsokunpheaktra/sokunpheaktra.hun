//
//  UITool.m
//  SyncForce
//
//  Created by Gaeasys Admin on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UITool.h"
#import "DatetimeHelper.h"
#import "ValuesCriteria.h"
#import "PicklistForRecordTypeInfoManager.h"
#import "EntityManager.h"
#import "CustomUITextField.h"

@implementation UITool

+ (void)setupEditCell:(UITableViewCell *)cell fieldsInfo:(Item *)fieldsInfo value:(NSString *)value tag:(int)tag delegate:(NSObject <UITextFieldDelegate> *)delegate isMadatory:(BOOL)madatory{
    // empty the cell contents
    
    for (UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    CGRect bounds = cell.contentView.bounds;
    CGRect rect = CGRectInset(bounds, 9.0, 9.0);
    rect = CGRectOffset(rect, 290.0, 0.0);
    
    NSString *fieldtype = [fieldsInfo.fields valueForKey:@"type"];
    
    if ([fieldtype isEqualToString:@"boolean"]) {
        
        // Display check box if field type is Boolean
        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:rect];
        mySwitch.tag = tag;
        
        if ([value isEqualToString:@"true"]) {
            mySwitch.on = YES;
        } else {
            mySwitch.on = NO;
        }
        
        [mySwitch addTarget:delegate action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        
        [cell.contentView addSubview:mySwitch];
        [mySwitch release];
        
    } else if ([fieldtype isEqualToString:@"id"]
               || [fieldtype isEqualToString:@"picklist"]
               || [fieldtype isEqualToString:@"datetime"]
               || [fieldtype isEqualToString:@"date"] || [fieldtype isEqualToString:@"reference"]) {
        
            UILabel *label = [[UILabel alloc]initWithFrame:rect];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.tag = tag;
            [label setOpaque:NO];
            [label setBackgroundColor:Nil];
            label.text = value;
            if ([fieldtype isEqualToString:@"datetime"] || [fieldtype isEqualToString:@"date"]) {
                label.text = [DatetimeHelper display:value];
            }
            [cell.contentView addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [label release];
        
    }else {
        
        CustomUITextField *textField = [[CustomUITextField alloc] initWithFrame:rect];
       // textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textField.borderStyle = UITextBorderStyleNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //  Set the keyboard's return key label to 'Next'.
        //
        [textField setReturnKeyType:UIReturnKeyDone];
        textField.delegate = delegate;
        
        //  Make the clear button appear automatically.
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        
        textField.tag = tag;
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [textField setPlaceholder:[fieldsInfo.fields valueForKey:@"label"]];
        
        //  When I edit numeric fields like telefone numer, the keyboard should switch to numbers automatically
        if ([fieldtype isEqualToString:@"Number"] || [fieldtype isEqualToString:@"Integer"] || [fieldtype isEqualToString:@"Currency"]) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
        } else if ([fieldtype isEqualToString:@"Phone"]) {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }
        textField.text = value;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        [cell.contentView addSubview:textField]; 
        
        [textField release];
    }
    if(madatory){
        UIView *madatoryView = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x-14, rect.origin.y, 5, rect.size.height)];
        madatoryView.layer.cornerRadius = 3;
        madatoryView.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:madatoryView];
        [madatoryView release];
    }
}


+ (void)setupRow:(UITableViewCell*)cell dataModel:(NSObject<DataModel>*)model tag:(int)tag delegate:(NSObject <UITextFieldDelegate> *)delegate{
    
    while ([cell.contentView.subviews count] > 0) {
        for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    }
    [cell.textLabel removeFromSuperview];
    
    CGRect rect = cell.contentView.bounds;
    rect.size.width = (rect.size.width/[model getColumnCount]);
    
    for(int i=0;i<[model getColumnCount];i++){
        
        int type = [model getColumType:i];
        if(type == TYPE_BOOLEAN){
            
            UISwitch *myswitch = [[UISwitch alloc] initWithFrame:rect];
            [cell.contentView addSubview:myswitch];
            [myswitch release];
            
        }else if(type == TYPE_DATETIME){
            
            UILabel *label = [[UILabel alloc] initWithFrame:rect];
            label.text = [model getValueAt:tag columnIndex:i];
            [cell.contentView addSubview:label];
            [label release];
            
        }else{
            UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 30)];
            textfield.borderStyle = UITextBorderStyleRoundedRect;
            textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfield.text = [model getValueAt:tag columnIndex:i];;
            textfield.delegate = delegate;
            [cell.contentView addSubview:textfield];
            [textfield release];
        }
        
        rect.origin.x = (rect.origin.x+rect.size.width+4);
        
    }
    
}

+ (NSString *)formatDateTime:(Item *)fieldsInfo value:(NSString *)value shortStyle:(BOOL)shortStyle {
    //NSString *formatedVal = [[NSString alloc]init];
//    CRMField *field = [FieldsManager read:entity field:code];
//    
//    NSTimeZone *timzone=[EvaluateTools getTimeZone];
//    
//    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
//    [formatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    
//    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
//    [formatter2 setTimeZone:timzone];
//    
//    if (shortStyle) {
//        [formatter2 setDateStyle:NSDateFormatterShortStyle];
//    } else {
//        [formatter2 setDateStyle:NSDateFormatterLongStyle];
//    }
//    
//    // format the value depending on its type
//    if ([field.type isEqualToString:@"Date/Time"]) {
//        [formatter1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
//        if (shortStyle) {
//            [formatter2 setTimeStyle:NSDateFormatterShortStyle];
//        } else {
//            [formatter2 setTimeStyle:NSDateFormatterMediumStyle];
//        }
//    } else if ([field.type isEqualToString:@"Date"]) {
//        [formatter1 setDateFormat:@"yyyy-MM-dd"];
//        [formatter2 setTimeStyle:NSDateFormatterNoStyle];
//    }
//    
//    NSDate *date = [formatter1 dateFromString:value];
//    formatedVal = [formatter2 stringFromDate:date];
//    
//    [formatter1 release];
//    [formatter2 release];
//    return formatedVal;
    return @"";
}




@end


