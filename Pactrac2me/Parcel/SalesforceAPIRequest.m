//
//  SalesforceAPIRequest.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 12/5/12.
//  Copyright (c) 2012 Davin Pen. All rights reserved.
//

#import "SalesforceAPIRequest.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "Base64.h"
#import "AttachmentEntitymanager.h"

@implementation SalesforceAPIRequest

-(id)init{
    self.webData = [[NSMutableData alloc] init];
    return self;
}

-(void)doRequest:(NSObject<SyncListener> *)listen{
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.status = [NSNumber numberWithInt:((NSHTTPURLResponse *)response).statusCode];
	[self.webData setLength: 0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)nsError {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.synListener onFailure:[nsError description] request:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    // Success
    NSString *jsonString =[[NSString alloc] initWithData:self.webData encoding:NSUTF8StringEncoding];
    NSLog(@"Response String : %@ status:%@",jsonString,self.status);
    NSLog(@"Process Name : %@",[self getProccessName]);
    
    SBJSON *parser = [[SBJSON alloc] init];
    // parse the JSON string into an object - assuming json_string is a NSString of JSON data
    NSMutableDictionary *responseData = [parser objectWithString:jsonString error:nil];
    [jsonString release];
    [parser release];
    
    if(responseData == nil){
        responseData = [NSMutableDictionary dictionary];
    }
    if([responseData isKindOfClass:[NSArray class]]){
        responseData = [(NSArray*)responseData objectAtIndex:0];
    }else if([responseData isKindOfClass:[NSDictionary class]]){
        responseData = responseData;
    }
    
    if ([self.status intValue] == 200 || [self.status intValue] == 201 || [self.status intValue] == 204) {
        
        if ([[self getProccessName] isEqualToString:@"Upsert Attachment"]) {
    
            [self.item.fields setObject:@"0" forKey:@"modified"];
            if([responseData.allKeys containsObject:@"id"]){
                [self.item.fields setObject:[responseData objectForKey:@"id"] forKey:@"Id"];
            }
            [AttachmentEntitymanager update:self.item modifiedLocally:NO];
            [self.synListener onSuccess:self];
            
        }
        
        if ([[self getProccessName] isEqualToString:@"Get Attachment Body"]) {
         
            NSString *b64img =  [Base64 encode:self.webData];
            [self.item.fields setObject:b64img forKey:@"body"];
            Item *existing = [AttachmentEntitymanager find:@"Attachment" column:@"Id" value:[self.item.fields objectForKey:@"Id"]];
            
            if (existing!=nil){
                [self.item.fields setObject:[existing.fields objectForKey:@"local_id"] forKey:@"local_id"];
                [AttachmentEntitymanager update:self.item modifiedLocally:NO];
            }else[AttachmentEntitymanager insert:self.item modifiedLocally:NO];
            [self.synListener onSuccess:self];
            
        }

         // login parsing
         if ([[self getProccessName] isEqualToString:@"Login"]) {
             if([responseData.allKeys containsObject:@"error"]){
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[responseData objectForKey:@"error"] message:[responseData objectForKey:@"error_description"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alertView show];
                 [alertView release];
             }else{
                 [[NSUserDefaults standardUserDefaults] setObject:[responseData objectForKey:@"access_token"] forKey:@"access_token"];
                 [[NSUserDefaults standardUserDefaults] setObject:[responseData objectForKey:@"instance_url"] forKey:@"instance_url"];
                 [self.synListener onSuccess:self];
             }
         //query record parsing
         }else if([[self getProccessName] isEqualToString:@"Query"]){
             
             self.records = [responseData objectForKey:@"records"];
             [self.synListener onSuccess:self];
             
         }else if([[self getProccessName] isEqualToString:@"Insert"]){
             
             if ([responseData objectForKey:@"id"] != nil)
                [self.item.fields setObject:[responseData objectForKey:@"id"] forKey:@"id"];
             
             [self.synListener onSuccess:self];
             
         } else if ([[self getProccessName] isEqualToString:@"Delete"]) {
            
             self.records = [responseData objectForKey:@"records"];
             [self.synListener onSuccess:self];
         
         } else if([[self getProccessName] isEqualToString:@"Download"]){
             self.downloadImage = [UIImage imageWithData:self.webData];
         }else if([[self getProccessName] isEqualToString:@"CallSFMethod"]){
             [self.synListener onSuccess:self];
         }
        
     }else{
         
         NSString *errorMessage = @"";
         if([responseData.allKeys containsObject:@"errorCode"]){
             errorMessage = [responseData objectForKey:@"errorCode"];
         }
         if([responseData.allKeys containsObject:@"error_description"]){
             errorMessage = [responseData objectForKey:@"error_description"];
         }
         [self.synListener onFailure:errorMessage request:self];
     }

}
-(NSString *)getProccessName{
    return nil;
}

-(NSString *)getMethod{
    return @"GET";
}

-(void)dealloc{
    [super dealloc];
}

@end
