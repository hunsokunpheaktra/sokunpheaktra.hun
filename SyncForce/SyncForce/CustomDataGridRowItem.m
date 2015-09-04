//
//  CustomDataGridRowItem.m
//  Datagrid
//
//  Created by Gaeasys on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomDataGridRowItem.h"
#import "NumberHelper.h"
#import "DataType.h"
#import "DatetimeHelper.h"
#import "AppDelegate.h"
#import "CustomDataGrid.h"


@implementation CustomDataGridRowItem

@synthesize baseSize;
@synthesize control;
@synthesize controlLabel;
@synthesize columnType;
@synthesize isView;
@synthesize updateable;



//view grid
#pragma mark - View lifecycle

-(id)initWithRowItemType:(BOOL)itemTypeButton columnType:(int)colType entityName:(NSString*)entityName fieldName:(NSString*)fieldName baseSize:(CGSize)size controlLabel:(NSString *)label listener:(NSObject<DatagridListener> *)aListener gridItem:(NSString *)aItem buttonTarget:(id)target tag:(int)tag navigateListener:(NSObject<NavigateListener>*)navigateListener isView:(BOOL)view
{
    self = [super init]; 
    self.controlLabel = label;
    self.columnType = colType;
    navListener = navigateListener;
    listener = aListener;
    baseSize = size;
    itemId = aItem;
    isView = view;
    
    if (!itemTypeButton) {
        
        if (TYPE_STRING == colType || TYPE_PICKLIST == colType) {
            
            NSString* name = @"";
            if([entityName isEqualToString:@"Case"] || [entityName isEqualToString:@"Task"] || [entityName isEqualToString:@"Event"]) name = @"Subject";
            else if ([entityName isEqualToString:@"Contract"]) name = @"ContractNumber";
            else name = @"Name";
            
            if ([fieldName isEqualToString:name]) {
                UIButton* bntName = [UIButton buttonWithType:UIButtonTypeCustom];
                [bntName setFrame:CGRectMake(5, 5, size.width, size.height)];
                [bntName setTitle:controlLabel forState:UIControlStateNormal];
                [bntName.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
                [bntName.titleLabel setNumberOfLines:0];
                [bntName.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [bntName setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                 bntName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                bntName.tag = tag;
                [bntName setShowsTouchWhenHighlighted:YES];
                [bntName addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
                
                control = bntName;

            }
            
            else {
                UILabel *tString = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, size.width, size.height)];
                tString.font = [UIFont systemFontOfSize:12];
                [tString setBackgroundColor:[UIColor clearColor]];
                tString.text = controlLabel;
                [tString setLineBreakMode:UILineBreakModeWordWrap];
                [tString setNumberOfLines:0];
                [tString setTextAlignment:UITextAlignmentLeft];
                
                control = (UIControl*)tString;
            }    
            
        } else if (TYPE_CURRENCY == colType) {
            
            UILabel *tCurrency = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, size.width, size.height)];
            tCurrency.font = [UIFont systemFontOfSize:12];
            [tCurrency setBackgroundColor:[UIColor clearColor]];
            tCurrency.text = [NumberHelper formatCurrencyValue:[controlLabel doubleValue]];
            [tCurrency setNumberOfLines:0];
            [tCurrency setLineBreakMode:UILineBreakModeWordWrap];
            [tCurrency setTextAlignment:UITextAlignmentRight];
            
            control = (UIControl*)tCurrency;

            
        } else if (TYPE_INT == colType || TYPE_DOUBLE == colType) {
            
            UILabel *tNumber = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, size.width, size.height)];
            tNumber.font = [UIFont systemFontOfSize:12];
            [tNumber setBackgroundColor:[UIColor clearColor]];
            tNumber.text = [NumberHelper formatNumberDisplay:[controlLabel doubleValue]];
            [tNumber setLineBreakMode:UILineBreakModeWordWrap];
            [tNumber setNumberOfLines:0];
            [tNumber setTextAlignment:UITextAlignmentRight];
            
            control = (UIControl*)tNumber;

            
        } else if (TYPE_PERCENT == colType) {
            
            UILabel *tPercent = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, size.width, size.height)];
            tPercent.font = [UIFont systemFontOfSize:12];
            [tPercent setBackgroundColor:[UIColor clearColor]];
            tPercent.text = [NumberHelper formatPercentValue:[controlLabel doubleValue]];
            [tPercent setNumberOfLines:0];
            [tPercent setLineBreakMode:UILineBreakModeWordWrap];
            [tPercent setTextAlignment:UITextAlignmentRight];
           
            control = (UIControl*)tPercent;

            
        } else if (TYPE_BOOLEAN == colType) {
            
            UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
            [checkBox setFrame:CGRectMake(5, 5, 50, 24)];
            [checkBox setImage:[UIImage imageNamed:@"checkBoxChecked"] forState:UIControlStateNormal];
            
            if([controlLabel isEqualToString:@""]||[controlLabel isEqualToString:@"0"]||[controlLabel isEqualToString:@"false"]||[controlLabel isEqualToString:@"NO"] || controlLabel == NULL || [controlLabel length] == 0){
                
                [checkBox setImage:[UIImage imageNamed:@"checkBoxUnChecked"] forState:UIControlStateNormal];   
            }
            
            control = checkBox;

            
        } else if (TYPE_DATETIME == colType || TYPE_DATE == colType) {
            
            UILabel *datetime = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, size.width, size.height)];
            datetime.font = [UIFont systemFontOfSize:12];
            [datetime setBackgroundColor:[UIColor clearColor]];
            datetime.text = [DatetimeHelper display:controlLabel];
            
            [datetime setTextAlignment:UITextAlignmentLeft];
            [datetime setLineBreakMode:UILineBreakModeWordWrap];
            [datetime setNumberOfLines:0];
            
            control = (UIControl*)datetime;

            
        } else if (TYPE_REFERENCE == colType) {
            
            UILabel *tString = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, size.width, size.height)];
            tString.font = [UIFont systemFontOfSize:12];
            [tString setBackgroundColor:[UIColor clearColor]];
            tString.text = [[[listener getValueBy:fieldName recordId:controlLabel] retain] objectForKey:@"Result"];
            [tString setLineBreakMode:UILineBreakModeWordWrap];
            [tString setNumberOfLines:0];
            [tString setTextAlignment:UITextAlignmentLeft];
            
            control = (UIControl*)tString;

            
        }
        
    }else{ 
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom]; 
      
        [button setFrame:CGRectMake(0, 10, size.width, size.height)];
            
        UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDelete.tag = tag;
        [btnDelete setTitle:controlLabel forState:UIControlStateDisabled];
        [btnDelete setFrame:CGRectMake(-10, 10, ((150 - 30 )/2), size.height/2)];
        [btnDelete setImage:[UIImage imageNamed:@"delete_record.png"] forState:UIControlStateNormal];
        [btnDelete addTarget:target action:@selector(deleteRecord:) forControlEvents:UIControlEventTouchUpInside];
           
        [button addSubview:btnDelete];
        control = button;

    }
    return self;
}



// add + edit grid

-(id) initWithColumnType:(int)colType entityName:(NSString*)entityName fieldName:(NSString*)fieldName recordTypeId:(NSString*)recordType rowIndex:(int)rowIndex columnIndex:(int)columnIndex baseSize:(CGSize)size controlLabel:(NSString *)label listener:(NSObject<DatagridListener> *)alistener buttonTarget:(id)target 

{
    self = [super init]; 
    self.controlLabel = label;
    self.columnType = colType;
    listener = alistener;
    baseSize = size;
    aTarget = target;
    updateable = [((CustomDataGrid*)aTarget).dataModel isEditable:columnIndex];
    isView = NO;
    

    NSArray *arrayIndex = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%d", rowIndex],
                           [NSString stringWithFormat:@"%d", columnIndex], nil];

        if (TYPE_STRING == colType) {
           
            if(updateable){
                UITextField *tString = [[UITextField alloc] initWithFrame:CGRectMake(5, 15, size.width, size.height)];
                tString.font = [UIFont systemFontOfSize:12];
                [tString setBackgroundColor:[UIColor whiteColor]];
            
                tString.borderStyle = UITextBorderStyleRoundedRect;
                tString.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                [tString setTextAlignment:UITextAlignmentLeft];
                tString.text = controlLabel;
                [[tString layer] setValue:arrayIndex forKey:@"index"]; 
                tString.delegate =self;
                
                control = tString;

            }else {
               
                UILabel *tString = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, size.width, size.height)];
                tString.font = [UIFont systemFontOfSize:12];
                [tString setBackgroundColor:[UIColor clearColor]];
                tString.text = controlLabel;
                [tString setLineBreakMode:UILineBreakModeWordWrap];
                [tString setNumberOfLines:0];
                [tString setTextAlignment:UITextAlignmentLeft];
                
                control = (UIControl*)tString;

            }   
            
        } else if (TYPE_CURRENCY == colType) {
            if(updateable){
                UITextField *tCurrency = [[UITextField alloc] initWithFrame:CGRectMake(5, 15, size.width, size.height)];
                tCurrency.font = [UIFont systemFontOfSize:12];
                [tCurrency setBackgroundColor:[UIColor whiteColor]];
                tCurrency.text = controlLabel ;//[NumberHelper formatCurrencyValue:[controlLabel doubleValue]];
                tCurrency.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                [tCurrency setTextAlignment:UITextAlignmentLeft];
                tCurrency.borderStyle = UITextBorderStyleRoundedRect;
                [[tCurrency layer] setValue:arrayIndex forKey:@"index"];
                tCurrency.delegate = self;
                
                control = tCurrency;

            }else {
            
                UILabel *tCurrency = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, size.width, size.height)];
                tCurrency.font = [UIFont systemFontOfSize:12];
                [tCurrency setBackgroundColor:[UIColor clearColor]];
                tCurrency.text = [NumberHelper formatCurrencyValue:[controlLabel doubleValue]];
                [tCurrency setNumberOfLines:0];
                [tCurrency setLineBreakMode:UILineBreakModeWordWrap];
                [tCurrency setTextAlignment:UITextAlignmentLeft];
                
                control = (UIControl*)tCurrency;

            
            }
        } else if (TYPE_INT == colType || TYPE_DOUBLE == colType) {
            if(updateable){
                UITextField *tNumber = [[UITextField alloc] initWithFrame:CGRectMake(5, 15, size.width, size.height)];
                tNumber.font = [UIFont systemFontOfSize:12];
                [tNumber setBackgroundColor:[UIColor whiteColor]];
                tNumber.text = controlLabel ;//[NumberHelper formatNumberDisplay:[controlLabel doubleValue]];
                [tNumber setTextAlignment:UITextAlignmentLeft];
                tNumber.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                tNumber.borderStyle = UITextBorderStyleRoundedRect;
                [[tNumber layer] setValue:arrayIndex forKey:@"index"];
                tNumber.delegate = self;
                
                control = tNumber;

            }else {
                
                UILabel *tNumber = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, size.width, size.height)];
                tNumber.font = [UIFont systemFontOfSize:12];
                [tNumber setBackgroundColor:[UIColor clearColor]];
                tNumber.text = [NumberHelper formatNumberDisplay:[controlLabel doubleValue]];
                [tNumber setLineBreakMode:UILineBreakModeWordWrap];
                [tNumber setNumberOfLines:0];
                [tNumber setTextAlignment:UITextAlignmentLeft];
                
                control = (UIControl*)tNumber;

            }
            
        } else if (TYPE_PERCENT == colType) {
            if(updateable){
                UITextField *tPercent = [[UITextField alloc] initWithFrame:CGRectMake(5, 15, size.width, size.height)];
                tPercent.font = [UIFont systemFontOfSize:12];
                [tPercent setBackgroundColor:[UIColor whiteColor]];
                tPercent.text = controlLabel; //[NumberHelper formatPercentValue:[controlLabel doubleValue]];
                [tPercent setTextAlignment:UITextAlignmentLeft];
                tPercent.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                tPercent.borderStyle = UITextBorderStyleRoundedRect;            
                [[tPercent layer] setValue:arrayIndex forKey:@"index"];
                tPercent.delegate = self;
                
                control = tPercent;

                
            }else {
               
                UILabel *tPercent = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, size.width, size.height)];
                tPercent.font = [UIFont systemFontOfSize:12];
                [tPercent setBackgroundColor:[UIColor clearColor]];
                tPercent.text = [NumberHelper formatPercentValue:[controlLabel doubleValue]];
                [tPercent setNumberOfLines:0];
                [tPercent setLineBreakMode:UILineBreakModeWordWrap];
                [tPercent setTextAlignment:UITextAlignmentLeft];
               
                control = (UIControl*)tPercent;


            }     
            
        } else if (TYPE_BOOLEAN == colType) {
            
                UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
                [checkBox setFrame:CGRectMake(5, 5, 50, 24)];
                [checkBox setImage:[UIImage imageNamed:@"checkBoxChecked"] forState:UIControlStateNormal];
                [[checkBox layer] setValue:arrayIndex forKey:@"index"];
                if([controlLabel isEqualToString:@""]||[controlLabel isEqualToString:@"0"]||[controlLabel isEqualToString:@"false"]||[controlLabel isEqualToString:@"NO"]){
                
                    [checkBox setImage:[UIImage imageNamed:@"checkBoxUnChecked"] forState:UIControlStateNormal];   
                }
            
                if(updateable)
                    [checkBox addTarget:target action:@selector(checkBoxClicked:) forControlEvents:UIControlEventTouchUpInside];
               
            control = checkBox; 

            
        } else if (TYPE_DATETIME == colType || TYPE_DATE == colType) {
            if(updateable){
                baseSize.height = 64;
                DateTimeAndReferenceChooser *dateTime = [[DateTimeAndReferenceChooser alloc] initWithHeader: TYPE_DATETIME == colType ?@"dateTime" : @"date" indexRowCol:arrayIndex selectValue:controlLabel arrItems:nil frame:CGRectMake(0, 5, size.width, baseSize.height) updateListener:target];
    
                control = (UIControl*)dateTime.view;
            }else {
               
                UILabel *datetime = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, size.width, size.height)];
                datetime.font = [UIFont systemFontOfSize:12];
                [datetime setBackgroundColor:[UIColor clearColor]];
                datetime.text = [DatetimeHelper display:controlLabel];
                
                [datetime setTextAlignment:UITextAlignmentLeft];
                [datetime setLineBreakMode:UILineBreakModeWordWrap];
                [datetime setNumberOfLines:0];

                control = (UIControl*)datetime;

            
            }    
            
        } else if (TYPE_REFERENCE == colType) {

            NSMutableDictionary* tmp = [[listener getValueBy:fieldName recordId:controlLabel] retain];

            BOOL isFound = [[tmp objectForKey:@"Found"] isEqualToString:@"YES"]?YES:NO;
            NSString* value = [tmp objectForKey:@"Result"];
            NSString* entity  = [tmp objectForKey:@"RefName"];
          
            if (isFound && updateable) {
                        
                    NSArray* tmpList = [listener getListReferenceBy:entity];
                    baseSize.height = 64;
            
                    DateTimeAndReferenceChooser *dateTime = [[DateTimeAndReferenceChooser alloc] initWithHeader:@"reference" indexRowCol:arrayIndex selectValue:value arrItems:tmpList frame:CGRectMake(0, 5, size.width, baseSize.height) updateListener:target];
            
                    control = (UIControl*)dateTime.view;
                
            } else {
                    updateable = NO; 
                    UILabel *tString = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, size.width, size.height)];
                    tString.font = [UIFont systemFontOfSize:12];
                    [tString setBackgroundColor:[UIColor clearColor]];
                    tString.text = value;
                    [tString setLineBreakMode:UILineBreakModeWordWrap];
                    [tString setNumberOfLines:0];
                    [tString setTextAlignment:UITextAlignmentLeft];

                    control = (UIControl*)tString;
            }  
            
      
            
        } else if (TYPE_PICKLIST == colType) {
            
            if(updateable){
                baseSize.height = 64;
                NSArray* listItems = [listener getPickListBy:fieldName recordTypeId:recordType];
                
                DateTimeAndReferenceChooser *dateTime = [[DateTimeAndReferenceChooser alloc] initWithHeader:@"picklist" indexRowCol:arrayIndex selectValue:controlLabel arrItems:listItems frame:CGRectMake(0, 5, size.width, baseSize.height) updateListener:target];
                
                control = (UIControl*)dateTime.view;

            }else {
               
                UILabel *pickList = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, size.width, size.height)];
                pickList.font = [UIFont systemFontOfSize:12];
                [pickList setBackgroundColor:[UIColor clearColor]];
                pickList.text = controlLabel;
                
                [pickList setTextAlignment:UITextAlignmentLeft];
                [pickList setLineBreakMode:UILineBreakModeWordWrap];
                [pickList setNumberOfLines:0];
                
                control = (UIControl*)pickList;
                
            }    

        }
 
    return self;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}


-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL isNumeric = YES;
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(columnType == TYPE_DOUBLE || columnType == TYPE_CURRENCY || columnType == TYPE_INT || columnType == TYPE_PERCENT){
        for(int i=0;i<newString.length;i++){
            NSString *str = [NSString stringWithFormat:@"%C",[newString characterAtIndex:i]];
            if([str isEqualToString:@"."]) continue;
            if(!isnumber([newString characterAtIndex:i])){
                isNumeric = NO;
                break;
            }
        }
    }
    
    if(!isNumeric){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error:Invalid Data" message:@"Invalid number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return NO;
        
    }else {
            
        textField.text = newString;
        [aTarget performSelector:@selector(editColumn:) withObject:textField];
        return NO;
    }

    return YES;
}   



- (void)actionClick:(id)sender {
        
    UIButton *button = (UIButton*)sender;
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    UITabBarController *tabController = (UITabBarController*)delegate.window.rootViewController;
    UINavigationController *nav = (UINavigationController*)tabController.selectedViewController;
    [navListener navigate:button.tag parentController:nav.topViewController accountId:itemId];
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc
{
    [super dealloc];
}

@end
