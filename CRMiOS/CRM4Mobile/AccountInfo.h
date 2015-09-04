//
//  AccountInfo.h
//  TestMap
//
//  Created by Fellow Consulting AG on 8/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AccountInfo : NSObject {
    NSString *name;
    NSString *address;
    NSString *date;
    NSString *startTime;
    NSString *endTime;
    NSString *duration;
    
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *address;
@property (nonatomic,retain) NSString *date;
@property (nonatomic,retain) NSString *startTime;
@property (nonatomic,retain) NSString *endTime;
@property (nonatomic,retain) NSString *duration;

@end
