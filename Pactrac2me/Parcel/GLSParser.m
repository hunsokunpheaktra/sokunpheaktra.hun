//
//  GLSParser.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/10/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "GLSParser.h"

@implementation GLSParser

-(BOOL)parse:(NSDictionary *)jsonData{
    
    
    NSString *error = [jsonData objectForKey:@"exceptionText"];
    
    if(error) return false;
    
    BOOL isSuccess = [jsonData objectForKey:@"tuStatus"] > 0;
    
    return isSuccess;

}

-(NSDictionary*)dataReturned:(NSDictionary*)jsonData {
    
    NSArray *arr = [jsonData objectForKey:@"tuStatus"];

    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setValue:[[[[arr objectAtIndex:0] valueForKey:@"history"] objectAtIndex:0] valueForKey:@"evtDscr"] forKey:@"keyStatus"];

    
    return dic;
}


@end
