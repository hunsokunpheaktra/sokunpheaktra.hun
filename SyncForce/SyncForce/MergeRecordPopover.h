//
//  ListRecordsMerge.h
//  SyncForce
//
//  Created by Gaeasys on 12/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMergeRecord.h"
#import "SfMergeRecords.h"

@class SynchronizeViewController;
@class MergeRecordDetail;

@interface MergeRecordPopover : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    UITableView *listView;
    MainMergeRecord *mainmediaviewer;
    NSArray *listrecods;
    NSArray * sfRecords;
    SfMergeRecords* recordsSf;
    NSIndexPath* indexSelected;
    NSMutableArray* sortListRecords;
    NSMutableArray* sectionTitle;
    NSMutableDictionary* mapIndexMergeSection;
    NSMutableDictionary* mapIndexMergeField;
    NSMutableDictionary* mapMergeItem;
}

@property (nonatomic, retain) IBOutlet MergeRecordDetail *mergeScreen;
@property (nonatomic, retain) UITableView *listView;
@property (nonatomic, retain) MainMergeRecord *mainmediaviewer;
@property (nonatomic, retain) NSArray *listrecods;
@property (nonatomic, retain) NSArray* sfRecords;
@property (nonatomic, retain) SfMergeRecords* recordsSf;
@property (nonatomic, retain) NSIndexPath* indexSelected;
@property (nonatomic, retain) NSMutableArray* sortListRecords;
@property (nonatomic, retain) NSMutableArray* sectionTitle;

- (id)initWithRootPath:(NSString *)entity mainmediaviewer:(MainMergeRecord *)pmainmediaviewer localRecord:(NSArray*)local sfRecords:(NSArray*)sf;

- (void) mergeClick :(NSMutableDictionary*) sectionsRadio radios:(NSMutableDictionary*)radios itemMerge:(Item*)item ;
- (void) afterSaveRecordsMerged;

@end
