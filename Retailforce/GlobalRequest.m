//
//  GlobalRequest.m
//  SyncForce
//
//  Created by Hun Sokunpheaktra on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GlobalRequest.h"
#import "FDCServerSwitchboard.h"
#import "ZKDescribeGlobalSObject.h"
#import "EntityManager.h"
#import "EntityRequest.h"

@implementation GlobalRequest
    
-(void)doRequest{
    [[FDCServerSwitchboard switchboard] describeGlobalWithTarget:self selector:@selector(describeGlobalCallback:error:context:) context:nil];
}

- (BOOL)checkObject:(NSString*)sobjectName{
    
    NSMutableArray *standard = [[[NSMutableArray alloc] initWithObjects:@"Account",@"Lead",@"Contract",@"Asset",@"Contact",@"Opportunity",@"Case",@"Campaign",@"Activity",@"Calendar",@"Price Book",@"Event",@"Task", nil] autorelease];
    
    if([sobjectName rangeOfString:@"__c"].length > 0){
        return YES;
    }
    if([standard containsObject:sobjectName]){
        return YES;
    }
        
    return NO;
}

- (void)describeGlobalCallback:(NSArray*)result error:(NSError *)error context:(id)contex{
    
    for(ZKDescribeGlobalSObject *sobject in result){ 
        if(sobject.queryable){
            if([self checkObject:sobject.name]){
            
                NSMutableDictionary *fields = [NSMutableDictionary dictionary];
                NSString *localid = [NSString stringWithFormat:@"%d",[EntityManager getCount:@"Filter"] + 1]; 
                
                [fields setValue:localid forKey:@"local_id"];
                [fields setValue:sobject.name forKey:@"objectName"];
                [fields setValue:sobject.label forKey:@"label"];
                [fields setValue:@"no" forKey:@"value"];
            
            }
        }
    }
    
    
}

-(void)didFailLoadWithError:(NSString *)error{
    
}

@end
