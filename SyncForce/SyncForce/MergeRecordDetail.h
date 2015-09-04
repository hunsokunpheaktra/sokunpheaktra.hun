//
//  ScreenMergeRecords.h
//  SyncForce
//
//  Created by Gaeasys on 12/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "MGSplitViewController.h"


@class MainMergeRecord ;
@class MergeRecordPopover;

@interface MergeRecordDetail : UIViewController<UIPopoverControllerDelegate,UITableViewDataSource,UITableViewDelegate,MGSplitViewControllerDelegate> {
    
    Item *localItem;   
    Item *sfItem;
    NSArray *sections;
    NSMutableDictionary* layoutItems;
    NSMutableDictionary* mapSections;
    UITableView * dataTable;
    NSMutableDictionary* radios;
    NSMutableDictionary* sectionRadio;
    NSMutableArray *headers;
    NSObject<EntityInfo> *entityInfo;
    UIPopoverController *popoverController;
    NSString *entityName;
    MergeRecordPopover *listRecordsMerge;
    UIToolbar *myToolbar;
    NSMutableArray* fieldkeys;
    Item* tmpSfitem;
    Item* tmpLocaItem ;
    
}


@property(nonatomic, retain) Item *localItem;   
@property(nonatomic, retain) Item *sfItem;
@property(nonatomic, retain) UITableView * dataTable;
@property(nonatomic, retain) NSMutableDictionary *radios;
@property(nonatomic, retain) NSMutableDictionary *sectionRadio;
@property(nonatomic, retain) NSMutableArray* headers;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) MergeRecordPopover *listRecordsMerge;
@property (nonatomic, retain) UIToolbar *myToolbar;

@property (nonatomic, retain) NSMutableArray* fieldkeys;

-(id) initWithEntity:(NSString*)entity;
-(void) initView ;

@end
