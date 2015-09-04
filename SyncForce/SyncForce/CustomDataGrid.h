//
//  CustomDataGrid.h
//  Datagrid
//
//  Created by Gaeasys on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDataGridRow.h"
#import "DatagridListener.h"
#import "DataModel.h"
#import "Item.h"
#import "NavigateListener.h"
#import "ObjectDetailViewController.h"
#import "UpdateListener.h"
#import "RecordTypeChooserViewController.h"


#define TABLE_ROW_NUMBER  10

@class ObjectDetailViewController;

@interface CustomDataGrid : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,NavigateListener,UpdateListener> {
    
    NSObject <DatagridListener> *listener;
    NSObject<DataModel>         *dataModel;
    
    
    UITableView                 *dataTable;
    UISearchBar                 *searchBar;
    
    UIToolbar                   *toolbarCancelSave;
    UIToolbar                   *toolbarAddEdit;
    UIToolbar                   *toolbarPaging;
    
    UIBarButtonItem             *bntPrev;
    UIBarButtonItem             *bntNext;
    UIBarButtonItem             *record;

    NSMutableDictionary         *dataFirstLoad;
    NSMutableArray              *datas;
    NSString                    *column_Sorted_Name;
    
    BOOL                        isGridEdit;
    BOOL                        isPortrait;
    BOOL                        isFollowDataModelRowOrder;

    int                         sort_order;
    int                         default_row_number;
    int                         number_of_row;
    int                         end_index;
    int                         start_index;
    id                          deletedRow;
    
    RecordTypeChooserViewController *popupRecordType;
    ObjectDetailViewController      *parentController;
    ObjectDetailViewController      *detailView;
    
    NSString                    *recordTypeId;
    NSString                    *parentType;
    NSString                    *childType;
    NSString                    *parentId;

}

@property (nonatomic,retain) ObjectDetailViewController  *parentController;
@property (nonatomic,retain) NSObject <DatagridListener> *listener;
@property (nonatomic,retain) NSObject<DataModel>         *dataModel;

@property (nonatomic,retain) UITableView *dataTable;
@property (nonatomic,retain) UISearchBar *searchBar;
@property (nonatomic,retain) UIToolbar   *toolbarAddEdit;
@property (nonatomic,retain) UIToolbar   *toolbarPaging;

@property (nonatomic,retain) NSString *parentType;
@property (nonatomic,retain) NSString *childType;
@property (nonatomic,retain) NSString *parentId;


- (void)initView;
- (void)chooseView;
- (void) datetimeAndReferenceChanged:(NSArray*)indexRowCol value:(NSString*)newValue;
- (id)initWithPopulate:(NSObject<DataModel> *)adataModel listener:(NSObject<DatagridListener> *)alistener rowNumber:(int)nbRow;


@end
