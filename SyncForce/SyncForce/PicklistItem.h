//
//  PicklistItem.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicklistItem : NSObject{
    NSString *label;
    NSString *value;
}

@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) NSString *value;

- (id)init:(NSString *)plabel value:(NSString *)pvalue;

@end
