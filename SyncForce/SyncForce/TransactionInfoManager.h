//
//  TransactionManager.h
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TransactionInfoManager : NSObject {
    
}

+ (void)initTable;
+ (void)save:(NSDictionary *)item;
+ (NSString *)readLastSyncDate:(NSString *)taskname;

@end
