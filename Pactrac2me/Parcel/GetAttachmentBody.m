//
//  GetAttachment.m
//  Pactrac2me
//
//  Created by Sy Pauv on 1/22/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "GetAttachmentBody.h"

@implementation GetAttachmentBody
@synthesize item;
-(id)initWithID:(Item *)rId{
    self=[super init];
    self.item=rId;
    return self;
}

-(void)doRequest:(NSObject<SyncListener> *)listen{
    
    self.synListener=listen;
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@Attachment/%@/body",[[NSUserDefaults standardUserDefaults] objectForKey:@"instance_url"],URL_SERVICE,[item.fields objectForKey:@"Id"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    request.HTTPMethod = [self getMethod];
    // request query record
    [request addValue:[NSString stringWithFormat:@"OAuth %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]] forHTTPHeaderField:@"Authorization"];
    [request addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
    self.theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

-(NSString *)getProccessName{
    return @"Get Attachment Body";
}

@end
