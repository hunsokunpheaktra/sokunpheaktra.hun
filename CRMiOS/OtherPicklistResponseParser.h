//
//  OtherPicklistResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/10/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "PicklistManager.h"

@interface OtherPicklistResponseParser : ResponseParser {
    
    NSMutableDictionary *picklistValue;
    NSString *entity;
    NSString *field;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *field;
@property (nonatomic, retain) NSMutableDictionary *picklistValue;

- (id)initWithEntity:(NSString *)newEntity fields:(NSString *)newField;

@end
