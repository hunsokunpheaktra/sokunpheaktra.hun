//
//  TNTParser.m
//  Parcel
//
//  Created by Hun Sokunpheaktra on 1/10/13.
//  Copyright (c) 2013 Davin Pen. All rights reserved.
//

#import "TNTParser.h"

@implementation TNTParser

-(BOOL)parse:(NSDictionary *)jsonData{
    
    NSArray *arr = [jsonData objectForKey:@"result"];
    NSString *status = [[arr objectAtIndex:0] lastObject];
    
    return [jsonData objectForKey:@"result"] > 0 && ![status isEqualToString:@"Not found"];
}

- (NSDictionary *)dataReturned:(NSDictionary *)jsonData {

    NSArray* arr = [jsonData valueForKey:@"result"];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setValue:[[arr objectAtIndex:0] lastObject] forKey:@"keyStatus"];
    
    return dic;
}

@end
