//
//  PicklistResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/9/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "PicklistManager.h"

@interface PicklistResponseParser : ResponseParser {
    NSMutableDictionary *picklistValue;
}

@property (nonatomic, retain) NSMutableDictionary *picklistValue;

@end
