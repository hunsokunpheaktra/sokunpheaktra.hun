//
//  MyClass.m
//  testPluginStackOverflow
//
//  Created by Carlos Williams on 2/03/12.
//  Copyright (c) 2012 Devgeeks. All rights reserved.
//

#import "SyncCallPlugin.h"
#import "EntityManager.h"
#import "DetailLayoutSectionsInfoManager.h"
#import "FieldInfoManager.h"
#import "RecordTypeMappingInfoManager.h"
#import "EditLayoutSectionsInfoManager.h"
#import "PicklistForRecordTypeInfoManager.h"
#import "PicklistInfoManager.h"
#import "RelatedListsInfoManager.h"
#import "RelatedListColumnInfoManager.h"
#import "ChildRelationshipInfoManager.h"
#import "EntityInfoManager.h"
#import "RecordTypeMappingInfoManager.h"
#import "NotInCriteria.h"
#import "PropertyManager.h"
#import "NSData (MBBase64).h"
#import "Base64.h"
#import "Bitset.h"

@implementation SyncCallPlugin

@synthesize callbackID;


-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (SyncCallPlugin*)[super initWithWebView:theWebView];
    if (self) {
        
        originalWebViewBounds = theWebView.bounds;
        
    }
    
    return self;
}

- (void) openSynchronizeScreen:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    if(viewController){
        [viewController release];
        [navController release];
    }
    viewController = [[SynchronizeViewController alloc] init];
    viewController.parentView = self;
    navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.view.frame = originalWebViewBounds;
    navController.navigationBar.tintColor = [UIColor colorWithRed:(23.0/255.0) green:(155.0/255.0) blue:(192.0/255.0) alpha:1];
    self.webView.superview.autoresizesSubviews = YES;
    [self.webView.superview addSubview:navController.view];  
    [[self.webView.superview.subviews lastObject] setHidden:NO];
}

- (void) savePicture:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    NSString *imageUrl = [arguments objectAtIndex:1];
    NSString *parentId = [arguments objectAtIndex:2];
    NSString *attachmentName = [arguments objectAtIndex:3];
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    NSString *base64String = [Base64 encode:imageData];
    
    Item *item = [[Item alloc] init:@"Attachment" fields:[NSMutableDictionary dictionary]];
    [item.fields setValue:@"2" forKey:@"modified"];
    [item.fields setValue:@"0" forKey:@"deleted"];
    [item.fields setValue:@"0" forKey:@"error"];
    
    [item.fields setValue:base64String forKey:@"Body"];
    [item.fields setValue:parentId forKey:@"ParentId"];
    [item.fields setValue:attachmentName forKey:@"Name"];
    
    NSMutableDictionary *cri = [[NSMutableDictionary alloc] init];
    [cri setValue:[[ValuesCriteria alloc] initWithString:item.entity] forKey:@"entity"];
    NSArray *listInfo = [FieldInfoManager list:cri];
    [cri release];
    
    for (Item* field in listInfo) {
        if ([[field.fields valueForKey:@"type"] isEqualToString:@"boolean"]) {
            if (![[item.fields allKeys] containsObject:[field.fields valueForKey:@"name"]] || [[item.fields valueForKey:[field.fields valueForKey:@"name"]] isEqualToString:@"(null)"])
                
                [item.fields setValue:@"false" forKey:[field.fields valueForKey:@"name"]];   
        } 
        else if ([[field.fields valueForKey:@"type"] isEqualToString:@"double"] || [[field.fields valueForKey:@"type"] isEqualToString:@"int"]) {
            if (![[item.fields allKeys] containsObject:[field.fields valueForKey:@"name"]] || [[item.fields valueForKey:[field.fields valueForKey:@"name"]] isEqualToString:@"(null)"]) 
                
                [item.fields setValue:@"0" forKey:[field.fields valueForKey:@"name"]];
        }
        
    }

    [EntityManager insert:item modifiedLocally:YES];
    [item release];
}

- (void) clearData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    NSString *callBackMethod = [arguments objectAtIndex:1];
    
    [[DatabaseManager getInstance] reInitDB];
    
    [self writeJavascript:[NSString stringWithFormat:@"%@()",callBackMethod]];
    
}

- (void) updateEnvironment:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    NSString *environment = [arguments objectAtIndex:1];
    NSString *isSandbox = [environment isEqualToString:@"SandBox"] ? @"yes" : @"no";
    
    [PropertyManager save:@"SandBox" value:isSandbox];
    
}

- (void) getPropertyValue:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    NSString *propertyName = [arguments objectAtIndex:1];
    NSString *callBackMethod = [arguments objectAtIndex:2];
    NSString *value = [PropertyManager read:propertyName];
    
    [self writeJavascript:[NSString stringWithFormat:@"%@('%@','%@')",callBackMethod,propertyName,value]];
    
}

-(void)returnToParentView {
    [[self.webView.superview.subviews lastObject] setHidden:YES];
    [self writeJavascript:@"backToNative();"];
}

- (void)update:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    NSString *entity = [arguments objectAtIndex:1];
    
    Item *item = [[Item alloc] init:entity fields:options];
    if([item.fields valueForKey:@"modified"] == @"0"){
        [item.fields setValue:@"1" forKey:@"modified"];
    }
    [EntityManager update:item modifiedLocally:YES];
    [item release];
}

- (void)insert:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    NSString *entity = [arguments objectAtIndex:1];

    Item *item = [[Item alloc] init:entity fields:options];
    
    [item.fields setValue:@"2" forKey:@"modified"];
    [item.fields setValue:@"0" forKey:@"deleted"];
    [item.fields setValue:@"0" forKey:@"error"];
    
    NSMutableDictionary *cri = [[NSMutableDictionary alloc] init];
    [cri setValue:[[ValuesCriteria alloc] initWithString:entity] forKey:@"entity"];
    NSArray *listInfo = [FieldInfoManager list:cri];
    [cri release];
    
    for (Item* field in listInfo) {
        if ([[field.fields valueForKey:@"type"] isEqualToString:@"boolean"]) {
            if (![[item.fields allKeys] containsObject:[field.fields valueForKey:@"name"]] || [[item.fields valueForKey:[field.fields valueForKey:@"name"]] isEqualToString:@"(null)"])
                
                [item.fields setValue:@"false" forKey:[field.fields valueForKey:@"name"]];   
        } 
        else if ([[field.fields valueForKey:@"type"] isEqualToString:@"double"] || [[field.fields valueForKey:@"type"] isEqualToString:@"int"]) {
            if (![[item.fields allKeys] containsObject:[field.fields valueForKey:@"name"]] || [[item.fields valueForKey:[field.fields valueForKey:@"name"]] isEqualToString:@"(null)"]) 
                
                [item.fields setValue:@"0" forKey:[field.fields valueForKey:@"name"]];
        }
        
    }
    
    [EntityManager insert:item modifiedLocally:YES];
    [item release];
}

- (void) getRecordTypeWithEntity:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    NSString *entity = [arguments objectAtIndex:1];
    NSString *callBackMethod = [arguments objectAtIndex:2];
    
    NSMutableDictionary *criteria = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:entity] autorelease] forKey:@"entity"];
    [criteria setValue:[[[NotInCriteria alloc] initWithValue:@"012000000000000AAA"] autorelease] forKey:@"recordTypeId"];
    [criteria setValue:[[[NotInCriteria alloc] initWithValue:@"false"] autorelease] forKey:@"available"];
    
    NSArray *listRecordType = [RecordTypeMappingInfoManager list:criteria];
    [criteria release];
    
    NSString *result = @"[";
    
    for(Item *item in listRecordType){
        result = [result stringByAppendingFormat:@"%@,",[self mappingFieldWithValue:item]];
    }
    
    [listRecordType release];
    
    if ([[result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasSuffix:@","]) 
        result = [result substringToIndex:result.length-1];
    
    result = [result stringByAppendingString:@"]"];
    
    [self writeJavascript:[NSString stringWithFormat:@"%@('%@',%@)",callBackMethod,entity,result]];
    
}

- (void) getReference:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    NSString* parentEntity = [arguments objectAtIndex:1];
    NSString* reference = [arguments objectAtIndex:2];
    NSString* methodeName = [arguments objectAtIndex:3];

    NSArray *listItem = [EntityManager list:reference criterias:nil];

    NSString* js = [self getArrayFromitem:listItem javascriptMethode:methodeName indexSelected:-2];
    js = [js substringToIndex:js.length-1];
    
    [listItem release];
    
    NSString*tm = [NSString stringWithFormat:@"'%@','%@','reference' )",parentEntity,reference];

    [self writeJavascript:[NSString stringWithFormat:@"%@,%@",js,tm]];
    
}

//entityName,fieldName,"getPickListAndReference",recordTypeId
- (void) getPickList:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
        
    NSString* entityName = [NSString stringWithString:[arguments objectAtIndex:1]];
    NSString* fieldName = [arguments objectAtIndex:2];
    NSString* methodeName = [arguments objectAtIndex:3];
    NSString* recordTypeId = [arguments objectAtIndex:4];
    
    NSMutableDictionary *cri = [[NSMutableDictionary alloc] initWithCapacity:1];
    [cri setValue:[[ValuesCriteria alloc] initWithString:entityName] forKey:@"entity"];
    [cri setValue:[[ValuesCriteria alloc] initWithString:fieldName] forKey:@"picklistName"];
    [cri setValue:[[ValuesCriteria alloc] initWithString:recordTypeId] forKey:@"recordTypeId"];
    
    NSArray* pickList = [PicklistForRecordTypeInfoManager list:cri];
    NSString* js = [self getArrayFromitem:pickList javascriptMethode:methodeName indexSelected:-2];
    js = [js substringToIndex:js.length-1];
    
    [pickList release];
    [cri release];
    
    NSString*tm = [NSString stringWithFormat:@"'%@','%@','picklist' )",entityName,fieldName];
    
    [self writeJavascript:[NSString stringWithFormat:@"%@,%@",js,tm]];
}



- (void) getRelatedListColumnInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    NSString* entityName = [arguments objectAtIndex:1];
    NSString* methodeName= [arguments objectAtIndex:2];
    
    NSMutableDictionary *criteria = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criteria setValue:[[ValuesCriteria alloc] initWithString:entityName] forKey:@"entity"];
    NSArray* relatedList = [RelatedListsInfoManager list:criteria];
    
    NSMutableArray* availAbaleRelatedListName = [[NSMutableArray alloc] init];
    NSMutableArray* listAvailableRelatedList = [[NSMutableArray alloc] init];
    
    for(Item *item in relatedList){
        NSString *table = [item.fields objectForKey:@"sobject"];
        NSMutableDictionary *checkLayout = [[NSMutableDictionary alloc] initWithCapacity:1];
        [checkLayout setValue:[ValuesCriteria criteriaWithString:table] forKey:@"entity"];
        NSArray *listLayout = [EditLayoutSectionsInfoManager list:checkLayout];
        
        if ([listLayout count]>0) {
            if ([[item.fields objectForKey:@"field"] length] > 0) {
                [availAbaleRelatedListName addObject:table];
                [listAvailableRelatedList addObject:item];
            }    
        }
        
        [listLayout release];
        [checkLayout release];
        
    }
    
    [relatedList release];
    
    NSString *arrRelatedListInfo = @"[";
    for(Item *item in listAvailableRelatedList){
        arrRelatedListInfo = [arrRelatedListInfo stringByAppendingFormat:@"%@,",[self mappingFieldWithValue:item]];
    }
    
    [listAvailableRelatedList release];
    
    if ([[arrRelatedListInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasSuffix:@","]) 
        arrRelatedListInfo = [arrRelatedListInfo substringToIndex:arrRelatedListInfo.length-1];
    
    arrRelatedListInfo = [arrRelatedListInfo stringByAppendingString:@"]"];
    
    NSMutableArray* listColumnIfo = [[NSMutableArray alloc] init];
    for (NSString* name in availAbaleRelatedListName) {
        [criteria removeAllObjects];
        [criteria setValue:[[ValuesCriteria alloc] initWithString:entityName] forKey:@"entity"];
        [criteria setValue:[[ValuesCriteria alloc] initWithString:name] forKey:@"sobject"];
        [listColumnIfo addObjectsFromArray:[RelatedListColumnInfoManager list:criteria]];
    }
    
    [availAbaleRelatedListName release];
    
    NSString* js = [self getArrayFromitem:listColumnIfo javascriptMethode:methodeName indexSelected:-2];
    js = [js substringToIndex:js.length-1];
    
    [listColumnIfo release];
    
    NSString*tm = [NSString stringWithFormat:@"'%@' )",entityName];
    [criteria release];
    [self writeJavascript:[NSString stringWithFormat:@"%@,%@,%@",js,arrRelatedListInfo,tm]];
    
}    


- (void) getRelatedListData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* parentId =[arguments objectAtIndex:1];
    NSString* parentName = [arguments objectAtIndex:2];
    NSString* childName = [arguments objectAtIndex:3];
    NSString* methodeName = [arguments objectAtIndex:4];
    
    NSMutableDictionary *criteria = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criteria setValue:[[ValuesCriteria alloc] initWithString:parentName] forKey:@"entity"];
    [criteria setValue:[[ValuesCriteria alloc] initWithString:childName] forKey:@"childSObject"];
    
    Item* item = [ChildRelationshipInfoManager find:criteria];
    [criteria removeAllObjects];
    [criteria setValue:[[ValuesCriteria alloc] initWithString:parentId] forKey:[item.fields objectForKey:@"field"]];
    NSArray* listRelatedListData = [EntityManager list:childName criterias:criteria];
    
    NSString* js = [self getArrayFromitem:listRelatedListData javascriptMethode:methodeName indexSelected:-2];
    js = [js substringToIndex:js.length-1];
    
    [listRelatedListData release];
    
    NSString*tm = [NSString stringWithFormat:@"'%@','%@','%@' )",childName,parentName,parentId]; 
    
    [criteria release];
    [item release];
    [self writeJavascript:[NSString stringWithFormat:@"%@,%@",js,tm]];
    
}

- (void) getChildRelationShipInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    NSString *parent = [arguments objectAtIndex:1];
    NSString *child = [arguments objectAtIndex:2];
    NSString *callBackMethod = [arguments objectAtIndex:3];
    
    NSMutableDictionary *criteria = [[NSMutableDictionary alloc] initWithCapacity:1];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:parent] autorelease] forKey:@"entity"];
    [criteria setValue:[[[ValuesCriteria alloc] initWithString:child] autorelease] forKey:@"sobject"];
    
    Item *item = [RelatedListsInfoManager find:criteria];
    [criteria release];
    
    NSString *result = @"";
    
    result = [result stringByAppendingString:[self mappingFieldWithValue:item]];
    [item release];
    
    [self writeJavascript:[NSString stringWithFormat:@"%@('%@','%@',%@)",callBackMethod,parent,child,result]];
    
}

-(void) getFieldInfo :(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    NSString* entityName = [arguments objectAtIndex:1];
    NSString* methodeName = [arguments objectAtIndex:2];
    
    NSMutableDictionary *cri = [[NSMutableDictionary alloc] initWithCapacity:1];
    [cri setValue:[[ValuesCriteria alloc] initWithString:entityName] forKey:@"entity"];
    NSArray* fieldInfos = [FieldInfoManager list:cri];
    
    NSString* js = [self getArrayFromitem:fieldInfos javascriptMethode:methodeName indexSelected:-2];
    
    [cri release];
    [fieldInfos release];
    [self writeJavascript:js];
}  

- (void) mapCascadingPicklist:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    NSString* entityName = [arguments objectAtIndex:1];
    NSString* methodeName = [arguments objectAtIndex:2];
    
    NSMutableDictionary *cri = [[NSMutableDictionary alloc] initWithCapacity:1];
    [cri setValue:[[ValuesCriteria alloc] initWithString:entityName] forKey:@"entity"];
    NSArray* fieldInfos = [FieldInfoManager list:cri];

    
    for (Item*itemInfo in fieldInfos)
    {
        NSString* controllerName = [itemInfo.fields valueForKey:@"controllerName"];
        NSString* type = [itemInfo.fields valueForKey:@"type"];
        NSMutableDictionary* mapValPicklists = [[NSMutableDictionary alloc] init];
       
          if ([type isEqualToString:@"picklist"] && controllerName != nil && controllerName.length >0) 
          {
                [cri removeAllObjects];
                [cri setValue:[[ValuesCriteria alloc] initWithString:entityName] forKey:@"entity"];
                [cri setValue:[[ValuesCriteria alloc] initWithString:[itemInfo.fields valueForKey:@"name"]] forKey:@"fieldName"];
                [cri setValue:[[ValuesCriteria alloc] initWithString:controllerName] forKey:@"controllerName"];
                NSArray* listPicklistInfo = [PicklistInfoManager list:cri];
                
                [cri removeAllObjects];
                [cri setValue:[[ValuesCriteria alloc] initWithString:entityName] forKey:@"entity"];
                [cri setValue:[[ValuesCriteria alloc] initWithString:controllerName] forKey:@"fieldName"];
                NSArray* controllerPicklist = [PicklistInfoManager list:cri];
                
                if ([listPicklistInfo count] > 0) 
                {
                    
                    for (Item* itemPicklist in listPicklistInfo) 
                    {
                        
                        NSString* dataString = [itemPicklist.fields valueForKey:@"validFor"];
                        const char *utfString = [dataString UTF8String];
                        NSMutableData* data =  [ NSMutableData dataWithData:[Base64 decode:utfString length:strlen(utfString)]] ; //[NSMutableData dataWithBytes:utfString length:strlen(utfString)]; 
                        
                        unsigned char *aBuffer;
                        unsigned len;
                        
                        len = [data length];
                        aBuffer = malloc(len);
                        
                        [data getBytes:aBuffer];
                        
                        Bitset* validFor =  [[Bitset alloc] init:aBuffer] ;
                    
                        for (int k = 0; k < validFor.size; k++) 
                        {
                            if ([validFor testBit:k]) {
                                
                                //NSLog(@"----> %d",k);
                            
                                NSString* controllerVal =  [[[controllerPicklist objectAtIndex:k] fields] valueForKey:@"label"];
                                NSString* picklistVal   = [itemPicklist.fields valueForKey:@"label"];
                                
                                if (![[mapValPicklists allKeys] containsObject:controllerVal]) 
                                {
                                    [mapValPicklists setValue:[NSMutableArray arrayWithObjects:picklistVal, nil] forKey:controllerVal];
                                }
                                else 
                                {
                                    [[mapValPicklists valueForKey:controllerVal] addObject:picklistVal];
                                }
                                
                            }  
                            
                        }
                        
                        
                        free(aBuffer);
                                   
                    }
                    
                }    
              
              NSString* key = [NSString stringWithFormat:@"%@%@%@",entityName,[itemInfo.fields valueForKey:@"name"],controllerName];
              NSString* lsConVal = [self getStringFromListData:[mapValPicklists allKeys]]; 
              NSMutableString* conValStList = [[NSMutableString alloc] init];
              [conValStList appendString:@"{"];
              for (NSString*conVal in [mapValPicklists allKeys]) {
                  NSString* stList = [self getStringFromListData:[mapValPicklists valueForKey:conVal]]; 
                  NSString* tmVal = [NSString stringWithFormat:@"'%@':%@,",conVal,stList];
                  [conValStList appendString:tmVal];
              }
              
             
              if ([[conValStList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasSuffix:@","]) 
              [conValStList replaceCharactersInRange: NSMakeRange([conValStList length]-1, 1) withString: @""];
              [conValStList appendString:@"}"];
              
              NSString* result = [NSString stringWithFormat:@"%@(%@,%@,'%@')",methodeName,lsConVal,conValStList,key]; 
              
              [self writeJavascript:result];

          }
        
     }
    

} 


- (void) getEntityInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    NSString* entityName = [arguments objectAtIndex:1];
    NSString* callBackMethod = [arguments objectAtIndex:2];
    
    NSMutableDictionary *cri = [[NSMutableDictionary alloc] initWithCapacity:1];
    [cri setValue:[[ValuesCriteria alloc] initWithString:entityName] forKey:@"name"];
    
    Item *item = [EntityInfoManager find:cri];
    [cri release];
    
    NSString *result = [self mappingFieldWithValue:item];
    [item release];

    [self writeJavascript:[NSString stringWithFormat:@"%@('%@',%@);",callBackMethod,entityName,result]];
    
}

- (void) getLayout:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    
    NSString* entityName = [arguments objectAtIndex:1];
    NSString* recordTypeId = [arguments objectAtIndex:2];
    NSString* methodename = [arguments objectAtIndex:3]; 
    NSString* layoutName = [arguments objectAtIndex:4]; 
    int index = [[arguments objectAtIndex:5] intValue];
    
    Item* tmpLayoutId;
    
    NSMutableDictionary *cri = [[NSMutableDictionary alloc] initWithCapacity:1];
    if ([recordTypeId length] == 0 || recordTypeId == nil) {
        recordTypeId = @"012000000000000AAA";
        [cri setValue:[[[ValuesCriteria alloc] initWithString:@"012000000000000AAA"] autorelease] forKey:@"RecordTypeId"];
        [cri setValue:[[[ValuesCriteria alloc] initWithString:@"Master"] autorelease] forKey:@"name"];
        [cri setValue:[[[ValuesCriteria alloc] initWithString:entityName] autorelease] forKey:@"entity"];
        tmpLayoutId = [RecordTypeMappingInfoManager find:cri];
        
    }else {
        [cri setValue:[[[ValuesCriteria alloc] initWithString:recordTypeId] autorelease] forKey:@"RecordTypeId"];
        [cri setValue:[[[ValuesCriteria alloc] initWithString:entityName] autorelease] forKey:@"entity"];
        tmpLayoutId = [RecordTypeMappingInfoManager find:cri];
    }
    
    // Find List edit layout item
    [cri removeAllObjects];
    [cri setValue:[ValuesCriteria criteriaWithString:entityName] forKey:@"entity"];

    if(tmpLayoutId)
        [cri setValue:[ValuesCriteria criteriaWithString:[tmpLayoutId.fields objectForKey:@"layoutId"]] forKey:@"Id"];
    
    NSArray *listLayout = [layoutName isEqualToString:@"detail"] ? [DetailLayoutSectionsInfoManager list:cri] : [EditLayoutSectionsInfoManager list:cri];
    
    NSString* js = [self getArrayFromitem:listLayout javascriptMethode:methodename indexSelected:index];
    
    js = [js substringToIndex:js.length-1];
    
    [cri release];
    [tmpLayoutId release];
    [listLayout release];
    
    NSString*tm = [NSString stringWithFormat:@"'%@'",recordTypeId];
    
    [self writeJavascript:[NSString stringWithFormat:@"%@,%@ )",js,tm]];
    
}

-(NSString*) getArrayFromitem:(NSArray*)listItem javascriptMethode:(NSString*)methodeName indexSelected:(int)index{
    

    NSMutableString* js = [[NSMutableString alloc] init];
    
    [js appendString:methodeName];
    [js appendString:@" ( ["];
    
    for (Item*item in listItem) {
        [js appendString:@"{"];
        
        for (NSString*fieldName in item.fields) {
            NSString* value = [[item.fields objectForKey:fieldName] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\r"];
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            
            [js appendString:@"'"];
            [js appendString:fieldName];
            [js appendString:@"':'"];
            [js appendString:value];
            [js appendString:@"',"];
        }
        
        if ([[js stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasSuffix:@","]) 
            [js replaceCharactersInRange: NSMakeRange([js length]-1, 1) withString: @""];
        
        [js appendString:@"} ,"];
        
    }
    
    
    if ([[js stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasSuffix:@","]) 
        [js replaceCharactersInRange: NSMakeRange([js length]-1, 1) withString: @""];
    [js appendString:@" ]"];
    
    if (index>=-1) {
        [js appendString:@","];
        [js appendString:[NSString stringWithFormat:@"%d",index]];
    }

    [js appendString:@" )"];    
    
    return js;
    
}


-(NSString*) getStringFromListData : (NSArray*) listData {

    NSString *str = @"[";
    
    for (NSString* st in listData) {
        NSString* value = [st stringByReplacingOccurrencesOfString:@"\n" withString:@"\\r"];
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        
        str = [str stringByAppendingFormat:@"'%@',",value];
    }
    
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasSuffix:@","]) 
    str = [str substringToIndex:str.length-1];
    str = [str stringByAppendingString:@"]"];
    
    return str;
}

- (NSString*)mappingFieldWithValue:(Item*)item{
    
    NSString *str = @"{";
    
    for(NSString *key in item.fields.allKeys){

        NSString* value = [[item.fields valueForKey:key] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\r"];
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];

        str = [str stringByAppendingFormat:@"'%@':'%@',",key,value];
    }
    
    str = [str substringToIndex:str.length-1];
    str = [str stringByAppendingString:@"}"];
    return str;
}

- (void) initData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    NSString *entity = [arguments objectAtIndex:1];
    NSString *callBackMethod = [arguments objectAtIndex:2];
    NSArray *listItem = [EntityManager list:entity criterias:nil];
    
    NSString *result = @"[";
    for(Item *item in listItem){
        result = [result stringByAppendingFormat:@"%@,",[self mappingFieldWithValue:item]];
    }
    if(listItem.count > 0) result = [result substringToIndex:result.length-1];
    [listItem release];
    result = [result stringByAppendingString:@"]"];
    
    [super writeJavascript:[NSString stringWithFormat:@"%@('%@',%@);",callBackMethod,entity,result]];

}

- (void) findRecord:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    NSString *entity = [arguments objectAtIndex:1];
    NSString *callBackMethod = [arguments objectAtIndex:2];
    NSString *rId = [arguments objectAtIndex:3];
    
    Item *item = [EntityManager find:entity column:@"Id" value:rId];
    NSString *result = [self mappingFieldWithValue:item];
    [item release];
    [self writeJavascript:[NSString stringWithFormat:@"%@('%@',%@);",callBackMethod,entity,result]];
}

@end
