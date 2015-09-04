//
//  CascadingPicklistParser.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 7/30/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "CascadingPicklistManager.h"

@interface CascadingPicklistParser : ResponseParser{
    NSMutableDictionary *cascadingValue;
}

@property (nonatomic, retain) NSMutableDictionary *cascadingValue;

@end
