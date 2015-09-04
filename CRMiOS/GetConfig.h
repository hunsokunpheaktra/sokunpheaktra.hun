//
//  GetConfig.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/20/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyManager.h"
#import "SyncTask.h"
#import "SOAPListener.h"
#import "ConfigLoader.h"
#import "Configuration.h"
#import "LayoutFieldManager.h"

@interface GetConfig : NSObject <SyncTask> {
    NSNumber *task;
    NSNumber *callNum;
    NSMutableData *webData;
    NSObject <SOAPListener> *listener;
    BOOL useRole;
    NSHTTPURLResponse *currentResponse;
}

@property (nonatomic, retain) NSNumber *task;
@property (nonatomic, retain) NSNumber *callNum;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSObject <SOAPListener> *listener;
@property (readwrite) BOOL useRole;
@property (nonatomic, retain) NSHTTPURLResponse *currentResponse;

- (id)init:(NSObject <SOAPListener> *)newListener useRole:(BOOL)pUseRole;
- (void)getFile;
+ (NSString *)escape:(NSString *)s;
- (NSString *)fixConfigName;

@end
