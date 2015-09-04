//
//  EditViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "UITools.h"
#import "EditCell.h"
#import "SelectionPopup.h"
#import "MultiSelectPopup.h"
#import "CreationListener.h"

#import "DatePopup.h"
#import "EntityManager.h"
#import "UpdateListener.h"
#import "ValidationTools.h"
#import "RelatedPopup.h"
#import "WholesalerPopup.h"

#import "LayoutSectionManager.h"
#import "LayoutFieldManager.h"
#import "LayoutPageManager.h"
#import "ChoosePicturePopup.h"
#import "PictureManager.h"


@interface EditViewController : UITableViewController <SelectionListener, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate> {

    NSString *subtype;
    NSMutableArray *sections;
    NSMutableArray *sectionData;
    NSMutableArray *relatedFields;
    Item *workDetail;
    Item *detail;
    NSObject <UpdateListener, CreationListener> *updateListener;
    NSNumber *isCreate;
    UIButton *chooseimage;
    
}

@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) UIButton  *chooseimage;
@property (nonatomic, retain) Item *detail;
@property (nonatomic, retain) Item *workDetail;
@property (nonatomic, retain) NSMutableArray *sections;
@property (nonatomic, retain) NSMutableArray *sectionData;
@property (nonatomic, retain) NSMutableArray *relatedFields;
@property (nonatomic, retain) NSObject <UpdateListener, CreationListener> *updateListener;
@property (nonatomic, retain) NSNumber *isCreate;
 
- (id)initWithDetail:(Item *)newDetail updateListener:(NSObject <UpdateListener, CreationListener> *)newUpdateListener isCreate:(BOOL)newIsCreate action:(NSString *)action;
- (void)cancel;
- (void)deleteConfirm:(id)sender;
- (NSString *)getCodeFromTag:(int)tag;
- (void)choosePic:(id)sender;
- (void)checkboxchange:(id)sender;

@end
