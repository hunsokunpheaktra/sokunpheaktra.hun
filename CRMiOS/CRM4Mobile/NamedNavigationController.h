//
//  NamedNavigationController.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 2/15/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NamedNavigationController : UINavigationController {
    NSString *name;
}

@property (nonatomic, retain) NSString *name;


- (id)initWithRootViewController:(UIViewController *)rootViewController name:(NSString *)pName;

@end
