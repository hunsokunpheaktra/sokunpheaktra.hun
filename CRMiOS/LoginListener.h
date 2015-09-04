//
//  LoginListener.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 9/29/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LoginListener <NSObject>

- (void)updateSyncButton:(BOOL)running;

@end
