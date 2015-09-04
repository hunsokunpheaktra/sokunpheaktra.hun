//
//  DragAndDropViewController.h
//  CRMiOS
//
//  Created by Sy Pauv on 10/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TKCalendarMonthView.h"
#import "Item.h"
#import "Configuration.h"
#import "LikeCriteria.h"
#import "GroupManager.h"
#import "FilterManager.h"
#import "EditViewController.h"
#import "UpdateListener.h"
#import "FilterListPopup.h"
#import "OrCriteria.h"
#import "PadTabTools.h"

#define cellIdentifier @"DropTableCell"
#define navBarHeight 30

@interface DragAndDropViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, TKCalendarMonthViewDataSource, TKCalendarMonthViewDelegate, UpdateListener, CreationListener, UISearchBarDelegate>
{
    
    UINavigationItem*   srcTableNavItem;
    UINavigationItem*   dstTableNavItem;
    
    UINavigationBar *srcTableNavBar;
    UINavigationBar *dstTableNavBar;
    
    UITableView*        srcTableView;
    UITableView*        dstTableView;
    UITableViewCell*    draggedCell;
    UIView*             dropArea;
    
    NSMutableArray*     contactData;
    NSMutableArray*     dstData;
    id                  draggedData;
    
    BOOL            dragFromSource;     // used for reodering
    NSIndexPath*    pathFromDstTable;   // used to reinsert data when reodering fails
    //calendar 
    TKCalendarMonthView *calendar;
    NSDate *selectedDate;
    
    NSString *nameFilter;
    UISearchBar *uIsearchBar;
    UIBarButtonItem *barinfo;
    UIActionSheet *asheet;
}

@property (nonatomic, retain) UIBarButtonItem *barinfo;
@property (nonatomic, retain) UISearchBar *uIsearchBar;
@property (nonatomic, retain) UIBarButtonItem *filter;
@property (nonatomic, retain)    NSString *nameFilter;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) TKCalendarMonthView *calendar;
@property (nonatomic, readonly) NSArray* contactData;
@property (nonatomic, readonly) NSArray* dstData;

- (void)getContactData;
- (void)filterAppointmentData;
- (void)chooseView;
- (void)filterClick:(id)sender;

- (void)setupSourceTableWithFrame:(CGRect)frame;
- (void)setupDestinationTableWithFrame:(CGRect)frame;
- (void)initDraggedCellWithCell:(UITableViewCell*)cell AtPoint:(CGPoint)point;

- (void)startDragging:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)startDraggingFromSrcAtPoint:(CGPoint)point pointscreen:(CGPoint)screenPoint;

- (void)doDrag:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)stopDragging:(UIPanGestureRecognizer *)gestureRecognizer;

- (UITableViewCell*)srcTableCellForRowAtIndexPath:(NSIndexPath*)indexPath;
- (UITableViewCell*)dstTableCellForRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)showinfo;


@end
