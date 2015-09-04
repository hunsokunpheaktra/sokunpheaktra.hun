//
//  PicklistPopupShowView.h
//  Thing
//
//  Created by Hun Sokunpheaktra on 9/25/12.
//
//

#import <UIKit/UIKit.h>
#import "UpdateListener.h"

@interface PicklistPopupShowView : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    UIPopoverController *popover;
    UITableView *tableView;
    UIPickerView *picker;
    UIDatePicker *datePicker;
    NSArray *listItems;
    BOOL isiPhone;
    UIView *parentView;
    NSObject<UpdateListener> *updateListener;
    NSString *fieldName;
    NSString *selectedValue;
    
    
    
    NSString *fieldType;
    
}

@property(nonatomic,retain)NSString *fieldName;
@property(nonatomic,retain)NSArray *listItems;
@property(nonatomic,retain)NSObject<UpdateListener> *updateListener;

-(id)initWithListDatas:(NSArray*)listDatas frame:(CGRect)frame mainView:(UIView*)mainView selectedVal:(NSString*)val type:(NSString*)type;

-(void)done;
-(void)cancel;
-(void)clear;
-(void)show:(UIView*)mainView;
-(void)hide;

@end
