//
//  EntityRequestDeleted.m
//  SyncForce
//
//  Created by Gaeasys Admin on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntityRequestDeleted.h"
#import "EntityManager.h"
#import "IsNotNullCriteria.h"
#import "Entity.h"
#import "TransactionInfoManager.h"
#import "DatetimeHelper.h"
#import "FDCDeletedObject.h"
#import "BypassInRequest.h"
#import "PropertyManager.h"

@implementation EntityRequestDeleted
@synthesize startdate;

- (id)init:(NSString *)pentity listener:(NSObject<SyncListener>*)plistener{
    self = [super init];
    self.entity = pentity;
    self.listener = plistener;
    isDone = NO;
    return self;
}

-(void)doRequest{
    
    [[FDCServerSwitchboard switchboard] getServerTimestampWithTarget:self selector:@selector(getServerTimestampResult:error:context:) context:nil];
    isDone = YES;
}

-(void) getServerTimestampResult:(NSDate *)timestamp error:(NSError *)error context:(id)context{
    
    NSLog(@"getServerTimestampResult: %@ error: %@ context: %@", timestamp, error, context);
    if (timestamp && !error)
    {
        NSLog(@" Deleted For : %@  , %@ to %@",self.entity,self.startdate, timestamp);
        [[FDCServerSwitchboard switchboard] getDeleted:self.entity fromDate:startdate toDate:timestamp target:self selector:@selector(deletedResult:error:context:) context:nil];
    }else if (error){
        [self didFailLoadWithError: [NSString stringWithFormat:@"%@",error]];
    }
}

- (void)deletedResult:(FDCGetDeletedResult *)result error:(NSError *)error context:(id)context
{
    NSLog(@"getDeletedResult: %@ error: %@ context: %@", result, error, context);
    if (result && !error){
        NSLog(@"deleted records: %@", result.records);
        int count = 0;
        NSMutableDictionary *filters = [[NSMutableDictionary alloc] initWithCapacity:1];
        [filters setValue:[ValuesCriteria criteriaWithString:@"0"] forKey:@"modified"];
        [filters setValue:[[ValuesCriteria alloc] initWithString:@"0"] forKey:@"error"];
        for(FDCDeletedObject *deletedObject in result.records){
            [filters setValue:[[ValuesCriteria alloc] initWithString:deletedObject.Id] forKey:@"Id"];
            self.currentitem = [EntityManager find:self.entity criterias:filters];
            if(self.currentitem != nil){
                [EntityManager remove:self.currentitem];
                count++;
            }
        }
        [filters release];
        [TransactionInfoManager save:[NSDictionary dictionaryWithObjectsAndKeys:[self getName],@"TaskName", [DatetimeHelper serverDateTime:[NSDate date]],@"LastSyncDate", nil]];
        [self.listener onSuccess:count request:self again:YES];
    }else if (error){
        [self didFailLoadWithError: [NSString stringWithFormat:@"%@",error]];
    }
}


- (void)didFailLoadWithError:(NSString*)error{
    [self.listener onFailure:[NSString stringWithFormat:@"Salesforce Error %@", error] request:self again:YES];
}

- (NSString *)getName {
    return [NSString stringWithFormat:@"Removing deleted %@", self.entity];
}

- (BOOL)prepare {
    if([[BypassInRequest getBypass] containsObject:self.entity]){
        return NO;
    }
    //startdate = [NSDate dateWithTimeIntervalSinceNow: - (5 * 60 * 60 * 24)];
    self.startdate = [DatetimeHelper stringToDateTime:[PropertyManager read:@"LastSync"]];
    
    NSLog(@"Start Date : %@",startdate);
    
    if(self.startdate == nil) isDone = YES;
    return !isDone;
}

@end
