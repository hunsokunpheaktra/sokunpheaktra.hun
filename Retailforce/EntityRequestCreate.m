 //
//  EntityRequestCreate.m
//  kba
//
//  Created by Gaeasys Admin on 10/4/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import "EntityRequestCreate.h"
#import "EntityManager.h"
#import "IsNotNullCriteria.h"
#import "Entity.h"
#import "PropertyManager.h"
#import "BypassInRequest.h"

@implementation EntityRequestCreate

- (id)init:(NSString *)pentity listener:(NSObject<SyncListener>*)plistener{
    self = [super init];
    self.entity = pentity;
    
    self.listener = plistener;
    return self;
}

-(void)doRequest{

    ZKSObject *object = [[[ZKSObject alloc] initWithType:self.entity] autorelease];
    for(Item *item in [Entity getFieldsCreateable:currentitem.entity]){
        NSString *field = [[item fields] valueForKey:@"name"];
        [object setFieldValue:[self.currentitem.fields valueForKey:field] field:field];
    }
    
    if([[entityInfo getAllFields] containsObject:@"OwnerId"])
        [object setFieldValue:[PropertyManager read:@"CurrentUserId"] field:@"OwnerId"];
    
    
        
    [[FDCServerSwitchboard switchboard] create:[NSArray arrayWithObject:object] target:self selector:@selector(createResult:error:context:) context:nil];
}
     
- (void)createResult:(id)result error:(NSError *)error context:(id)context
{
    NSLog(@"createResult : %@", result);
    if([(NSArray *)result count] == 0){
        [self didFailLoadWithError: @"Insertion failed"];
        return;  
    }
    NSString *message = [NSString stringWithFormat:@"%@",[result objectAtIndex:0]]; 
    //error
    if([message length] != 18){
       [self didFailLoadWithError: message];
       return;
    }
    if (result && !error)
    {
        NSLog(@"createResult : %@", message);
        [self.currentitem.fields setObject: message forKey:@"Id"];
        [EntityManager update:self.currentitem modifiedLocally:false];
        [self.listener onSuccess:1 request:self again:YES];
    }

}

- (void)didFailLoadWithError:(NSString*)error{
    [self.currentitem.fields setObject:@"1" forKey:@"error"];
    if(currentitem.entity != nil) [EntityManager update:self.currentitem modifiedLocally:false];
    
    [self.listener onFailure:[NSString stringWithFormat:@"Salesforce Error %@", error] request:self again:YES];
}

- (NSString *)getName {
    return [NSString stringWithFormat:@"Uploading new %@", self.entity];
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
    [filters setValue:[ValuesCriteria criteriaWithString:@"2"] forKey:@"modified"];
    //[filters setValue:[[IsNullCriteria alloc] init] forKey:@"Id"];
    [filters setValue:[[ValuesCriteria alloc] initWithString:@"0"] forKey:@"error"];
    NSArray *li =  [EntityManager list:self.entity criterias:filters];
    if(li.count > 0){
        currentitem = [li objectAtIndex:0];
    }
    [filters release];
    return currentitem != nil;
}


    
@end
