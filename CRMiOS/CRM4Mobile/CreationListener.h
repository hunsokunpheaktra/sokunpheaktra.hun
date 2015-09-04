//
//  CreationListener.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 11/1/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CreationListener <NSObject>

- (void)didCreate:(NSString *)entity key:(NSString *)key;


@end
