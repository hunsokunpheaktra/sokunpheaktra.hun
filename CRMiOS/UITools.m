//
//  UITools.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "UITools.h"


@implementation UITools


+ (NSString *)multiSelectValue:(NSString *)entity field:(NSString *)field value:(NSString *)value {
    NSArray *chunks = [value componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";,"]];
    NSMutableString *displayText = [[NSMutableString alloc] initWithCapacity:1];
    for (NSString *chunk in chunks) {
        NSString *tmp = [PicklistManager getPicklistDisplay:entity field:field value:chunk];
        if (tmp != nil) {
            if ([displayText length] > 0) {
                [displayText appendString:@", "];
            }
            [displayText appendString:tmp];
        }
    }
    return displayText;
}

+ (void)setupCell:(UITableViewCell *)cell subtype:(NSString *)subtype code:(NSString *)code value:(NSString *)value 
         grouping:(BOOL)grouping item:(Item *)item iphone:(BOOL)iphone {
    // empty the cell contents
    while ([cell.contentView.subviews count] > 0) {
        [[cell.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    NSString *entity = sinfo == nil ? subtype : sinfo.entity;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = Nil;
    CRMField *field = [FieldsManager read:entity field:code];
    
    // display grouping section
    if (grouping) {
        
        cell.textLabel.text = [EvaluateTools translateWithPrefix:code prefix:@"HEADER_"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([[EvaluateTools translateWithPrefix:code prefix:@"HEADER_"] rangeOfString:[EvaluateTools translateWithPrefix:@"%ADDRESS%" prefix:@"HEADER_"]].length != NSNotFound) {
            if (value == nil || [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryNone; 
            } else {
                cell.detailTextLabel.numberOfLines = 3;
                cell.detailTextLabel.text = value;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
        } else {
            cell.detailTextLabel.text = value;
        }
        
    } else if (field == nil) {
        cell.textLabel.text = [EvaluateTools formatDisplayField:code];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.text = value;
    } else {
        NSString *customName = [sinfo customName:field.code];
        cell.textLabel.text = customName != nil ? customName : field.displayName;
        // format the value depending on its type
        if ([field.type isEqualToString:@"Date/Time"] || [field.type isEqualToString:@"Date"]) {
            cell.detailTextLabel.text = [UITools formatDateTime:field.type value:value shortStyle:iphone];
        } else if ([field.type isEqualToString:@"Checkbox"]) {
            if ([value isEqualToString:@"true"]) {
                cell.detailTextLabel.text = NSLocalizedString(@"YES", nil);
            } else {
                cell.detailTextLabel.text = NSLocalizedString(@"NO", nil);
            }
        } else if ([field.code rangeOfString:@"Email"].length > 0 || [field.code rangeOfString:@"Location"].length > 0 || [field.code rangeOfString:@"Address"].length > 0 || [field.code rangeOfString:@"WebSite"].length > 0
                   || ([field.type isEqualToString:@"Phone"] && iphone && [field.code rangeOfString:@"Fax"].length==0)
                   || ([field.code isEqualToString:@"FileNameOrURL"] && [[item.fields objectForKey:@"FileExtension"] isEqualToString:@"URL"])) {
            //cell.detailTextLabel.text = value;
            if (value == nil || [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                
                cell.detailTextLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryNone; 
            } else {
                cell.detailTextLabel.text = value;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
            }
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
        } else if ([field.type isEqualToString:@"Picklist"] && ![RelationManager isCalculated:subtype field:field.code]
                    && ![RelationManager isKey:subtype field:field.code]) {
            
            cell.detailTextLabel.text = [PicklistManager getPicklistDisplay:entity field:field.code value:value];
        } else if ([field.type isEqualToString:@"Multi-Select Picklist"]) {
            cell.detailTextLabel.text = [UITools multiSelectValue:entity field:field.code value:value];
            
        } else if (([field.type isEqualToString:@"Currency"] || [field.type isEqualToString:@"Number"] || [field.type isEqualToString:@"Integer"]) && ![field.code isEqualToString:@"Probability"]) {
            
            NSString *formattedValue = [UITools formatNumber:value];
            if ([field.type isEqualToString:@"Currency"]) {
                cell.detailTextLabel.text = [UITools formatCurrency:formattedValue item:item];
            } else {
                // fields such as CustomNumber2X are percentages.
                if ([field.type isEqualToString:@"Number"] && [field.code characterAtIndex:field.code.length - 2] == '2') {
                    formattedValue = [NSString stringWithFormat:@"%@%%", formattedValue];
                }
                cell.detailTextLabel.text = formattedValue;
            }
    
        } else if ([field.type isEqualToString:@"Text (Long)"]) {
            cell.detailTextLabel.numberOfLines = 100;
            [cell.detailTextLabel setText:value];
        } else {
            cell.detailTextLabel.text = value;
        }
    }
    
}

+ (void)handleCellClick:(UIViewController *)controller code:(NSString *)code item:(Item *)item updateListener:(NSObject<UpdateListener> *)listener {
    NSString *entityCode = item.entity;
    if ([item isMemberOfClass:[SublistItem class]]) {
        entityCode = [NSString stringWithFormat:@"%@ %@", item.entity, ((SublistItem *)item).sublist];
    }
    CRMField *field = [FieldsManager read:entityCode field:code];
    if (field == nil) return;
    if ([field.code rangeOfString:@"Email"].length > 0) {
        
        NSString *email = [item.fields objectForKey:code];
        
        if ([[email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            return;
        }
        
        MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = [[MailControllerDelegate alloc] initWithItem:item update:listener];
        [mailController setToRecipients:[NSMutableArray arrayWithObject:email]];
        if (mailController) [controller presentModalViewController:mailController animated:YES];
        [mailController release];
        
    } else if ([field.code rangeOfString:@"WebSite"].length > 0 || ([field.code isEqualToString:@"FileNameOrURL"] && [[item.fields objectForKey:@"FileExtension"] isEqualToString:@"URL"])) {
        NSString *strUrl = [item.fields objectForKey:code];
        if (strUrl == nil || [[strUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            return;
        }
        NSString *url = [strUrl hasPrefix:@"http"] ? strUrl : [NSString stringWithFormat:@"http://%@", strUrl];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        
    } else if ([field.type isEqualToString:@"Phone"] && [field.code rangeOfString:@"Fax"].length==0) {
        NSString *telnum = [[item.fields objectForKey:code] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *url = [NSString stringWithFormat:@"tel:%@", telnum];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    } else if ([field.code rangeOfString:@"Location"].length > 0 || [field.code rangeOfString:@"Address"].length > 0) {
        NSString *value = [item.fields objectForKey:field.code];
        if ([[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            return;
        }
        MapViewController *map = [[MapViewController alloc] initWithItem:item];
        if ([controller isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController*)controller pushViewController:map animated:YES];
        } else {
            [controller.navigationController pushViewController:map animated:YES];
        }
        [map release];
    }
    
}

+ (NSString *)formatDateTime:(NSString *)type value:(NSString *)value shortStyle:(BOOL)shortStyle {
    NSTimeZone *timeZone = [CurrentUserManager getUserTimeZone];
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setTimeZone:timeZone];
    
    if (shortStyle) {
        [formatter2 setDateStyle:NSDateFormatterShortStyle];
    } else {
        [formatter2 setDateStyle:NSDateFormatterLongStyle];
    }
    
    // format the value depending on its type
    if ([type isEqualToString:@"Date/Time"]) {
        [formatter1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        if (shortStyle) {
            [formatter2 setTimeStyle:NSDateFormatterShortStyle];
        } else {
            [formatter2 setTimeStyle:NSDateFormatterMediumStyle];
        }
    } else if ([type isEqualToString:@"Date"]) {
        [formatter2 setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter1 setDateFormat:@"yyyy-MM-dd"];
        [formatter2 setTimeStyle:NSDateFormatterNoStyle];
    }
    
    NSDate *date = [formatter1 dateFromString:value];
    NSString *formatedVal = [formatter2 stringFromDate:date];
    
    [formatter1 release];
    [formatter2 release];
    return formatedVal;
}

+ (void)setupEditCell:(UITableViewCell *)cell subtype:(NSString *)subtype field:(CRMField *)field value:(NSString *)value tag:(int)tag delegate:(NSObject <UITextViewDelegate, UITextFieldDelegate> *)delegate item:(Item *)item iphone:(BOOL)iphone {
    // empty the cell contents
    while ([cell.contentView.subviews count] > 0) {
        [[cell.contentView.subviews objectAtIndex:0] removeFromSuperview];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    CGRect bounds = [cell.contentView bounds];
    
    CGRect rect = CGRectInset(bounds, 9.0, 9.0);
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    NSString *entity = sinfo == nil ? subtype : sinfo.entity; 
    
    if (iphone) {
        rect = CGRectOffset(rect, 80.0, 0.0);
        rect.size.width = rect.size.width - 80;
    } else {
        rect = CGRectOffset(rect, 160.0, 0.0);
        rect.size.width = rect.size.width - 160;
    }
    // to fix a display bug that occurs sometimes when we scroll down fast
    if (rect.size.height > 25) {
        rect.size.height = 25;
    }
    NSString *otherEntity = [RelationManager getRelatedEntity:subtype field:field.code];
    if ([field.type isEqualToString:@"Checkbox"]) {
        if ([Configuration isYes:@"useCheckbox"]) {
            
            UIButton *checkbox = [UIButton buttonWithType:UIButtonTypeCustom];
            rect.origin.x += rect.size.width - 50;
            [checkbox setFrame:CGRectMake(rect.origin.x, rect.origin.y, 32, 32)];
            checkbox.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            checkbox.tag = tag;
            UIImage *img;
            if ([value isEqualToString:@"true"]) {
                img = [UIImage imageNamed:@"checkbox_full.png"];
            } else {
                img = [UIImage imageNamed:@"checkbox_empty"];
            }
            [checkbox setImage:img forState:UIControlStateNormal];
            [checkbox addTarget:delegate action:@selector(checkboxchange:) forControlEvents:UIControlEventTouchUpInside];
            checkbox.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [cell.contentView addSubview:checkbox];
            
        } else {
        
            // Display check box if field type is Boolean
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            rect.origin.x += rect.size.width - 96;
            UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:rect];
            
            mySwitch.tag = tag;
            
            if ([value isEqualToString:@"true"]) {
                mySwitch.on = YES;
            } else {
                mySwitch.on = NO;
            }
            
            [mySwitch addTarget:delegate action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
            mySwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [cell.contentView addSubview:mySwitch];
            [mySwitch release];
            
        }
        
    } else if ([field.type isEqualToString:@"ID"]
               || [field.type isEqualToString:@"Picklist"]
               || [field.type isEqualToString:@"Multi-Select Picklist"]
               || [field.type isEqualToString:@"Date/Time"]
               || [field.type isEqualToString:@"Date"] || otherEntity != nil) {
        Item *otherItem = [RelationManager getRelatedItem:subtype field:field.code value:value];
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
        label.tag = tag;
        [label setOpaque:NO];
        [label setBackgroundColor:nil];
        
        if (otherItem != nil) {
            NSString *otherSubType = [Configuration getSubtype:otherItem];
            NSObject <Subtype> *otherInfo = [Configuration getSubtypeInfo:otherSubType];
            label.text = [otherInfo getDisplayText:otherItem];   
        } else if ([field.type isEqualToString:@"Date/Time"] || [field.type isEqualToString:@"Date"]) {
            label.text = [UITools formatDateTime:field.type value:value shortStyle:iphone];
        } else if ([field.type isEqualToString:@"ID"]) {
            label.text = @"";
            for (Relation *relation in [Relation getEntityRelations:entity]) {
                if ([relation.srcEntity isEqualToString:entity] && [relation.srcKey isEqualToString:field.code]) {
                    if ([relation.srcFields count] > 0) {
                        label.text = [item.fields objectForKey:[relation.srcFields objectAtIndex:0]];
                    }
                    break;
                }
            }
        } else if ([field.type isEqualToString:@"Multi-Select Picklist"]) {
            label.text = [UITools multiSelectValue:entity field:field.code value:value];
        } else {
            label.text = [PicklistManager getPicklistDisplay:entity field:field.code value:value];
        }
        
        [cell.contentView addSubview:label];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [label release];
        
        
    } else if ([field.type isEqualToString:@"Text (Long)"]) {
        rect.size.height = 100;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITextView *textView = [[UITextView alloc] initWithFrame:rect];
        if (!iphone) {
            textView.layer.cornerRadius = 8;
            textView.layer.borderWidth = 1;
            textView.layer.borderColor = [[UIColor grayColor] CGColor];
            textView.clipsToBounds = YES;
        }  
        textView.tag = tag;
        textView.font = [UIFont systemFontOfSize:16];
        textView.delegate = delegate;
        [textView setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textView setText:value];
        [textView setReturnKeyType:UIReturnKeyDefault];
        textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:textView];
        [textView release];
        
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITextField *textField = [[UITextField alloc] initWithFrame:rect];
        if (!iphone) {
            [textField setBorderStyle:UITextBorderStyleRoundedRect];
        }
        //  Set the keyboard's return key label to 'Done'.
        //
        [textField setReturnKeyType:UIReturnKeyDone];
        textField.delegate = delegate;
        [textField addTarget:delegate action:@selector(changeText:) forControlEvents:UIControlEventEditingChanged];
        
        //  Make the clear button appear automatically.
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        
        textField.tag = tag;
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textField setPlaceholder:field.displayName];
        
        
        //  When I edit numeric fields like telefone numer, the keyboard should switch to numbers automatically
        
        if ([field.type isEqualToString:@"Number"] || [field.type isEqualToString:@"Integer"] || [field.type isEqualToString:@"Currency"]) {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        } else if ([field.type isEqualToString:@"Phone"]) {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        } else if ([field.code rangeOfString:@"WebSite"].length > 0) {
            textField.keyboardType = UIKeyboardTypeURL;
        } else if ([field.code rangeOfString:@"Email"].length > 0) {
            textField.keyboardType = UIKeyboardTypeEmailAddress;
        }
        
        if ([field.type isEqualToString:@"Date/Time"] || [field.type isEqualToString:@"Date"]) {
            textField.text = [UITools formatDateTime:field.type value:value shortStyle:iphone];
        } else {
            textField.text = value;
        }
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:textField];
        [textField release];
    }
    
    if ([sinfo isMandatory:field.code]) {
        UIView *subview = [cell.contentView.subviews objectAtIndex:0];
        if (subview) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(subview.frame.origin.x-5, subview.frame.origin.y, 4, subview.frame.size.height)];
            view.backgroundColor = [UIColor redColor];
            view.layer.cornerRadius = 2;
            view.clipsToBounds = YES;
            [cell.contentView addSubview:view];
            [view release];
        }
    }
}

+ (NSDateFormatter *)getDateFormatter:(NSString *)type {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    if ([type isEqualToString:@"Date"]) {
        [formatter setDateFormat:@"yyyy-MM-dd"];
    } else {
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    return formatter;
}


+ (void)initDatePicker:(UIDatePicker *)datePicker value:(NSString *)value type:(NSString *)type {
    NSDateFormatter *formatter = [UITools getDateFormatter:type];
    
    NSTimeZone *userTZ = nil;
    if ([type isEqualToString:@"Date"]) {
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        userTZ = [NSTimeZone timeZoneWithName:@"GMT"];
    } else {
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        userTZ = [CurrentUserManager getUserTimeZone];
    }
    [datePicker setTimeZone:userTZ];
    // the following code block fixes a bug that creates a difference of -1 day
    // in date picker, when the CRM is on US time, and the iPad on Asia time.
    if (![type isEqualToString:@"Date"]) {
        NSLocale *locale = [NSLocale currentLocale];
        [formatter setLocale:locale];
        datePicker.locale = locale;
        datePicker.calendar = [locale objectForKey:NSLocaleCalendar];
    }
    [datePicker.calendar setTimeZone:userTZ];
    
    NSDate *nsdate;
    if (value == nil || [value isEqualToString:@""]) {
        nsdate = [NSDate dateWithTimeInterval:([[NSTimeZone localTimeZone] secondsFromGMT] - [userTZ secondsFromGMT]) sinceDate:[NSDate date]];
    } else {
        nsdate = [formatter dateFromString:value];
    }
    [datePicker setDate:nsdate animated:NO];
    

}



+ (BOOL)contentTypeIsImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return YES;
        case 0x89:
            return YES;
        case 0x47:
            return YES;
        case 0x49:
            return YES;
        case 0x4D:
            return YES;
    }
    return NO;
}

+ (void)contactPicture:(UITableView *)table item:(Item *)detail button:(UIButton *)chooseImage{
    
    UIView *headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 110)];
    [chooseImage setFrame:CGRectMake(20, 5, 100, 100)];
    chooseImage.center= headView.center;
    chooseImage.layer.cornerRadius = 10;
    chooseImage.layer.borderWidth = 0.5;
    chooseImage.clipsToBounds=YES;
    chooseImage.layer.borderColor = [[UIColor grayColor] CGColor];
    chooseImage.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    chooseImage.imageView.contentMode=UIViewContentModeScaleToFill;
    NSData *dataimg=[PictureManager read:[detail.fields objectForKey:@"gadget_id"]];
    
    UIImage *img;
    if (dataimg!=nil) {
        
        img=[UIImage imageWithData:dataimg];
        CGSize newSize=chooseImage.frame.size;
        UIGraphicsBeginImageContext( newSize );
        [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        chooseImage.tag = 0;
        
    } else {
        img = nil;
        chooseImage.tag=1;
    }
    
    [chooseImage setImage:img forState:UIControlStateNormal];
    [chooseImage setTitle:@"Add Image" forState:UIControlStateNormal];
    [chooseImage setShowsTouchWhenHighlighted:YES];
    [chooseImage setTitleColor:[UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
    [headView addSubview:chooseImage];
    [table  setTableHeaderView:headView];
    
}


+ (UIColor *)readHexColorCode:(NSString *)hexcode
{
    if (hexcode==nil) {
        hexcode=@"194C7F";
    }    
    hexcode=[hexcode stringByReplacingOccurrencesOfString:@"#" withString:@""];
    UIColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    NSScanner* scanner = [NSScanner scannerWithString:hexcode];
    (void) [scanner scanHexInt:&colorCode]; // ignore error
    
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
    
    result = [UIColor colorWithRed:(CGFloat)redByte / 0xff green:(CGFloat)greenByte / 0xff blue:(CGFloat)blueByte / 0xff alpha:1.0];
    
    return result;
}


+ (NSString *)formatPDFDisplayValue:(CRMField *)field value:(Item *)item{
    
    NSString *value = [item.fields objectForKey:field.code];
    NSString *subtype = [Configuration getSubtype:item];
    
    // format the value depending on its type
    if ([field.type isEqualToString:@"Date/Time"] || [field.type isEqualToString:@"Date"]) {
        value = [UITools formatDateTime:field.type value:value shortStyle:NO];
    } else if ([field.type isEqualToString:@"Checkbox"]) {
        if ([value isEqualToString:@"true"]) {
            value = NSLocalizedString(@"YES", nil);
        } else {
            value = NSLocalizedString(@"NO", nil);
        }
        
    } else if ([field.type isEqualToString:@"Picklist"] && ![RelationManager isCalculated:subtype field:field.code] && ![RelationManager isKey:subtype field:field.code]) {
        
        value = [PicklistManager getPicklistDisplay:item.entity field:field.code value:value];
        
    } else if (([field.type isEqualToString:@"Currency"] || [field.type isEqualToString:@"Number"] || [field.type isEqualToString:@"Integer"]) && ![field.code isEqualToString:@"Probability"]){
        
        value = [UITools formatNumber:value];
        // fields such as CustomNumber2X are percentages.
        if ([field.type isEqualToString:@"Number"] && [field.code characterAtIndex:field.code.length - 2] == '2') {
            value = [NSString stringWithFormat:@"%@%%", value];
        }
        if ([field.type isEqualToString:@"Currency"]) {
            value = [UITools formatCurrency:value item:item] ;
        } 
    }
    
    return value == nil||[value isEqualToString:@""]? @" ":value;
}

+ (NSString  *)formatNumber:(NSString *)unformatted {
    if (unformatted == nil || [unformatted isEqualToString:@""]) {
        return @"";
    }
    NSNumberFormatter *format = [[[NSNumberFormatter alloc] init] autorelease];
    [format setNumberStyle:NSNumberFormatterDecimalStyle];
    NSDecimalNumber *numValue = [NSDecimalNumber decimalNumberWithString:unformatted];
    return [format stringFromNumber:numValue];
}

+ (NSString *)formatCurrency:(NSString *)value item:(Item *)item {
    if (value == nil || [value isEqualToString:@""]) {
        return @"";
    }
    NSString *currencyCode = [item.fields objectForKey:@"CurrencyCode"];
    if (currencyCode == nil) {
        // if not found, take the user's currency code
        currencyCode = [[CurrentUserManager getCurrentUserInfo].fields objectForKey:@"CurrencyCode"];
        if (currencyCode == nil || [currencyCode length] == 0) {
            // if still not found, take the company's default currency
            currencyCode = [PropertyManager read:@"DefaultCurrency"];
        }
    }
    if (currencyCode == nil) {
        return value;
    } else if ([currencyCode isEqualToString:@"EUR"]) {
        return [NSString stringWithFormat:@"€ %@", value];
    } else if ([currencyCode isEqualToString:@"USD"]) {
        return [NSString stringWithFormat:@"$ %@", value];
    } else {
        return [NSString stringWithFormat:@"%@ %@", currencyCode, value];
    }
}

// remove calculated fields : they are not editable
+ (NSArray *)filterFields:(NSArray *)fields subtype:(NSString *)subtype {
    NSMutableArray *filteredFields = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject<Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    for (NSString *field in fields) {
        if ([field rangeOfString:@"CreatedBy"].location != 0
            && [field rangeOfString:@"ModifiedBy"].location != 0
            && ![field isEqualToString:@"CreatedDate"] && ![field isEqualToString:@"ModifiedDate"]
            && ![RelationManager isCalculated:subtype field:field]
            && ![RelationManager isKey:subtype field:field]
            && ![sinfo isReadonly:field]) {
            [filteredFields addObject:field];
        }
    }
    return filteredFields;
}

+ (void)initCheckboxes:(Item *)detail sections:(NSArray *)sections {
    // init empty checkboxes to disabled
    NSString *subtype = [Configuration getSubtype:detail];
    for (Section *section in sections) {
        NSArray *filtered = [self filterFields:section.fields subtype:subtype];
        for (NSString *code in filtered) {
            CRMField *field = [FieldsManager read:detail.entity field:code];
            if ([field.type isEqualToString:@"Checkbox"]) {
                NSString *value = [detail.fields objectForKey:code];
                if (value == nil || value.length == 0) {
                    [detail.fields setObject:@"false" forKey:code];
                }
            }
        }
    }
}

+ (CGSize)computeImageSize:(UIImage *)image forSize:(int)maxSize {
    CGSize size = CGSizeMake(maxSize, maxSize);
    if (image.size.height > image.size.width) {
        size.width = image.size.width * maxSize / image.size.height;
    } else {
        size.height = image.size.height * maxSize / image.size.width;
    }
    return size;
}

+ (NSString *)getAttachmentExtension:(SublistItem *)subItem {
    NSString *extension = [[subItem.fields objectForKey:@"FileExtension"] lowercaseString];
    if ([extension isEqualToString:@"url"]) {
        NSString *url = [subItem.fields objectForKey:@"FileNameOrURL"];
        NSRange range = [url rangeOfString:@"." options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            extension = [[url substringFromIndex:range.location + 1] lowercaseString];
        } else {
            extension = @"html";
        }
    }
    return extension;
}


+ (NSString *)getAttachmentIcon:(SublistItem *)subItem {
    NSString *extension = [UITools getAttachmentExtension:subItem];
    if ([extension isEqualToString:@"docx"]) extension = @"doc";
    if ([extension isEqualToString:@"pptx"]) extension = @"ppt";
    NSString *fileName = @"File.png";
    if ([extension isEqualToString:@"doc"] || [extension isEqualToString:@"png"]
        || [extension isEqualToString:@"jpg"] || [extension isEqualToString:@"ppt"]
        || [extension isEqualToString:@"pdf"]) {
        fileName = [NSString stringWithFormat:@"filetype-%@.png", extension];
    }
    return fileName;
}

@end
