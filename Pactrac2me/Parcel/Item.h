//
//  Item.h
//  kba
//
//  Created by Sy Pauv on 10/1/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Item : NSObject {
    
    NSString *entity;
    NSMutableDictionary *fields;
    NSMutableDictionary *attachments;
    
}

@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSMutableDictionary *fields;
@property (nonatomic, retain) NSMutableDictionary *attachments;

- (id)initCustom:(NSString *)newEntity fields:(NSMutableDictionary *)newFields;
- (id)init:(NSString *)newEntity fields:(NSDictionary *)newFields;

@end
