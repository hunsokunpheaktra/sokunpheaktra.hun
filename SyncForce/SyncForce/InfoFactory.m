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
    
    //if ([[EntityInfoManager list:nil] count] > 0 && infos == nil) {

    infos =  [NSMutableDictionary dictionaryWithCapacity:1]; //[[NSMutableDictionary alloc] initWithCapacity:1];
        NSArray* tmp  =  [EntityInfoManager list:nil];
        for(Item *entityInfo in tmp){
            NSString * dif = [[entityInfo fields] valueForKey:@"name"];
            [infos setObject: [[[Entity alloc] initWithEntityName:dif] autorelease] forKey:dif];
        }
        
        [tmp release];
    //}    
    //}
}

+ (void)clearInfo{
    infos = nil;
}

+ (NSObject <EntityInfo> *) getInfo:(NSString *)entity {
    [InfoFactory initInfos];    
    return [[infos valueForKey:entity] retain];
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
