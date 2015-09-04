//
//  SynProcess.h
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncListener.h"
#import "SynchronizedViewController.h"
#import "Reachability.h"
#import "CheckedSaleforceLogin.h"
#import "LogItem.h"
#import "GetAttachmentBody.h"
#import "UpsertAttachmentRequest.h"


@class Reachability;

@interface SyncProcess : CheckedSaleforceLogin<UIAlertViewDelegate>{
  
    
    NSMutableArray *running;
    NSMutableArray *waiting;
    
    int completed;
    double percentage;
    
    SynchronizedViewController *syncCon;
    
}

@property (nonatomic, retain) NSMutableArray *running;
@property (nonatomic, retain) NSMutableArray *waiting;
@property (nonatomic,retain) SynchronizedViewController *syncCon;
@property(nonatomic,retain) NSArray *listrecods;


+ (SyncProcess *)getInstance;

- (void)start;
- (void)stop;
- (BOOL)isBlocking:(NSString *)errorCode;
- (BOOL)shouldRetry:(NSString *)errorCode;
- (void)checkRunning;
- (double)computePercent;





@end
