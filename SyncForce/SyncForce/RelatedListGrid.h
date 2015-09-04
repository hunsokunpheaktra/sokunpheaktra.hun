//
//  RelatedListGrid.h
//  SyncForce
//
//  Created by Gaeasys on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDataGridRow.h"
#import "CustomDataGridHeader.h"
#import "CustomDataGridPaging.h"
#import "CustomDataGridNewItem.h"
#import "DatagridListener.h"
#import "DataModel.h"
#import "Item.h"
#import "NavigateListener.h"


#define ROW_NUMBER  5

@interface RelatedListGrid : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,NavigateListener> {
    
    NSObject <DatagridListener> *listener;
    NSObject<DataModel>         *dataModel;
    UITableView                 *dataTable;
    CustomDataGridHeader        *header;
    CustomDataGridPaging        *paging;
    UIView                      *tFooter;
    UIView                      *tHeader;
    UISearchBar                 *searchBar;
    UIToolbar                   *buttonCancelSave;
    UIToolbar                   *buttonAddEdit;
    
    NSArray                     *columnNames;
    NSMutableArray              *datas;
    NSString                    *colSort;
    BOOL                        isGridEdit;
    BOOL                        isMassAdd;
    BOOL                        isNotAdd;
    BOOL                        isRequireAction;
    
    NSMutableDictionary         *dataFirstLoad;
    NSArray                     *listSize;
    
}

@property (nonatomic,retain) NSObject <DatagridListener> *listener;
@property (nonatomic,retain) NSObject<DataModel> *dataModel;
@property (nonatomic,retain) IBOutlet UITableView *dataTable;
@property (nonatomic,retain) CustomDataGridHeader *header;
@property (nonatomic,retain) CustomDataGridPaging *paging;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) UIView* tFooter;
@property (nonatomic,retain) UIView* tHeader;
@property (nonatomic,retain) UIToolbar* buttonCancelSave;
@property (nonatomic,retain) UIToolbar* buttonAddEdit;
@property (nonatomic,retain) NSMutableDictionary *dataFirstLoad;

@property (nonatomic,retain) NSArray* columnNames;
@property (nonatomic,retain) NSMutableArray* datas;
@property (nonatomic,retain) NSString *colSort;
@property BOOL isGridEdit;
@property BOOL isMassAdd;
@property BOOL isNotAdd;
@property BOOL isRequireAction;
@property (nonatomic,retain) NSArray *listSize;


@property int sortChange;
@property int j;
@property int dataView;
@property int cnt1;
@property int cnt2;

-(void) testAnimated :(id)sender;
-(id)initWithPopulate:(NSObject<DataModel> *) adataModel listener:(NSObject<DatagridListener> *) alistener requireAction:(BOOL)requireAction;


@end
