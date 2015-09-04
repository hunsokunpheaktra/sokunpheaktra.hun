//
//  SyncManager.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPListener.h"
#import "Configuration.h"
#import "EntityRequest.h"
#import "PicklistRequest.h"
#import "SyncListener.h"
#import "LogManager.h"
#import "SOAPRequest.h"
#import "FieldRequest.h"
#import "OutgoingEntityRequest.h"
#import "EntityManager.h"
#import "SalesStageRequest.h"
#import "PropertyManager.h"
#import "IsNotNullCriteria.h"
#import "OtherPicklistRequest.h"
#import "CustomRecordTypeRequest.h"
#import "CurrencyCodeRequest.h"
#import "ServerTimeRequest.h"
#import "DeletedItemsRequest.h"
#import "CurrentUserRequest.h"
#import "IndustryRequest.h"
#import "MetadataChangeRequest.h"
#import "GetConfig.h"
#import "PharmaRequest.h"
#import "OutgoingSublistRequest.h"
#import "LicenseCheck.h"
#import "UpdateSyncTime.h"
#import "CascadingPicklistRequest.h"
#import "DeletedSublistRequest.h"
#import "CompanyRequest.h"
#import "FieldManagementRequest.h"
#import "AssessmentsRequest.h"
#import "TestFlight.h"

#define PIPELINE_SIZE 2

@interface SyncProcess : NSObject <SOAPListener> {
    NSObject <SyncListener> *listener;
    NSString *error;
    NSString *errCode;
    NSMutableArray *running;
    NSMutableArray *waiting;
    int completed;
    double percentage;
    NSNumber *cancelled;
    int taskNum;
    int phase;
}
@property (nonatomic, retain) NSMutableArray *running;
@property (nonatomic, retain) NSMutableArray *waiting;
@property (nonatomic, retain) NSString *error;
@property (nonatomic, retain) NSObject <SyncListener> *listener;
@property (nonatomic, retain) NSNumber *cancelled;
@property (readwrite) int phase;
@property (nonatomic, retain) NSString *errCode;

+ (SyncProcess *)getInstance;
- (void)start:(NSObject <SyncListener> *)listener;
- (void)stop;
- (void)end;
- (BOOL)isRunning;
- (BOOL)isBlocking:(NSString *)errorCode errorMessage:(NSString *)errorMessage;
- (BOOL)shouldRetry:(NSString *)errorCode errorMessage:(NSString *)errorMessage;
- (void)checkRunning;
- (double)computePercent;
+ (NSString *)getLibSuccess:(int)code;
- (void)buildTasks;
+ (BOOL)isBadLogin:(NSString *)errorMessage;

@end
