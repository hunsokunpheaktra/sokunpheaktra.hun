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

@interface SyncCallPlugin : CDVPlugin<UINavigationControllerDelegate>{
	
    SynchronizeViewController* viewController;
    UINavigationController* navController;
    CGRect	originalWebViewBounds;
    NSString* callbackID;  
}

@property (nonatomic, copy) NSString* callbackID;

//Instance Method
- (NSString*)mappingFieldWithValue:(Item*)item;
- (NSString*) getStringFromListData : (NSArray*) listData;
- (NSString*) getArrayFromitem:(NSArray*)listItem javascriptMethode:(NSString*)methodeName indexSelected:(int)index;
- (void) savePicture:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) clearData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) updateEnvironment:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getPropertyValue:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) openSynchronizeScreen:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) initData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getFieldInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getEntityInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getLayout:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) findRecord:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) update:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) insert:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getReference:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getPickList:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getRelatedListColumnInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getRelatedListData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getRecordTypeWithEntity:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getChildRelationShipInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) mapCascadingPicklist:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end