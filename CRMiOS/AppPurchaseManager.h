//
//  AppPurchaseManager.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 1/17/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "PadTabTools.h"
#import "MBProgressHUD.h"

#define AppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define AppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define AppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define PRODUCT_ID @"CRM4Mobile"

@interface AppPurchaseManager : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver,UIAlertViewDelegate>{
    SKProduct *responseProduct;
    SKProductsRequest *productsRequest;
    MBProgressHUD *_hud;
    UIViewController *parent;
}
@property (retain) MBProgressHUD *hud;
@property (nonatomic, retain) UIViewController *parent;
- (id)initwithView:(UIViewController *)view;
- (void)doRequest;
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseCRM4Mobile;

@end
