//
//  ServerTimeResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/13/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ServerTimeResponseParser.h"


@implementation ServerTimeResponseParser



- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
   // tag= CurrentServerTime , level =4 ,value= 07/14/2011 04:48:48
    if ([tag isEqualToString:@"CurrentServerTime"] && level==4) {
        [PropertyManager save:@"SyncStart" value:value];
        [self oneMoreItem];
    }
    
}

@end
