//
//  LicenseCheck.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/25/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncTask.h"
#import "SOAPListener.h"
#import "PropertyManager.h"
#import "LicenseResponse.h"
#import "LicenseRequest.h"


@interface LicenseCheck : LicenseRequest{

}
- (id)init:(NSObject <SOAPListener> *)newListener;

@end
