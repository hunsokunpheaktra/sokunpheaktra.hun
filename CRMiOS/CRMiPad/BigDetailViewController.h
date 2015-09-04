//
//  BigDetailViewController.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "UITools.h"
#import "CustomCell.h"
#import "RelationManager.h"
#import "EditViewController.h"
#import "RelatedListViewController.h"
#import "PadMainViewController.h"
#import "LayoutPageManager.h"
#import "LayoutSectionManager.h"
#import "LayoutFieldManager.h"
#import "Action.h"
#import "UpdateListener.h"
#import "EvaluateTools.h"
#import "FaceBookLinkedInView.h"
#import "LayoutPageManager.h"
#import "MGSplitViewController.h"
#import "SublistDetailPopup.h"
#import "TakePictureController.h"
#import "DetailPDFExport.h"
#import "SublistEditVC.h"
#import "LongTextViewController.h"

#define DETAIL_FONT_SIZE 16.0
#define DETAIL_HEADER_FONT_SIZE 16.0
#define DETAIL_HEADER_HEIGHT 48.0
#define DETAIL_HEADER_ROW_WIDTH 400.0
#define DETAIL_MAX_CELL_HEIGHT 220.0

@class PadMainViewController;

@interface BigDetailViewController : UIViewController <CreationListener, UpdateListener, UITableViewDelegate, UITableViewDataSource, MGSplitViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    
    PadMainViewController *parent;
    NSDictionary *allFields;
    Item *detail;
    NSMutableArray *relations;
    NSDictionary *relatedItems;
    NSMutableArray *sublistItems;
    NSMutableArray *sublists;
    NSArray *pages;
    NSArray *sections;
    NSMutableArray *sectionData;
    NSString *subtype;
    NSObject <Subtype> *sinfo;
    NSNumber *currentPage;
    UIToolbar *toolbar;
    
    UIButton *favoriteButton;
    UISegmentedControl *segmentedControl;
    UIPopoverController *popoverController;
    UITableView *detailView;
    UIView *errorView;
    UILabel *contactNameLabel;
    UILabel *accountNameLabel;
    UIImageView *contactPicture;
    
    UIBarButtonItem *btnShowAction;
    NSObject<UpdateListener> *updateListener;
    UIActionSheet *actionSheet;
    
    NSArray *workAction;
    UIView *header;
    
    NSMutableArray *longFields;
    
}
@property (nonatomic, retain) MGSplitViewController *splitController;
@property (nonatomic, retain) NSArray *workAction;
@property (nonatomic, retain) NSObject<UpdateListener> *updateListener;
@property (nonatomic, retain) UIBarButtonItem *btnShowAction;
@property (nonatomic, retain) UIButton *favoriteButton;
@property (nonatomic, retain) PadMainViewController *parent;
@property (nonatomic, retain) NSNumber *currentPage;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSArray *pages;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSDictionary *allFields;
@property (nonatomic, retain) Item *detail;
@property (nonatomic, retain) NSDictionary *relatedItems;
@property (nonatomic, retain) NSMutableArray *relations;
@property (nonatomic, retain) NSMutableArray *sublistItems;
@property (nonatomic, retain) NSMutableArray *sublists;
@property (nonatomic, retain) NSMutableArray *sectionData;
@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) NSObject <Subtype> *sinfo;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UITableView *detailView;
@property (nonatomic, retain) UIView *errorView;
@property (nonatomic, retain) UILabel *contactNameLabel;
@property (nonatomic, retain) UILabel *accountNameLabel;
@property (nonatomic, retain) UIImageView *contactPicture;
@property (nonatomic, retain) NSMutableArray *longFields;

- (id)initDetail:(NSString *)newSubtype parent:(PadMainViewController *)parent;
- (void)edit;
- (void)clickToCollape:(id)sender;
- (NSMutableArray *)fillSectionData:(int)section;
- (void)addFavorite:(id)sender;
- (void)faceBookLinkedIn:(id)sender;
- (void)tabPagesChange:(id)sender;
- (void)setCurrentDetail:(Item *)newDetail;
- (void)showActionSheet;
- (void)addRelated:(id)sender;
- (void)addSublist:(id)sender;
- (void)checkAction;
- (void)exportPDF;

@end
