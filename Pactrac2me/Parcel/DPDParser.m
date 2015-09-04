//
//  DPDParser.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/10/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "DPDParser.h"

@implementation DPDParser

-(BOOL)parse:(NSDictionary *)jsonData{
    return [jsonData objectForKey:@"result"] > 0 ;
}


- (NSDictionary *)dataReturned:(NSDictionary *)jsonData {
    
    NSArray* arr = [jsonData valueForKey:@"result"];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setValue:[[arr lastObject] objectAtIndex:2] forKey:@"keyStatus"];
    
    return dic;
    
}


@end
