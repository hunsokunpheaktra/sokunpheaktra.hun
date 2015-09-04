//
//  Layout.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DetailLayout : NSObject {
    NSMutableArray *pages;
}

@property (nonatomic, retain) NSMutableArray *pages;

- (id)init;

@end
