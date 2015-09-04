//
//  AssessmentsResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv on 5/21/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import "ResponseParser.h"
@interface AssessmentsResponseParser : ResponseParser
@property (nonatomic, retain) NSMutableDictionary *assessment;
@property (nonatomic, retain) NSMutableDictionary *quest;
@property (nonatomic, retain) NSMutableDictionary *answer;
@end
