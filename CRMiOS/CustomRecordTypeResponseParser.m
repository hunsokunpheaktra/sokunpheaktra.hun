//
//  CustomRecordTypeResponseParser.m
//  CRMiOS
//
//  Created by Sy Pauv on 6/15/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "CustomRecordTypeResponseParser.h"


@implementation CustomRecordTypeResponseParser

@synthesize recordType;

- (id)init{
    self = [super init];
    self.recordType = [[NSMutableDictionary alloc] initWithCapacity:1];
    return self;
}


- (void)handleTag:(NSString *)tag value:(NSString *)value level:(int)level {
    
    //NSLog(@"tag = %@ value= %@ leve %d",tag,value,level);
    
    if (level==6 && [tag isEqualToString:@"Name"]) {
        // fix bug for Custom Object => CustomObject
        [recordType setObject:[value stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:tag];
        
    } else if (level == 8 && ([tag isEqualToString:@"LanguageCode"]|| [tag isEqualToString:@"SingularName"]||[tag isEqualToString:@"PluralName"]||[tag isEqualToString:@"ShortName"])) {
        
        [recordType setObject:value forKey:tag];
        if ([tag isEqualToString:@"ShortName"]) {
            [self oneMoreItem];
            if ([CustomRecordTypeManager read:[self.recordType objectForKey:@"Name"] languageCode:[self.recordType objectForKey:@"LanguageCode"] plural:NO] == nil) {
                [CustomRecordTypeManager insert:self.recordType];
            }
            
        }
        
    }
    
    
}



@end
