//
//  InfoFactory.h
//  kba
//
//  Created by Sy Pauv on 10/1/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityInfo.h"

@interface InfoFactory : NSObject {
    
}
+(void)clearInfo ;
+ (NSObject <EntityInfo> *) getInfo:(NSString *)entity;
+ (NSMutableArray *) getEntities;
+ (void)initInfos;
@end
