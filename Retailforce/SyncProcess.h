//
//  SynProcess.h
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncListener.h"
#import "EntityRequest.h"
#import "EntityRequestCreate.h"
#import "EntityRequestUpdate.h"
#import "InfoFactory.h"
#import "SynchronizeViewInterface.h"
#import "SynchronizeViewController.h"

#define PIPELINE_SIZE 1

@class Reachability;
@interface SyncProcess : NSObject<SyncListener>  {
    NSString *error;
    NSMutableArray *running;
    NSMutableArray *waiting;
    int completed;
    double percentage;
    NSNumber *cancelled;
    int taskNum;
    int retryCount;
    int shouldRetrieveContent;
    Boolean isContentRetrieved;
    NSObject<SynchronizeViewInterface> *syncCon;
    NSMutableArray *syncList;
    
    Reachability* hostReach;
    Reachability* internetReach;
    BOOL internetActive;
    BOOL hostActive;
    BOOL isFirst;
    
    NSArray *listrecods;
    
    NSArray* list_ignore_sobject;
    NSArray* list_ignore_layout;
    NSArray* list_ignore_child_query;
    
    
}
@property (nonatomic, retain) NSMutableArray *running;
@property (nonatomic, retain) NSMutableArray *waiting;
@property (nonatomic, retain) NSString *error;
@property (nonatomic, retain) NSNumber *cancelled;
@property (nonatomic, retain) NSMutableArray *syncList;

@property (nonatomic, retain) NSArray *list_ignore_sobject;
@property (nonatomic, retain) NSArray *list_ignore_layout;
@property (nonatomic, retain) NSArray *list_ignore_child_query;

@property(nonatomic,retain) NSArray *listrecods;
@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;

@property (nonatomic, retain) NSObject<SynchronizeViewInterface> *syncCon;

+ (SyncProcess *)getInstance;
- (void)start:(NSObject*)psyncCon;
- (void)stop;
- (BOOL)isRunning;
- (BOOL)isBlocking:(NSString *)errorCode;
- (BOOL)shouldRetry:(NSString *)errorCode;
- (void)checkRunning;
- (double)computePercent;
+ (NSString *)getLibSuccess:(int)code;

- (BOOL) doAlertInternetFailed;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
- (void) startNotifier;
- (void) checkNetworkStatus:(NSNotification *)notice;



@end
