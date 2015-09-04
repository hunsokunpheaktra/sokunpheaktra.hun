//
//  FieldResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "FieldsManager.h"

@interface FieldResponseParser : ResponseParser {
    NSMutableDictionary *currentField;
    NSString *entity;
}
@property (nonatomic,retain) NSString *entity;
@property (nonatomic,retain) NSMutableDictionary *currentField;

- (id)initWithEntity:(NSString *) newEntity;

@end
