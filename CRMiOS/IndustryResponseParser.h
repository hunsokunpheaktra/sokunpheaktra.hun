//
//  IndustryResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/19/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "IndustryManager.h"

@interface IndustryResponseParser : ResponseParser {
     NSMutableDictionary *industry;    
}

@property (nonatomic, retain) NSMutableDictionary *industry;

- (id)init;

@end
