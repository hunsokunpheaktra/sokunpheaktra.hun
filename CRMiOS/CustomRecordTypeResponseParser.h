//
//  CustomRecordTypeResponseParser.h
//  CRMiOS
//
//  Created by Sy Pauv on 6/15/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "CustomRecordTypeManager.h"

@interface CustomRecordTypeResponseParser : ResponseParser {
    
    NSMutableDictionary *recordType;
}

@property(nonatomic, retain) NSMutableDictionary *recordType;


@end
