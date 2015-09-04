//
//  DetailViewController.h
//  CRM
//
//  Created by MACBOOK on 4/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityInfo.h"
#import "Configuration.h"
#import "EditingViewController.h"
#import "RelationManager.h"
#import "ListViewController.h"
#import "UITools.h"
#import "UpdateListener.h"
#import "Relation.h"
#import "ListRelationViewController.h"
#import "SublistRelationVC.h"
#import "LayoutFieldManager.h"
#import "LayoutPageManager.h"
#import "LayoutSectionManager.h"
#import "DetailViewController.h"
#import "FaceBookLinkedInView.h"
#import "IphoneSublistDetail.h"
#import "RelationSub.h"


#define IPHONE_DETAIL_FONT_SIZE 16.0f
#define IPHONE_DETAIL_CELL_CONTENT_WIDTH 320.0f
#define IPHONE_DETAIL_CELL_CONTENT_MARGIN 5.0f

@class ListViewController;

@interface DetailViewController : UIViewController <UpdateListener, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	NSArray *listField;
    NSDictionary *relatedItems;
    Item *item;
    UITableView *tableView;
    UIButton *favoriteButton;
    UIToolbar *toolbar;
    NSMutableArray *relations;
    NSObject <UpdateListener> *listener;
    NSObject<Subtype> *sinfo;
    NSString *subtype;
    NSNumber *currentPage;
    NSMutableArray *sectionData;
    NSArray *sections;
    NSArray *pages;
    
    UIImageView *contactPicture;
    UILabel *contactNameLabel;
    UILabel *accountNameLabel;
    NSArray *workAction;
    
    NSArray *subListNames;
    NSDictionary *sublistValues;
    UIImagePickerController *imagePicker;
    BOOL isdelete;
}

@property(nonatomic, retain)  UIImagePickerController *imagePicker;
@property (nonatomic, retain) NSDictionary *sublistValues;
@property (nonatomic, retain) NSArray *subListNames;
@property (nonatomic, retain) NSArray *workAction;
@property (nonatomic, retain) UILabel *accountNameLabel;
@property (nonatomic, retain) UILabel *contactNameLabel;
@property (nonatomic, retain) UIImageView *contactPicture;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIButton *favoriteButton;
@property (nonatomic, retain) NSMutableArray *sectionData;
@property (nonatomic, retain) NSString *subtype;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSArray *pages;
@property (nonatomic, retain) NSObject<Subtype> *sinfo;
@property (nonatomic, retain) NSMutableArray *relations;
@property (nonatomic, retain) NSArray *listField;
@property (nonatomic, retain) NSDictionary *relatedItems;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSNumber *currentPage;

@property (nonatomic, retain) NSObject <UpdateListener> *listener;

- (id)initWithItem:(Item *)newItem listener:(NSObject <UpdateListener> *)listener;
- (void)addFavorite:(id)sender;
- (void)faceBookLinkedIn:(id)sender;
- (void)segmentPageChange:(id)sender;

- (NSArray *)fillSectionData:(int)section;
- (void)actionClicked;
- (void)checkAction;
- (void)takePicture;
- (void)createRelatedItem:(id)sender;

- (void)actionHandle:(int)index;
- (void)createRelatedItemHandle:(int)index;
- (void)updateSections;

@end
