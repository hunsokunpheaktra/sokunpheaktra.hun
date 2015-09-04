//
//  FieldManagementParser.h
//  CRMiOS
//
//  Created by Arnaud on 1/11/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParser.h"
#import "FieldMgmtManager.h"

@interface FieldManagementParser: ResponseParser {
    NSMutableDictionary *currentField;
}

@property (nonatomic,retain) NSMutableDictionary *currentField;

- (id)init;

@end
