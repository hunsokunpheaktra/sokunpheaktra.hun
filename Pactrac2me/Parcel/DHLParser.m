//
//  DHLParser.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/10/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "DHLParser.h"

@implementation DHLParser

-(BOOL)parse:(NSDictionary *)jsonData{

    return [jsonData objectForKey:@"result"] > 0 ;
}


- (NSDictionary *)dataReturned:(NSDictionary *)jsonData {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setValue:[jsonData valueForKey:@"result"] forKey:@"keyStatus"];
    
    return dic;
    
}

@end
