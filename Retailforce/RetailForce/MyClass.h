//
//  MyClass.h
//  testPluginStackOverflow
//
//  Created by Carlos Williams on 2/03/12.
//  Copyright (c) 2012 Devgeeks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynchronizeViewController.h"

#ifdef CORDOVA_FRAMEWORK
#import <Cordova/CDVPlugin.h>
#else
#import "CDVPlugin.h"
#endif

@interface MyClass : CDVPlugin<UINavigationControllerDelegate>{
	
    SynchronizeViewController* viewController;
    UINavigationController* navController;
    CGRect	originalWebViewBounds;
    NSString* callbackID;  
}

@property (nonatomic, copy) NSString* callbackID;

//Instance Method  
- (void) print:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end