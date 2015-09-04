//
//  MyParcelViewController.h
//  Parcel
//
//  Created by Davin Pen on 10/2/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import <StoreKit/StoreKit.h>
#import "UpdateListener.h"
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"
#import <QuickLook/QuickLook.h>
#import "SyncListener.h"
#import "BasicPreviewItem.h"
#import "Appirater.h"
#import "EGORefreshTableHeaderView.h"

@interface MyParcelViewController : UIViewController<UISearchBarDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UpdateListener,QLPreviewControllerDataSource,SyncListener,UIAlertViewDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate>{
    
    NSMutableArray *allParcels;
    NSMutableArray *originalParcels;
    UITableView *tableView;
    UISearchBar *searchBar;

}

@property(nonatomic,retain)UISearchBar *searchBar;
@property(nonatomic,retain)UITableView *tableView;
@property(nonatomic,retain)NSString *imageFilePath;
@property(nonatomic,retain)MBProgressHUD *hud;
@property(nonatomic,retain)EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic,readwrite)BOOL reloading;

-(void)addParcel;
-(void)refresh;
-(void)openTutorial;
-(void)showMap:(UIButton*)button;
-(void)previewImage:(UIButton*)button;
-(void)finishUpdating;
-(void)tapTableView:(UIGestureRecognizer*)tap;
-(void)showHud:(NSString*)textLabel;
-(void)hideHud:(NSString*)textLabel;

@end
