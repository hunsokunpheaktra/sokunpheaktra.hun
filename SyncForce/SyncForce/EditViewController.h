//
//  EditViewController.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "EntityInfo.h"
#import "ListPopupViewController.h"
#import "UpdateListener.h"

#define SETTING_HEADER_FONT_SIZE 16.0
#define SETTING_HEADER_HEIGHT 48.0
#define SETTING_HEADER_ROW_WIDTH 400.0

@interface EditViewController : UITableViewController <UITextFieldDelegate,UIAlertViewDelegate,UIScrollViewDelegate>{
    Item *detail;
    NSObject<EntityInfo> *entityInfo;
    NSObject<UpdateListener> *updateInfo;
    NSMutableDictionary *layoutItems;
     
    //UITableView *editView;
    NSArray *sections;
    NSString *mode;
    NSString *objectId;
    NSMutableDictionary *tagMapper;
    NSArray *fieldinfos;
    NSMutableDictionary *mapData;
    NSMutableArray *allTextField;
    NSMutableDictionary *mapSections;
    NSMutableDictionary *madatoryFields;
    NSString* fieldParent;
    UITextField *tempTextField;
    NSString* recordTypeId;

}

@property (nonatomic, retain) NSObject<UpdateListener> *updateInfo;
@property (nonatomic, retain) NSMutableArray *allTextField;
@property (nonatomic, retain) NSMutableDictionary *mapData;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) Item *detail;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSMutableDictionary *layoutItems;
@property (nonatomic, retain) NSString *mode;
@property (nonatomic, retain) NSMutableDictionary *tagMapper;
@property (nonatomic, retain) NSMutableDictionary *mapSections;

- (id)init:(Item*)item mode:(NSString*)pMode objectId:(NSString*)pobjectId relationField:(NSString*)relationField;
- (void)saveClick:(id)sender;
- (void)updateCell:(NSIndexPath*)path newValue:(NSString*)value;
- (void)changeSwitch:(id)sender;
- (NSString *)getFieldName:(UIView*)view;
- (void)done:(NSString*)newDate editPath:(NSIndexPath*)path;
- (void)clear:(NSIndexPath*)path;

@end
