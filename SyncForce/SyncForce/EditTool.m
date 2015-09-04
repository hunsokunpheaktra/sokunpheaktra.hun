//
//  EditTool.m
//  SyncForce
//
//  Created by Gaeasys on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditTool.h"
#import "FieldInfoManager.h"
#import "EntityManager.h"
#import "PicklistForRecordTypeInfoManager.h"
#import "DatetimeHelper.h"
#import "DatePickListRefEditor.h"

@implementation EditTool

@synthesize control, index;



- (id) setupAddEditCell:(UITableViewCell *)cell entityInfo:(NSObject<EntityInfo> *)fieldsInfo valueItem:(Item *)item listFieldInfo:(NSArray*)listFieldInfo fieldName:(NSString*)fieldName rect:(CGRect)rect tag:(int)tag delegate:(id)delegate parentField:(NSString*)parentField parentId:(NSString*)parentId{
    
    int nbItem = [listFieldInfo count];
    index = 0;
    control = [[UIControl alloc] initWithFrame:rect];
    control.tag = 0;
    
    rect = CGRectInset(rect, 7.0, 7.0);
    rect.size.width = rect.size.width/nbItem;
    CGRect frame = rect;
    
    for (Item* tmItem in listFieldInfo) {
        NSString* fieldApi = [tmItem.fields objectForKey:@"value"];
        index = [[tmItem.fields objectForKey:@"columns"] intValue];
        frame.origin.x  = frame.origin.x + frame.size.width * index;
        
        NSString *fieldtype = [[[fieldsInfo getFieldInfoByName:fieldApi] fields] valueForKey:@"type"];
        NSString *value = [item.fields objectForKey:fieldApi];
        
        if ([fieldtype isEqualToString:@"boolean"]) {
           
            frame.size.width = 22.0;
            frame.size.height = 22.0;
            
            UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
            [checkBox setFrame:frame];
            checkBox.tag = 0;
            checkBox.contentMode = UIViewContentModeScaleToFill;
            [checkBox setTitle:fieldApi forState:UIControlStateDisabled];
            
            if ([value isEqualToString:@""] || value == nil) [delegate updateField:@"false" apiFieldName:fieldApi];
            
            if([value isEqualToString:@"true"])
                [checkBox setBackgroundImage: [UIImage imageNamed:@"check_yes"] forState:UIControlStateNormal];
            else
                [checkBox setBackgroundImage:[UIImage imageNamed:@"check_no"] forState:UIControlStateNormal];   
            
            [checkBox addTarget:delegate action:@selector(changeSwitch:) forControlEvents:UIControlEventTouchUpInside];
            [control insertSubview:checkBox atIndex:index];

            
        } else if ([fieldtype isEqualToString:@"id"]
                   || [fieldtype isEqualToString:@"picklist"]
                   || [fieldtype isEqualToString:@"datetime"]
                   || [fieldtype isEqualToString:@"date"] || [fieldtype isEqualToString:@"reference"]) {
            
            
            NSArray* listItems = nil;
            if([fieldtype isEqualToString:@"reference"]) {
                NSArray *arr = [FieldInfoManager referenceToEntitiesByField:[tmItem.fields objectForKey:@"entity"] field:[tmItem.fields objectForKey:@"value"]];
                            
                for (NSString*name in arr) {
                    Item* tmpItem;
                    if ([[DatabaseManager getInstance] checkTable:name]) {
                        if (parentField &&[parentField isEqualToString:fieldApi]) {
                            value = parentId;
                            [delegate updateField:value apiFieldName:fieldApi];
                        }    
                        tmpItem = [EntityManager find:name column:@"Id" value:value];
                        
                        if (tmpItem != nil) {
            
                            NSString* subOrName = @"";
                            if ([tmpItem.entity isEqualToString:@"Case"] ||
                                [tmpItem.entity isEqualToString:@"Task"] ||
                                [tmpItem.entity isEqualToString:@"Event"]
                                ) {
                                subOrName = @"Subject";
                            }
                            else if ([tmpItem.entity isEqualToString:@"Contract"]) subOrName = @"ContractNumber";
                            else subOrName = @"Name";
                            
                            value = [tmpItem.fields objectForKey:subOrName];
                            listItems = [[EntityManager list:name criterias:nil] retain];
                            break;
                        }else listItems = [[EntityManager list:name criterias:nil] retain];
                    }
                }
                
            }else if ([fieldtype isEqualToString:@"picklist"]) {
                
                NSString* recordTypeId = [item.fields objectForKey:@"recordTypeId"];
                listItems = [PicklistForRecordTypeInfoManager getPicklistItems:fieldApi entity:[tmItem.fields objectForKey:@"entity"] recordTypeId:recordTypeId ==nil?@"012000000000000AAA":recordTypeId];
                
                if ([[tmItem.fields valueForKey:fieldApi] length] == 0 || [tmItem.fields valueForKey:fieldApi] == nil) {
                    for (Item* item in listItems) {
                        if ([[item.fields objectForKey:@"defaultValue"] isEqualToString:@"true"]) {
                            value = [item.fields objectForKey:@"value"];
                            break;
                        }
                    }
                }
            }
            
            
            DatePickListRefEditor* chooser = [[DatePickListRefEditor alloc] initWithListItems:listItems fieldApi:fieldApi type:(NSString*)fieldtype selectValue:value frame:frame updateListener:delegate];
            chooser.tag = tag;
            [control insertSubview:chooser.view atIndex:index];
            
        }else if ([fieldtype isEqualToString:@"textarea"]){
            
            NSString *fieldLenght = [[[fieldsInfo getFieldInfoByName:[tmItem.fields objectForKey:@"value"]] fields] valueForKey:@"length"];
            
            frame.size.height = [fieldLenght intValue] > 1000 ? 100 : 60;
            
            UITextView *textView = [[UITextView alloc] initWithFrame:frame];
            
            textView.layer.cornerRadius = 5;
            textView.layer.borderWidth = 1;
            textView.layer.borderColor = [[UIColor grayColor] CGColor];
            textView.clipsToBounds = YES;
            textView.tag = tag;
            [textView.layer setValue:fieldApi forKey:@"ApiFieldName"];
            textView.font = [UIFont systemFontOfSize:16];
            textView.delegate = delegate;
            [textView setAutocorrectionType:UITextAutocorrectionTypeNo];
            [textView setText:value];
            [textView setReturnKeyType:UIReturnKeyDone];
            textView.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
           
            [control insertSubview:textView atIndex:index];
            
            //[cell.contentView addSubview:textView];
            //[textView release];
            
        }else {
            
            UITextField *textField = [[UITextField alloc] initWithFrame:frame];
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            //textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            //  Set the keyboard's return key label to 'Next'.
            [textField setReturnKeyType:UIReturnKeyDone];
            textField.delegate = delegate;
            [textField.layer setValue:fieldApi forKey:@"ApiFieldName"];
            
            //  Make the clear button appear automatically.
            [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
            textField.tag = tag;
            [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            // [textField setPlaceholder:fieldName];
            
            //  When I edit numeric fields like telefone numer, the keyboard should switch to numbers automatically
            if ([fieldtype isEqualToString:@"Number"] || [fieldtype isEqualToString:@"Integer"] || [fieldtype isEqualToString:@"Currency"]) {
                textField.keyboardType = UIKeyboardTypeNumberPad;
            } else if ([fieldtype isEqualToString:@"Phone"]) {
                textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            }
            
            textField.text = value;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            
            [control insertSubview:textField atIndex:index];
            
            // [cell.contentView addSubview:textField];
            // [textField release];
            
        }
        
        if ([[tmItem.fields objectForKey:@"required"] isEqualToString:@"true"]) {
            UIButton* bntMandatory = [UIButton buttonWithType:UIButtonTypeCustom];
            bntMandatory.tag = 1;
            [bntMandatory setBackgroundColor:[UIColor redColor]];
            frame.size.height = frame.size.height - 5.0;
            frame.size.width = 4.0;
            [bntMandatory setFrame:frame];
            control.tag = control.tag+1;
            [control insertSubview:bntMandatory atIndex:0];
        }
        
    }
    
    return self;
}   


@end
