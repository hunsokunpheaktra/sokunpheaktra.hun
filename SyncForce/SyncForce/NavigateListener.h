//
//  NavigateListener.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/11/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@protocol NavigateListener <NSObject>

- (void)navigate:(int)row parentController:(UIViewController*)parent accountId:(NSString*)accId;

@end
