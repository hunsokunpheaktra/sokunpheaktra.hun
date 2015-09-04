//
//  CascadingPicklist.h
//  SyncForce
//
//  Created by Gaeasys Admin on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CascadingPicklist : NSObject{
    //controller field
    NSString *controller;
    
    //children fields
    NSArray *children;
    
    //value controller map children field
    NSDictionary *validValue;
}

@property (nonatomic, retain) NSString *controller;
@property (nonatomic, retain) NSArray *children;
@property (nonatomic, retain) NSDictionary *validValue;

- (id)init:(NSString *)pcontroler;
- (void)checkValidFor:(NSString *)entity;

@end