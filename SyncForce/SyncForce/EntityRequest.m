//
//  EntityRequest.m
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import "EntityRequest.h"
#import "InfoFactory.h"
#import "EntityManager.h"
#import "PropertyManager.h"
#import "DirectoryHelper.h"
#import "ZKSObject.h"
#import "TransactionInfoManager.h"
#import "FilterObjectManager.h"
#import "GreaterThanCriteria.h"
#import "GreaterThanOrEqualCriteria.h"
#import "LikeCriteria.h"
#import "LessThanCriteria.h"
#import "LessThanOrEqualCriteria.h"
#import "NotInCriteria.h"
#import "FilterManager.h"

@implementation EntityRequest

@synthesize entity,entityInfo;
@synthesize dateFilter;
@synthesize listener;
@synthesize tasknum,currentitem;

- (id)initWithEntity:(NSString *)newEntity listener:(NSObject<SyncListener>*) newListener {
    self.entity = newEntity;
    self.listener = newListener;
    return self;
}
- (NSString*)getCriteria:(Item*)item{
    
    NSString *oper = [item.fields valueForKey:@"operator"];
    NSMutableString *criter = [[[NSMutableString alloc] initWithCapacity:1] autorelease];
    [criter appendFormat:@"%@ ",[item.fields valueForKey:@"fieldName"]];
    
    NSObject<Criteria> *criteria;
    
    if([oper isEqualToString:@"equals"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"not equal to"]){
        criteria = [[NotInCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"not start with"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"starts with"]){
        criteria = [[LikeCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"contains"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"does not contain"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"less than"]){
        criteria = [[LessThanCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"greater than"]){
        criteria = [[GreaterThanCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"less or equal"]){
        criteria = [[LessThanOrEqualCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"greater or equal"]){
        criteria = [[GreaterThanOrEqualCriteria alloc] initWithValue:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"includes"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }else if([oper isEqualToString:@"excludes"]){
        criteria = [[ValuesCriteria alloc] initWithString:[item.fields valueForKey:@"value"]];
    }
    
    NSString* subOrName = @"";
    
    if ([entity isEqualToString:@"Case"] ||
        [entity isEqualToString:@"Task"] ||
        [entity isEqualToString:@"Event"]
        ) {
        subOrName = @"Subject";
    }
    else if ([entity isEqualToString:@"Contract"]) subOrName = @"ContractNumber";
    else subOrName = @"Name";
    
    [criter appendString:[[criteria getCriteria] stringByReplacingOccurrencesOfString:@"?" withString:@""]];
    if ([[item.fields objectForKey:@"fieldName"] isEqualToString:subOrName]) {
        NSString *value = [item.fields valueForKey:@"value"];
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];
        value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [criter appendFormat:@"'%@'",value];
    }else [criter appendFormat:@"%@",[item.fields valueForKey:@"value"]];

    
    return criter;
}


- (NSString*) getQueryContents{
    // read the selected Entity Info
    NSArray * allfields =  [self.entityInfo getAllFields];
    NSMutableString* querystring = [[NSMutableString alloc] initWithCapacity:1];
    
	// construct the query dynamically
    [querystring appendString: @"Select "];
    for(int i = 0 ; i < allfields.count; i++){
        if(i > 0) [querystring appendString:@", "];
        [querystring appendString: [allfields objectAtIndex:i]];
    }
    [querystring appendString:@" From "];
    [querystring appendString:self.entity];
   
    NSArray* listFilter = [FilterObjectManager list:entity];
    
    if(self.dateFilter != nil && ![self.dateFilter isEqualToString:@""]){
      // if([listFilter count] == 0){
          if([self.entity isEqualToString:@"ContentWorkspaceDoc"]){
             [querystring appendString:@" Where ContentDocument.LastModifiedDate = "];
             [querystring appendString:self.dateFilter];
          }else{
             Item *item = [FilterManager find:entity];
             NSString *lastSyn = [item.fields valueForKey:@"lastSyn"];
             if(lastSyn || item == nil){
                [querystring appendString:@" Where LastModifiedDate >= "];
                [querystring appendString:self.dateFilter];
             }
          }
       //}   
    }
    
    if([listFilter count] > 0){
        if([querystring rangeOfString:@"Where"].length>0){
            [querystring appendString:@" And ( "];
        }else{
            [querystring appendString:@" Where "];
        }
        for(int i=0;i<[listFilter count];i++){
            Item *item = [listFilter objectAtIndex:i];
            NSString *str = [self getCriteria:item];
            [querystring appendString:str];
            if(i<([listFilter count]-1)) [querystring appendString:@" OR "];
        }
        if([querystring rangeOfString:@"("].length > 0) [querystring appendString:@" )"];
    }

    //NSLog(@"=== %@", querystring);
      
    return querystring;
}

- (void)doRequest {    
    // loop on all fields and build the query
    self.dateFilter = [TransactionInfoManager readLastSyncDate:[self getName]];
    NSString *queryString =  [NSString stringWithFormat:@"%@",[self getQueryContents]];
    [[FDCServerSwitchboard switchboard] query:queryString target:self selector:@selector(queryResult:error:context:) context:nil];

}

- (void)queryResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSLog(@"INcoming %@", result);
    
    if (result != nil && error == nil)
    {
        NSLog(@"queryResult:%@ eror:%@ context:%@", result, error, context);
        NSMutableArray *allDetails = [NSMutableArray arrayWithArray:result.records];
        NSString *userId = nil;
        NSString *currencyCode = nil;
        NSString *usertimezone = nil;
        if ([self.entity isEqualToString:@"User"]) {
            userId = [PropertyManager read:@"CurrentUserId"];
        }      
    
        for(ZKSObject *sobject in result.records){
            [sobject.fields setValue:@"0" forKey:@"error"];
            [sobject.fields setValue:@"0" forKey:@"deleted"];
            
            Item *item = [[Item alloc] initCustom:self.entity fields:[NSDictionary dictionaryWithDictionary:sobject.fields]];
            BOOL isLocal = [EntityManager find:self.entity column:@"Id" value:[[item fields] valueForKey:@"Id"]] != nil;
            if(isLocal) [EntityManager update:item modifiedLocally:false];
            else [EntityManager insert:item modifiedLocally:false];
            
            // if entity test = user, we need to save in the property Manager Timezone, Currency code
            if ([self.entity isEqualToString:@"User"]) {
                if ([userId isEqualToString: [[[item fields] valueForKey:@"Id"] substringWithRange:NSMakeRange(0, 15)]]) {
                    currencyCode = [item.fields valueForKey:@"CurrencyIsoCode"]; 
                    usertimezone = [item.fields valueForKey:@"TimeZoneSidKey"]; 
                    [PropertyManager save:@"CurrencyIsoCode" value:currencyCode];
                    [PropertyManager save:@"TimeZoneSidKey" value:usertimezone];
                }
                
            }
            
            [item release];
        }
        
        [self.listener onSuccess:allDetails.count request:self again:false];
    }
    if (error != nil){
        NSLog(@"Eorr: %@",error);
        [self didFailLoadWithError:[NSString stringWithFormat:@"%@", error]];
    }
}

- (void)didFailLoadWithError:(NSString*)error{
    [self.currentitem.fields setObject:@"1" forKey:@"error"];
    if(currentitem.entity != nil) [EntityManager update:self.currentitem modifiedLocally:false];
    
    [self.listener onFailure:[NSString stringWithFormat:@"Salesforce Error %@", error] request:self again:false];
}

- (NSString *)getName {
    return [NSString stringWithFormat:@"%@ Incoming", self.entity];
}

- (NSNumber *)getTasknum {
    return self.tasknum;
}

- (void)setTask:(NSNumber *)taskNum {
    self.tasknum = tasknum;
}

- (NSString *)getEntity {
    return self.entity;
}

- (Item*) getCurrentitem {
    return self.currentitem;
}

- (NSMutableDictionary*) filterDictionnary:(NSDictionary *)result {

    NSArray * allfields =  [self.entityInfo getAllFields];
    NSMutableDictionary *newfields = [NSMutableDictionary dictionaryWithDictionary:result];
    
    for (NSString* key in [result allKeys]) {
        if([allfields containsObject:key]) continue;
        [ newfields removeObjectForKey:key];
    }
    
    return newfields;
}


- (NSString *)toString:(id) val{
    NSString *stringVal = [NSString stringWithFormat:@"%@",val];
    if([val isKindOfClass:[NSArray class]]){
        NSMutableString *content = [NSMutableString stringWithString:@""];
        for(NSString *innerval in val){
            [content appendString:[NSString stringWithFormat:@"%@,",innerval]];
        }
        stringVal = content;
        if(content.length > 1){
            stringVal = [content substringToIndex:content.length - 1];
        }
    }
    return stringVal;
}

- (NSString *)toInt:(int) val{
    return [NSString stringWithFormat:@"%d",val];
}

- (NSString *)toBoolValue:(BOOL)val{
    if(val) return @"true";
    return @"false";
}

- (BOOL)prepare {
    self.entityInfo = [InfoFactory getInfo:self.entity];
    NSLog(@"count field %d on entity %@",[[self.entityInfo getAllFields] count],self.entity );
    NSArray *arr = [self.entityInfo getAllFields];
    //not contain in meta data bypass
    if([arr count] < 1) return NO;
    return YES;
}

@end
