//
//  UpsertAttachmentRequest.m
//  Pactrac2me
//
//  Created by Sy Pauv on 1/24/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "UpsertAttachmentRequest.h"
#import "JSON.h"

@implementation UpsertAttachmentRequest

-(id)initWithItem:(Item *)item{
    self=[super init];
    if (self) {
        self.item = item;
        self.sobject=@"Attachment";
    }
    return self;
}

-(void)doRequest:(NSObject<SyncListener> *)listen{
    
    self.synListener=listen;
    NSString *requestBody = @"";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *baseUrl=@"";
    NSString *Id = [self.item.fields objectForKey:@"Id"];
    Id = Id == nil ? @"" : Id;
    
    if ([Id isEqualToString:@""] && ((NSString *)[self.item.fields objectForKey:@"Id"]).length < 15) {
        //if Record id == nil do insert else do update method
         baseUrl = [NSString stringWithFormat:@"%@%@%@/", [[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"], URL_SERVICE,self.sobject];
        [dic setObject:[NSString stringWithFormat:@"%@.jpg",[self.item.fields objectForKey:@"Description"]] forKey:@"Name"];
        [dic setObject:[self.item.fields objectForKey:@"Description"] forKey:@"Description"];
        [dic setObject:[self.item.fields objectForKey:@"body"] forKey:@"Body"];
        [dic setObject:[self.item.fields objectForKey:@"ParentId"] forKey:@"ParentId"];
        requestBody=[dic JSONRepresentation];

    }else{
        //do update attachment
        baseUrl = [NSString stringWithFormat:@"%@%@%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"], URL_SERVICE,self.sobject,Id];
        [dic setObject:[self.item.fields objectForKey:@"body"] forKey:@"Body"];
        requestBody=[dic JSONRepresentation];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    NSLog(@"Method %@",[self getMethod]);
    request.HTTPMethod = [self getMethod];

    NSString *msgLength = [NSString stringWithFormat:@"%d", [requestBody length]];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"OAuth %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]] forHTTPHeaderField:@"Authorization"];
    [request addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];

    self.theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

-(NSString *)getMethod{
    NSString *Id = [self.item.fields objectForKey:@"Id"];
    Id = Id == nil ? @"" : Id;
    if (![Id isEqualToString:@""]) return @"PATCH";
    return @"POST";
}

-(NSString *)getProccessName{
    return @"Upsert Attachment";
}

@end

