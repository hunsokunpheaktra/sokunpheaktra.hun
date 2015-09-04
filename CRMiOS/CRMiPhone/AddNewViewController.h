//
//  AddNewViewController.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/13/11.
//  Copyright 2011 Gaeasys. All rights reserved.
//

#import "InfoFactory.h"
#import "ListViewController.h"
#import "UITools.h"
#import "PickListSelectController.h"
#import "EntityManager.h"
#import "ValidationController.h"

@interface AddNewViewController : UITableViewController<UpdateListener,UITextFieldDelegate> {
    NSMutableDictionary *newItem;
    NSArray *listField;
    NSString *entity;

    UIDatePicker *datePicker;
    UITextField *currectTxtField;
    //date format
    NSDateFormatter *dateFormater;
    ListViewController *listView;
}
@property(nonatomic,retain) UITextField *currectTxtField;
@property(nonatomic,retain) ListViewController *listView;
@property(nonatomic,retain)  NSDateFormatter *dateFormater;
@property(nonatomic, retain) UIDatePicker *datePicker;
@property(nonatomic, retain) NSArray *listField;
@property (nonatomic ,retain)  NSString *entity;
@property (nonatomic ,retain)  NSMutableDictionary *newItem;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (void)showDatePicker;
- (void)changeSwitch:(id)sender;
- (void)changeText:(id)sender;
-(id)initWithEntity:(NSString *)newEntity withListView:(ListViewController *)newListView withItem:(NSMutableDictionary *)newItemdic;

@end
