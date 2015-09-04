//
//  SynchronizeViewInterface.h
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MainMergeRecord;

@protocol SynchronizeViewInterface <NSObject>
    - (void) syncClick:(id)sender;
    - (void) sendErrorLog;
    - (void) refresh;
    - (NSString*) getSessionId;
    - (NSString*) getInstance;
    - (void) mergeViewOpen:(MainMergeRecord*)screen; 
@end
