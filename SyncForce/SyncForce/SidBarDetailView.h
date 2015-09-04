//
//  SidBarDetailView.h
//  SyncForce
//
//  Created by Gaeasys on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JTTableViewDatasource;
@class JTRevealSidebarView;
@class ObjectDetailViewController;

@interface SidBarDetailView : UIViewController <UISearchBarDelegate>{
        
    UITableView* sideBarTableView;
    JTTableViewDatasource *_datasource;
    JTRevealSidebarView *_revealView;
    NSArray* rows;
    NSArray* listKeyFiled;
    NSMutableArray* listView;
    NSMutableArray* cellArray;
    NSMutableDictionary * mapFieldType;
    
    int start_number;
    int end_number;
    int rowSelect;
    id parentView;
    
    BOOL isPair;
}

@property (nonatomic, retain) UITableView* sideBarTableView;
@property int start_number;
@property int end_number;

-(NSString *) getFormatValue:(NSString*)origin type:(NSString*)type fieldName:(NSString*)fName;
- (id)initWithRevealView:(JTRevealSidebarView*)revealView entityName:(NSString*)entity parent:(id)parent;
@end
