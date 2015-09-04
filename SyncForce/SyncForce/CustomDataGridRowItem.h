//
//  CustomDataGridRowItem.h
//  Datagrid
//
//  Created by Gaeasys on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatagridListener.h"
#import "GridItem.h"
#import "NavigateListener.h"
#import "DateTimeAndReferenceChooser.h"

@class CustomDataGrid;

@interface CustomDataGridRowItem : NSObject<UITextFieldDelegate>{
    
    NSObject<DatagridListener> *listener;
    NSObject<NavigateListener> *navListener;
    
    CGSize		baseSize;							
	UIControl	* control;				
	NSString    * controlLabel;
    int         columnType;
    NSString    *itemId;
    id          aTarget;
    BOOL        isView;
    BOOL        updateable;

}


@property(nonatomic, assign) CGSize baseSize;
@property(nonatomic, retain) UIControl *control;
@property(nonatomic, retain) NSString *controlLabel;
@property BOOL updateable;
@property BOOL isView;
@property int columnType;


- (id)initWithRowItemType:(BOOL)itemType columnType:(int)colType entityName:(NSString*)entityName fieldName:(NSString*)fieldName baseSize:(CGSize)size controlLabel:(NSString *)label listener:(NSObject<DatagridListener> *)listener gridItem:(NSString *)item buttonTarget:(id)target tag:(int)tag navigateListener:(NSObject<NavigateListener>*)navigateListener isView:(BOOL)view;

- (id)initWithColumnType:(int)colType entityName:(NSString*)entityName fieldName:(NSString*)fieldName recordTypeId:(NSString*)recordType rowIndex:(int)rowIndex columnIndex:(int)columnIndex baseSize:(CGSize)size controlLabel:(NSString *)label listener:(NSObject<DatagridListener> *)listener buttonTarget:(id)target;

- (void)actionClick:(id)sender ;

@end
