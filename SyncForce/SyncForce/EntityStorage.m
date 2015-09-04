//
//  EntityStorage.m
//  SalesforceSyncModule
//
//  Created by Gaeasys Admin on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntityStorage.h"
#import "EntityManager.h"
#import "TransactionInfoManager.h"
#import "InfoFactory.h"

@implementation EntityStorage
@synthesize tasknum,listener;

- (id)init:(NSObject<SyncListener>*)newListener{
    self.listener = newListener;
    return self;
}

- (void)doRequest{
    //help to wait the processing before go to next request
    NSMutableArray* arrwait = [NSMutableArray arrayWithObjects: @"1", @"2", @"3", @"4", @"5", @"1", @"2", @"3", @"4", @"5", nil];
    @synchronized(arrwait){
        [InfoFactory initInfos];
        [EntityManager initTables];
        while([arrwait count] > 0){
            [arrwait removeLastObject];
            if([arrwait count] == 0){
                [self.listener onSuccess:-1 request:self again:false];
            }
        }
    }
}
- (NSString *)getName{ 
    return @"Initialize Data Storage";
}

- (void)setTask:(NSNumber *)taskNum {
    self.tasknum = tasknum;
}

- (NSNumber *)getTasknum {
    return self.tasknum;
}

- (NSString *)getEntity { 
    return nil;
}

- (Item*) getCurrentitem{
    return nil;
}

- (BOOL)prepare{
    NSString *lastsyncDate= [TransactionInfoManager readLastSyncDate:[self getName]];
    return lastsyncDate == nil;
}

@end
