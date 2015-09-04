//
//  RequestUpdate.h
//  Parcel
//
//  Created by Gaeasys on 1/8/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SalesforceAPIRequest.h"
#import "MainViewController.h"
#import "CheckedSaleforceLogin.h"
#import "MBProgressHUD.h"
#import "SalesforceAPIRequest.h"
#import "GetAttachmentBody.h"

@class LoginViewController;
@class MyParcelViewController;

@interface RequestUpdate : CheckedSaleforceLogin {

    NSArray*  records;
    NSString* entityName;
    id        parentVC;
    MBProgressHUD *hud;
    
}

- (id) initWithEntity: (NSString*)entity parentClass:(id) parentRef;
- (Item*) setLocalUserFields : (NSDictionary*) record;
- (void) updateData : (NSArray*)listUpdate;
- (void) start;

@end
