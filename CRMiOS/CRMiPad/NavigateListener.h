//
//  NavigateListener.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol NavigateListener <NSObject>

- (void)navigate:(NSString *)newEntity subtype:(NSString *)subtype key:(NSString *)key;

@end
