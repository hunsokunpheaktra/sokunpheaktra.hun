//
//  BaseCriteria.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/3/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaseCriteria : NSObject {
    NSString *column;
}

@property (nonatomic, retain) NSString *column;

- (id)initWithColumn:(NSString *)column;


@end
