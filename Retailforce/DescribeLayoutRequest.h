//
//  DescribeLayoutRequest.h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityRequest.h"
#import "ZKDescribeLayoutResult.h"

@interface DescribeLayoutRequest : EntityRequest{
    
    NSMutableArray* listFiledLayout;
    NSMutableArray* listMany2OneRelation;
}

-(NSArray*) getOne2OneRelation;
-(BOOL) isAbleToQuery :(NSString*) entityName;

@end
