//
//  HermesParser.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/10/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "HermesParser.h"

@implementation HermesParser

-(BOOL)parse:(NSDictionary *)jsonData{
    
    BOOL isSuccess = [jsonData objectForKey:@"status"] > 0;
    
    return isSuccess;
    
}

-(NSDictionary*)dataReturned:(NSDictionary*)jsonData {
    
    NSArray *arr = [jsonData objectForKey:@"status"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setValue:[[arr objectAtIndex:0] valueForKey:@"statusDescription"] forKey:@"keyStatus"];

    return dic;
}


@end
