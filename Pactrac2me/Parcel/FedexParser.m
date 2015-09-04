//
//  FedexParser.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/10/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "FedexParser.h"

@implementation FedexParser

-(BOOL)parse:(NSDictionary *)jsonData{
    
    NSArray *arr = [[jsonData objectForKey:@"TrackPackagesResponse"] objectForKey:@"packageList"];
    NSDictionary *dic = [arr objectAtIndex:0];
    
    BOOL isSuccess = [[dic objectForKey:@"isSuccessful"] boolValue];
    
    return isSuccess;
    
}

-(NSDictionary*)dataReturned:(NSDictionary*)jsonData {
    NSArray *arr = [[jsonData objectForKey:@"TrackPackagesResponse"] objectForKey:@"packageList"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setValue:[[arr objectAtIndex:0] valueForKey:@"keyStatus"] forKey:@"keyStatus"];
    
    return dic;
}


@end
