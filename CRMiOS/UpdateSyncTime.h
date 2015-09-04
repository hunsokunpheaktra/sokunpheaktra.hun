//
//  UpdateSyncTime.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/26/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncTask.h"
#import "SOAPListener.h"
#import "LicenseRequest.h"
@interface UpdateSyncTime : LicenseRequest{

}

- (id)init:(NSObject <SOAPListener> *)newListener;

@end
