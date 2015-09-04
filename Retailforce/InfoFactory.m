//
//  InfoFactory.m
//  kba
//
//  Created by Sy Pauv on 10/1/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import "InfoFactory.h"
#import "EntityInfoManager.h"
#import "FieldInfoManager.h"
#import "Entity.h"

@implementation InfoFactory

static NSMutableDictionary *infos;

+ (void)initInfos {
        
    if ([[EntityInfoManager list:nil] count] > 0 && infos == nil) {
    //if(infos == nil) infos = [[NSMutableDictionary alloc] initWithCapacity:1];
    [infos removeAllObjects];
        for(Item *entityInfo in [EntityInfoManager list:nil]){
            NSString * dif = [entityInfo.fields valueForKey:@"name"];
            [infos setObject: [[Entity alloc] initWithEntityInfo:entityInfo] forKey:dif];
        }
    }
}

+ (void)clearInfo{
    [infos release];
    infos = nil;
}

+ (NSObject <EntityInfo> *) getInfo:(NSString *)entity {

    Entity *entityInfo = [infos valueForKey:entity];
    
    if(!entityInfo){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:1];
        [dic setValue:[ValuesCriteria criteriaWithString:entity] forKey:@"name"];
        
        Item *item = [EntityInfoManager find:dic];
        
        [dic release];
        
        Entity *newInfo = [[Entity alloc] initWithEntityInfo:item];
        [infos setValue:newInfo forKey:entity];
        
        [item release];
        
        entityInfo = newInfo;
    }
    
    return entityInfo;
}

+ (NSMutableArray *) getEntities {
    [InfoFactory initInfos];
    NSMutableArray *entities = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *entity in [infos keyEnumerator]) {
        [entities addObject:entity];
    }
    [entities sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return entities;
}

@end
