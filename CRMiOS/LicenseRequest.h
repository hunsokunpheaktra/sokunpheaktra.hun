//
//  LicenseRequest.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncTask.h"
#import "SOAPListener.h"
#import "PropertyManager.h"
#import "LicenseResponse.h"

#define LICENSE_URL	@"https://crm4mobile-check.appspot.com"

@interface LicenseRequest : NSObject <ParserListener, SyncTask>{
    
    NSNumber *task;
    NSNumber *callNum;
    NSMutableData *webData;
    NSNumber *status;
    NSObject <SOAPListener> *listener;
    
}

@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSNumber *task;
@property (nonatomic, retain) NSNumber *callNum;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSObject <SOAPListener> *listener;

- (id)init:(NSObject <SOAPListener> *)newListener;
- (NSString *)getURLSuffix ;
- (ResponseParser *)getParser;
- (NSString *)getDeviceName;
- (NSString *)getAction;

@end

