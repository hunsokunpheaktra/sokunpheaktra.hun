//
//  SalesforceAPIRequest.h
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/5/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncListener.h"
#import "Item.h"

#define LOGIN_HOST @"https://login.salesforce.com"
#define AUTH_SERVICE @"/services/oauth2/token"

#define URL_SERVICE_SOQL @"/services/data/v25.0/query/?q="
#define URL_SERVICE @"/services/data/v25.0/sobjects/"

#define CLIENT_SECRET @"794037618573580060"
#define CONSUMER_KEY @"3MVG99qusVZJwhsnxVdYaeJqv1cTLD2RMfFELiUdU99H9SiY247qzTbauXgnf1EQwYvTlzo11xuNcEN80kpW0"
#define MASTER_USR @"mmtdev@matchmytime.com"
#define MASTER_Pass @"Schw3d3n!"
#define MASTER_TOKEN @"OBQoAODcMt8EG82M6r40fTNi"

@interface SalesforceAPIRequest : NSObject

@property (nonatomic, retain) NSURLConnection *theConnection;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSObject<SyncListener> *synListener;
@property (nonatomic, retain) NSArray *records;
@property (nonatomic, retain) UIImage *downloadImage;

@property (nonatomic ,retain) Item *item;

-(void)doRequest:(NSObject<SyncListener> *)listen;
-(NSString *)getProccessName;
-(NSString *)getMethod;

@end
