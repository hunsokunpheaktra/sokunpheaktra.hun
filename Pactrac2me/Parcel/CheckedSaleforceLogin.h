//
//  CheckedSaleforceLogin.h
//  Parcel
//
//  Created by Gaeasys on 1/8/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "LoginRequest.h"
#import "CreateRecordRequest.h"
#import "DeleteRecordRequest.h"
#import "QueryRequest.h"
#import "Reachability.h"


@class AppDelegate;

@interface CheckedSaleforceLogin : NSObject <SyncListener> {

    NSString *error;
    NSNumber *cancelled;
    Reachability* hostReach;
    Reachability* internetReach;
    
}

@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;

@property (nonatomic, retain) NSString *error;
@property (nonatomic, retain) NSNumber *cancelled;


- (BOOL) doAlertInternetFailed;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
- (void) startNotifier;
- (void) checkNetworkStatus:(NSNotification *)notice;

- (void) userRequest;
- (void) checkSaleForceLogin;
- (void) registerDeviceToken;
- (void) checkDeviceToken;
- (void) registerUser;

- (BOOL)isRunning;

@end
