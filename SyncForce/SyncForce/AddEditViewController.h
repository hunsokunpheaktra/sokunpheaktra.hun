//
//  AddEditViewController.h
//  SyncForce
//
//  Created by Gaeasys on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityInfo.h"
#import "Item.h"
#import "UpdateListener.h"

#define SETTING_HEADER_FONT_SIZE 16.0
#define SETTING_HEADER_HEIGHT 48.0
#define SETTING_HEADER_ROW_WIDTH 400.0


@interface AddEditViewController : UITableViewController<UITextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate> {
    
    Item *detail;
    NSMutableDictionary* sectionNameRowSection;
    NSMutableArray *sectionNameOrder;
    NSMutableDictionary *layoutItems;
    NSArray *sections;
    NSString *mode;
    NSString *objectId;
    NSMutableDictionary *mapSections;
    NSString* fieldParent;
    NSString* recordTypeId;
    NSObject<EntityInfo> *entityInfo;
    NSObject<UpdateListener> *updateInfo;

}

@property (nonatomic, retain) NSObject<UpdateListener> *updateInfo;

- (id)init:(Item*)item mode:(NSString*)pMode objectId:(NSString*)pobjectId relationField:(NSString*)relationField;
- (void) updateField:(NSString*) newValue apiFieldName:(NSString*)apiName;



@end
