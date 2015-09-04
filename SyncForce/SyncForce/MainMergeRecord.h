//
//  MainMergeScreen.h
//  SyncForce
//
//  Created by Gaeasys on 12/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSplitViewController.h"
#import "MergeRecordDetail.h"
#import "SfMergeRecords.h"

@class MergeRecordPopover;


@interface MainMergeRecord : MGSplitViewController {
    MergeRecordPopover* listRecordsMerge;
    MergeRecordDetail *mergeView;
    NSString *entityName;
    
    SfMergeRecords* process;
    NSArray *listrecods;
    NSArray * sfRecords;

}


@property (nonatomic, retain) MergeRecordPopover *listRecordsMerge;
@property (nonatomic, retain) MergeRecordDetail *mergeView;
@property (nonatomic, retain) NSString *entityName;

@property (nonatomic, retain) NSArray *listrecods;
@property (nonatomic, retain) NSArray* sfRecords;


- (id)initWithEntity:(NSString*)entity listlocalrecords:(NSArray*)local listSfRecords:(NSArray*)sf merge:(id)mergeController;


@end
