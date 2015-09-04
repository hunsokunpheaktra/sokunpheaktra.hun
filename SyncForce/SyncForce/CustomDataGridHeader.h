//
//  CustomDataGridHeader.h
//  Datagrid
//
//  Created by Gaeasys on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDataGridRow.h"

@interface CustomDataGridHeader : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    
    UITableView *headerTable;
    NSArray     *columnNames;
    NSArray     *columnTypes;
    id          target;
    BOOL        isGridEditAble;
    NSArray     *listSize;
    BOOL        isPortrait;
    
}

@property (nonatomic, retain) IBOutlet UITableView *headerTable;
@property (nonatomic, retain) NSArray* columnNames;
@property (nonatomic, retain) NSArray* columnTypes;
@property (nonatomic, retain) id target;
@property BOOL isGridEditAble;
@property (nonatomic,retain) NSArray *listSize;
@property BOOL isPortrait;


-(id)initWithPopulate:(CGRect)frame listSize:(NSArray*)listSize withColunmnames:(NSArray*)pcolumnNames colType:(NSArray*)colType bntTarget:(id)bntTarget isAction:(BOOL) isAction;

@end
