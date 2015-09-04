//
//  MetadataChangeResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "MetadataChangeResponseParser.h"


@implementation MetadataChangeResponseParser

- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
    if ([tag isEqualToString:@"LOVLastUpdated"] && level==6) {
        
        [self oneMoreItem];

        // If the field has not changed, we don't sync the picklists.
        
        if ([[PropertyManager read:@"LOVLastUpdated"] isEqualToString:value]) {
            
            [PropertyManager save:@"syncPicklist" value:@"NO"];
            
        } else {
            [PropertyManager save:@"syncPicklist" value:@"YES"];
            
        }
        [PropertyManager save:@"LOVLastUpdated" value:value];
        
    }
}


@end
