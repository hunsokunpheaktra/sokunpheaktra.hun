//
//  NamedNavigationController.m
//  CRMiOS
//
//  Created by Arnaud Marguerat on 2/15/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import "NamedNavigationController.h"

@implementation NamedNavigationController

@synthesize name;

- (id)initWithRootViewController:(UIViewController *)rootViewController name:(NSString *)pName {
    self = [super initWithRootViewController:rootViewController];
    self.name = pName;
    return self;
}

@end
