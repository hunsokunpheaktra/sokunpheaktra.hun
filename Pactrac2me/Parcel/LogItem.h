//
//  LogItem.h
//  kba
//
//  Created by Sy Pauv on 10/3/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogItem : NSObject {
    NSString *message;
    NSString *task;
    NSString *type;
    NSDate *date;
    NSString *count;
    NSString *errorId;
    NSString *entity;
}

@property (nonatomic, retain) NSString *errorId;
@property (nonatomic, retain) NSString *entity;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *task;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *count;
@property (nonatomic, retain) NSDate   *date;

    


@end
