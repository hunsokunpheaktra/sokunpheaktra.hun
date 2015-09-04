//
//  SfMergeRecords.m
//  SyncForce
//
//  Created by Gaeasys on 12/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//

#import "EntityRequest.h"
#import "InfoFactory.h"
#import "EntityManager.h"
#import "PropertyManager.h"
#import "DirectoryHelper.h"
#import "ZKSObject.h"
#import "TransactionInfoManager.h"
#import "MergeRecordPopover.h"
#import "SynchronizeViewController.h"
#import "SfMergeRecords.h"
#import "DatetimeHelper.h"
#import "Section.h"
#import "EditLayoutSectionsInfoManager.h"
#import "NumberHelper.h"
#import "FilterObjectManager.h"
#import "NotInCriteria.h"
#import "LessThanCriteria.h"
#import "GreaterThanCriteria.h"
#import "LessThanOrEqualCriteria.h"
#import "GreaterThanOrEqualCriteria.h"
#import "FilterManager.h"

@implementation SfMergeRecords

@synthesize listLocalRecords,array;
@synthesize synprocess;

- (id)initWithSynProcess:(NSString *)newEntity listener:(SyncProcess*) newListener {
    self.entity = newEntity;
    self.synprocess = newListener;
    self.listener = newListener;
    array = [[NSMutableArray alloc] init];
    return self;
}

- (NSString*) getQueryContents{
    // read the selected Entity Info
    
  
    NSArray * allfields =  [self.entityInfo getAllFields];
    
    NSMutableString* querystring =[[NSMutableString alloc]initWithCapacity:10];	
    
	// construct the query dynamically
    [querystring appendString: @"Select "];
    for(int i = 0 ; i < allfields.count; i++){
        if(i > 0) [querystring appendString: @", "];
        [querystring appendString: [allfields objectAtIndex:i]];
    }
    [querystring appendString: @" From "];
    [querystring appendString: self.entity];
    
    if ([listLocalRecords count] > 0) {
        [querystring appendString: @" Where ( Id in ("];
    
        for (Item* item in listLocalRecords) {
        
            [querystring appendString: @"'"];
            [querystring appendString: [item.fields objectForKey:@"Id"]];
            [querystring appendString: @"'"];
        
            if (item != [listLocalRecords lastObject]) {
                [querystring appendString: @","];
            }
        }

        [querystring appendString: @")"];
      } 
    
    if ([listLocalRecords count]>0) 
        [querystring appendString:@" ) "];

    
    if(self.dateFilter != nil && ![self.dateFilter isEqualToString:@""]){
                
        if([querystring rangeOfString:@"Where"].length>0) [querystring appendString:@" Or "];
        else [querystring appendString:@" Where "];
       
        if(self.dateFilter != nil && ![self.dateFilter isEqualToString:@""]){
            if([self.entity isEqualToString:@"ContentWorkspaceDoc"]){
                [querystring appendString:@" ContentDocument.LastModifiedDate = "];
                [querystring appendString:self.dateFilter];
            }else{
                Item *item = [FilterManager find:entity];
                NSString *lastSyn = [item.fields valueForKey:@"lastSyn"];
                if(lastSyn || item == nil){
                    [querystring appendString:@" LastModifiedDate >= "];
                    [querystring appendString:self.dateFilter];
                }
            }
        }
    }
    

    return querystring;
}


- (void)doRequest {    
    // loop on all fields and build the query
    self.dateFilter = [TransactionInfoManager readLastSyncDate:[NSString stringWithFormat:@"%@ Incoming", self.entity]];
    NSString *queryString =  [NSString stringWithFormat:@"%@",[self getQueryContents]];
    [[FDCServerSwitchboard switchboard] query:queryString target:self selector:@selector(queryResult:error:context:) context:nil];
     
}

- (void)queryResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
   
    NSLog(@"INcoming %@", result);
    NSLog(@"INcoming %@", error);
    
    if (result != nil && error == nil)
    {
        NSLog(@"queryResult:%@ eror:%@ context:%@", result, error, context);
        NSMutableArray *allDetails = [NSMutableArray arrayWithArray:[result records]];

        if ([allDetails count] > 0) {
            NSString *userId = nil;
            if ([self.entity isEqualToString:@"User"]) {
                userId = [PropertyManager read:@"CurrentUserId"];
            }      
        
            for(int i = 0 ; i < allDetails.count ; i++ ){
                ZKSObject* sobject = [allDetails objectAtIndex:i];
                [[sobject fields] setValue:@"0" forKey:@"error"];
                [[sobject fields] setValue:@"0" forKey:@"deleted"];
            
                Item *item = [[Item alloc] initCustom:self.entity fields:[NSDictionary dictionaryWithDictionary:[sobject fields]]];
                [array addObject:item];
            }
        }
        
    }
    if (error != nil)
    {
        NSLog(@"Eorr: %@",error);
        [self didFailLoadWithError:[NSString stringWithFormat:@"%@", error]];
    } 
    
    
    
    NSMutableArray* recordsDiff = [[NSMutableArray alloc] init];
    NSMutableArray *sfRecords = [[NSMutableArray alloc] init];
    
    NSMutableArray* tmpLocalList = nil;
    NSMutableArray* tmpSfList = nil;
    
    NSMutableArray* tmpOriginalLocalList = [[NSMutableArray alloc] init];
    NSMutableArray* tmpOriginalRemoteList = [[NSMutableArray alloc] init];
    
    if ([array count]>0) {
        
        // Order data 
        for (Item* itemLocal in listLocalRecords) {
            for (Item* itemSf in array) {
                if ([[itemLocal.fields objectForKey:@"Id"] isEqualToString:[itemSf.fields objectForKey:@"Id"]]) {
                    [tmpOriginalLocalList addObject:itemLocal];
                    [tmpOriginalRemoteList addObject:itemSf];
                }    
            }   
        }
        
        // Find data modified in saleforce
        NSMutableArray* localArr = [[NSMutableArray alloc] init];
        for (Item* itemLocal in listLocalRecords) {
            [localArr addObject:[itemLocal.fields objectForKey:@"Id"]];
        }   
        
        for (Item* itemSf in array) {
            if (![localArr containsObject:[itemSf.fields objectForKey:@"Id"]]) {
                NSMutableDictionary *localCriteria = [[NSMutableDictionary alloc] init];
                [localCriteria setValue:[[[ValuesCriteria alloc] initWithString:[itemSf.fields objectForKey:@"Id"]] autorelease] forKey:@"Id"];
                
                if ([[EntityManager list:entity criterias:localCriteria] count] >0) {
                    [tmpOriginalLocalList addObject:[[EntityManager list:entity criterias:localCriteria] objectAtIndex:0]];
                    [tmpOriginalRemoteList addObject:itemSf];
                }    
            }
        }
        
        [localArr release];
        
       // Find recorod need to be merger
        for (int x = 0; x < [tmpOriginalRemoteList count]; x++) {
            if ([[[[tmpOriginalLocalList objectAtIndex:x] fields] objectForKey:@"modified"] intValue] == 1) {
            
                NSString* remoteDateModifed = [[[tmpOriginalRemoteList objectAtIndex:x] fields] objectForKey:@"LastModifiedDate"];
            
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"YYY-MM-dd'T'HH:mm:ss.SSS'Z'"];
                NSDate *lastSyncDate = [dateFormat dateFromString:[TransactionInfoManager readLastSyncDate:[NSString stringWithFormat:@"%@ Incoming", self.entity]]]; 
                NSDate *dateSf = [dateFormat dateFromString:remoteDateModifed];
            
                if ([lastSyncDate compare:dateSf] == NSOrderedAscending) 
                {
                    [recordsDiff addObject:[tmpOriginalLocalList objectAtIndex:x]];
                    [sfRecords addObject:[tmpOriginalRemoteList objectAtIndex:x]];
                }
                
            }else {
             
                if (![[[[tmpOriginalLocalList objectAtIndex:x] fields] objectForKey:@"LastModifiedById"] isEqualToString:[[[tmpOriginalRemoteList objectAtIndex:x] fields] objectForKey:@"LastModifiedById"]]) 
                {
                    [recordsDiff addObject:[tmpOriginalLocalList objectAtIndex:x]];
                    [sfRecords addObject:[tmpOriginalRemoteList objectAtIndex:x]];
                }
            
            }
        }
        
        
        
        tmpLocalList = [[NSMutableArray alloc] init];
        tmpSfList    = [[NSMutableArray alloc] init];
        
        
        // check if records need to be merged have different data
        for (int x =0; x< [recordsDiff count]; x++) {
            
            Item* tmpLocaItem = [recordsDiff objectAtIndex:x]; 
            Item* tmpSfitem   = [sfRecords objectAtIndex:x];  
            
            //Group items(Field) by heading
            NSMutableArray* sectionNameOrder = [[NSMutableArray alloc] initWithCapacity:1];
            NSMutableDictionary* mapSections = [[NSMutableDictionary alloc] initWithCapacity:1];
            NSMutableDictionary* filters = [[NSMutableDictionary alloc] initWithCapacity:1];
            
            [filters setValue:[ValuesCriteria criteriaWithString:entity] forKey:@"entity"];
            for(Item *item in [EditLayoutSectionsInfoManager list:filters]){
                NSString *heading = [item.fields valueForKey:@"heading"];
                if(![mapSections.allKeys containsObject:heading]){
                    [sectionNameOrder addObject:heading];
                    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1];
                    [mapSections setValue:items forKey:heading];
                }
                [[mapSections objectForKey:heading] addObject:item];
            }
            
            NSMutableArray *detailSections = [[NSMutableArray alloc] initWithCapacity:1];
            for(NSString *heading in sectionNameOrder){
                Section *section = [[Section alloc] initWithName:heading];
                for(Item *item in [mapSections valueForKey:heading]){
                    NSString *fieldname = [item.fields valueForKey:@"value"];
                    if ([[[tmpLocaItem fields] allKeys] containsObject:fieldname]) {
                         if ([[tmpSfitem fields] objectForKey:fieldname] !=(id)kCFNull || [[[tmpLocaItem fields] objectForKey:fieldname] length] >0) { 
                             
                             NSString* valueSf = [[tmpSfitem fields] objectForKey:fieldname];
                             NSString* valueLocal  = [[tmpLocaItem fields] objectForKey:fieldname];
                             Item *info = [entityInfo getFieldInfoByName:fieldname];
                             NSString *fieldType = [info.fields objectForKey:@"type"];
                             
                             if ([fieldType isEqualToString:@"currency"]) {
                                 if ([[[sfRecords objectAtIndex:x] fields] objectForKey:fieldname] !=(id)kCFNull) { 
                                     valueSf = [NumberHelper formatCurrencyValue:[valueSf doubleValue]];
                                 }   
                                 valueLocal  = [NumberHelper formatCurrencyValue:[valueLocal doubleValue]];
                             }
                             
                             if ([fieldType isEqualToString:@"double"]) {
                                 if (valueSf != (id)kCFNull) {
                                     valueSf = [NumberHelper formatNumberDisplay:[valueSf doubleValue]];
                                 }else valueSf = @"" ;
                                 
                                 valueLocal = [NumberHelper formatNumberDisplay:[valueLocal doubleValue]];
                             }
                             
                             if ([fieldType isEqualToString:@"percent"]) {
                                 if (valueSf != (id)kCFNull) {
                                     valueSf = [NumberHelper formatPercentValue:[valueSf doubleValue]];
                                 }else valueSf = @"" ;
                                 
                                 valueLocal = [NumberHelper formatPercentValue:[valueLocal doubleValue]];
                             }

                         
                             if (![valueLocal isEqualToString:valueSf]) {
                                [section.fields addObject:fieldname];
                             }    
                         }   
                        
                    }
                    
                }
                
                if ([section.fields count]>0) {
                    [detailSections addObject:section];
                }
                
            }
            
            if ([detailSections count] > 0) {
                [tmpLocalList addObject:tmpLocaItem];
                [tmpSfList addObject:tmpSfitem];
            }

        }
        
    }
    
    
   if ( (tmpLocalList != nil && [tmpLocalList count] != 0) ||[tmpLocalList count] > 0) {
          [synprocess stop];
       MainMergeRecord* mergeScreen = [[MainMergeRecord alloc] initWithEntity:entity listlocalrecords:recordsDiff listSfRecords:sfRecords merge:self];
            
       [((SynchronizeViewController*)synprocess.syncCon) mergeViewOpen:mergeScreen];
   }else  {
       [self.listener onSuccess:0 request:self again:false];
   }
   
}


-(void) continueProcess {
     synprocess.cancelled = 0 ;
    [self.listener onSuccess:0 request:self again:false];
}

- (void)didFailLoadWithError:(NSString*)error{
    [self.currentitem.fields setObject:@"1" forKey:@"error"];
    if(currentitem.entity != nil) [EntityManager update:self.currentitem modifiedLocally:false];
    
   // [self.listener onFailure:[NSString stringWithFormat:@"Salesforce Error %@", error] request:self again:false];
}

- (NSString *)getName {
    return [NSString stringWithFormat:@"%@ Merging check", self.entity];
}

- (BOOL)prepare {
    self.entityInfo = [InfoFactory getInfo:self.entity];
    NSMutableDictionary *localCriteria = [[NSMutableDictionary alloc] init];
    [localCriteria setValue:[[[ValuesCriteria alloc] initWithString:@"1"] autorelease] forKey:@"modified"];
    //[localCriteria setValue:[[NotInCriteria alloc] initWithValue:@"2"] forKey:@"modified"] ;
    //[localCriteria setValue:[[[ValuesCriteria alloc] initWithString:@"0"] autorelease] forKey:@"modified"];
    
    self.listLocalRecords = [EntityManager list:entity criterias:localCriteria];
    
    //not contain in meta data bypass
   // if([listLocalRecords count] < 1) return NO;
 
    return YES;
}

@end
