//
//  EntityRequestUpdate.m
//  kba
//
//  Created by Gaeasys Admin on 10/4/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import "EntityRequestUpdate.h"
#import "EntityManager.h"
#import "IsNotNullCriteria.h"
#import "LikeCriteria.h"
#import "Entity.h"
#import "BypassInRequest.h"

@implementation EntityRequestUpdate

- (id)init:(NSString *)pentity listener:(NSObject<SyncListener>*) pListener{
    self = [super init];
    self.entity = pentity;
    self.listener = pListener;
    return self;
}

-(void)doRequest{

    ZKSObject *object = [[[ZKSObject alloc] initWithType:self.entity] autorelease];
    for(Item *item in [Entity getFieldsUpdateable:currentitem.entity]){
        NSString *field = [[item fields] valueForKey:@"name"];
        [object setFieldValue:[self.currentitem.fields valueForKey:field] field:field];
    }
    [object setFieldValue:[self.currentitem.fields valueForKey:@"Id"] field:@"Id"];
    [[FDCServerSwitchboard switchboard] update:[NSArray arrayWithObject:object] target:self selector:@selector(updateResult:error:context:) context:nil];
    
}

- (void)updateResult:(id)result error:(NSError *)error context:(id)context
{
    
    NSString *message = [NSString stringWithFormat:@"%@",[result objectAtIndex:0]]; 
    //error
    if([message length] != 18){
        [self didFailLoadWithError: message];
        return;
    }
    if (result && !error)
    {
        NSLog(@"updateResult : %@", message);
        [self.currentitem.fields setObject:@"0" forKey:@"modified"];
        [EntityManager update:self.currentitem modifiedLocally:false];
        
        [self.listener onSuccess:1 request:self again:[self prepare]];
    }
}


- (void)didFailLoadWithError:(NSString*)error{
    [self.currentitem.fields setObject:@"1" forKey:@"error"];
    if(currentitem.entity != nil) [EntityManager update:self.currentitem modifiedLocally:false];
    
    [self.listener onFailure:[NSString stringWithFormat:@"Salesforce Error %@", error] request:self again:YES];
}

- (NSString *)getName {
    return [NSString stringWithFormat:@"Uploading existing %@", self.entity];
}

- (BOOL)prepare {
    if([[BypassInRequest getBypass] containsObject:self.entity]){
        return NO;
    }
    self.entityInfo = [InfoFactory getInfo:self.entity];
    if([[self.entityInfo getAllFields] count] < 1) return NO;
    currentitem = nil;
    NSMutableDictionary *filters = [[NSMutableDictionary alloc] initWithCapacity:1];
    //[filters setValue:[[IsNullCriteria alloc] init] forKey:@"error"];
    [filters setValue:[ValuesCriteria criteriaWithString:@"1"] forKey:@"modified"];
    [filters setValue:[[ValuesCriteria alloc] initWithString:@"0"] forKey:@"error"];
    NSArray *li =  [EntityManager list:self.entity criterias:filters];
    if(li.count > 0){
        currentitem = [li objectAtIndex:0];
    }
    [filters release];
    return currentitem != nil;
}


@end
