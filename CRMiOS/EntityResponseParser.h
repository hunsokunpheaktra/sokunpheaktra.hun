//
//  XMLParser.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/8/11.
//  Copyright 2011 Fellow Consulting . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityManager.h"
#import "ParserListener.h"
#import "ResponseParser.h"
#import "MergeContacts.h"

@interface EntityResponseParser : ResponseParser {
    NSString *entity;
    NSString *sublist;
    NSMutableDictionary *fields;
    NSMutableDictionary *sublistFields;
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *sublist;
@property (nonatomic, retain) NSMutableDictionary *fields;
@property (nonatomic, retain) NSMutableDictionary *sublistFields;


- (id)initWithEntity:(NSString *)newEntity;

@end
