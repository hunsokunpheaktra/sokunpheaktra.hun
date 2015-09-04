
//
//  EditViewController.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Item.h"
#import "EntityInfo.h"
#import "ListPopupViewController.h"
#import "UpdateListener.h"
#import "ScreenRelatedList.h"
#import "EntityListController.h"
#import "MapviewController.h"
#import "KeyInformationView.h"
#import "SidBarDetailView.h"

#define SETTING_HEADER_FONT_SIZE 16.0
#define SETTING_HEADER_HEIGHT 48.0
#define SETTING_HEADER_ROW_WIDTH 400.0

@class JTRevealSidebarView;

@class ScreenRelatedList;

@interface ObjectDetailViewController : UIViewController <UIPopoverControllerDelegate,UpdateListener, UITableViewDataSource, UITableViewDelegate>{
    
    JTRevealSidebarView *_revealView;

    Item *detail;
    
    NSObject<EntityInfo> *entityInfo;
    NSMutableDictionary *layoutItems;
    
    NSArray *sections;
    NSMutableArray *tmpSections;
    NSString *mode;
    NSString *objectId;
    NSArray *fieldinfos;
    NSMutableDictionary *mapSections;
    ScreenRelatedList *screenRelatedList;
    NSArray *relatedLists;
    UISegmentedControl *segment;
    NSMutableArray *relatedHeader;
    NSInteger segmentSelectIndex;
    
    NSMutableDictionary* sectionNameRowSection;
    
    UIToolbar* toolbar;
    NSMutableArray* sectionNameOrder;
    MapviewController *mapcon;
    EditViewController *editView;
    UITableView* tableDetail;
    KeyInformationView* keyInfo;
    
    NSMutableDictionary  *mapRefName;
    NSMutableDictionary  *tableNameExist;
    NSMutableDictionary  *mapRecordTypeLayout;
    
    NSArray *listField;
    
    BOOL isFirstLoadRelatedList;
    BOOL isRevealSideBar;
    
    int start_number;
    int end_number;
    int selectedRowNumber;
    
    NSString* parentType;
    NSString* parentId;
    NSString* childType;
    
    id parentClass;
    
    UISegmentedControl* actionSegmt;
    
}

@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) Item *detail;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSMutableDictionary *layoutItems;
@property (nonatomic, retain) NSString *mode;
@property (nonatomic, retain) NSMutableDictionary *mapSections;
@property (nonatomic, retain) UITableView* tableDetail;
@property (nonatomic, retain) KeyInformationView* keyInfo;

@property int start_number;
@property int end_number;
@property int selectedRowNumber;
@property (nonatomic, retain) id parentClass;

@property (nonatomic, retain) NSString* parentType;
@property (nonatomic, retain) NSString* parentId;
@property (nonatomic, retain) NSString* childType;

-(void)dataTableReloadView;
-(void) chooseView :(float)width;

-(NSMutableDictionary*) getValueBy:(NSString*)fieldName recordId:(NSString*)recordId;
- (id)init:(Item*)item mode:(NSString*)pMode objectId:(NSString*)pobjectId;
- (void)editClick:(id)sender;
- (void)openParent:(id)sender;
- (void)reloadRelatedList;
- (void) mapData:(NSString*)rtId;

@end

