//
//  RelationManager.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 4/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "RelationManager.h"


@implementation RelationManager


+ (NSArray *)getSubtypeRelations:(NSString *)subtype relation:(Relation *)relation {
    NSString *otherKey, *thisKey, *otherEntity;
    NSArray *thisFields;
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    if ([relation.srcEntity isEqualToString:[sinfo entity]]) {
        thisKey = relation.srcKey;
        thisFields = relation.srcFields;
        otherEntity = relation.destEntity;
        otherKey = relation.destKey;
    } else {
        thisKey = relation.destKey;
        thisFields = relation.destFields;
        otherEntity = relation.srcEntity;
        otherKey = relation.srcKey;
    }
     
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject <EntityInfo> *info = [Configuration getInfo:otherEntity];
    NSArray *subtypes = [info getSubtypes];
    for (NSObject <Subtype> *otherSubtype in subtypes) {
        if (![otherSubtype.name isEqualToString:otherSubtype.entity] || [subtypes count] == 1) {
            RelationSub *rsub = [[RelationSub alloc] initWith:relation subtype:subtype entity:[sinfo entity] key:thisKey fields:thisFields otherEntity:otherEntity otherSubtype:otherSubtype.name otherKey:otherKey];
            [results addObject:rsub];
            [rsub release];
        }
    }
    return results;
}


+ (NSArray *)getRelations:(NSString *)subtype entity:(NSString *)entity {
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:1];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype entity:entity];
    NSArray *relations = [Relation getEntityRelations:[sinfo entity]];
    for (Relation *relation in relations) {
        NSArray *relSubs = [RelationManager getSubtypeRelations:subtype relation:relation];   
        [results addObjectsFromArray:relSubs];
        [relSubs release];
        if ([relation.srcEntity isEqualToString:relation.destEntity]) {
            Relation *reverse = [[Relation alloc] initWith:relation.destEntity srcKey:relation.destKey destEntity:relation.srcEntity destKey:relation.srcKey srcFields:relation.destFields destFields:relation.srcFields];
            NSArray *revRelSubs = [RelationManager getSubtypeRelations:subtype relation:reverse];   
            [results addObjectsFromArray:revRelSubs];
            [revRelSubs release];
        }
    }
    return results;
}

+ (NSString *)singleField:(NSString *)subtype from:(NSString *)fromSubtype entity:(NSString *)entity {
    NSArray *relSubs = [RelationManager getRelations:fromSubtype entity:entity];
    NSString *singleField = nil;
    for (RelationSub *relSub in relSubs) {
        if ([relSub.otherSubtype isEqualToString:subtype]) {
            if ([relSub.key isEqualToString:@"Id"]) {
                return nil;
            } else {
                if (singleField != nil) {
                    return nil; // two fields can match ? return nil
                }
                singleField = relSub.key;
            }
        }
        if ([relSub.subtype isEqualToString:subtype]) {
            return nil;
        }
    }
    return singleField;
}

+ (BOOL)isCreatable:(NSString *)subtype from:(NSString *)fromSubtype entity:(NSString *)entity {
    NSArray *relSubs = [RelationManager getRelations:fromSubtype entity:entity];
    NSObject <Subtype> *sInfo = [Configuration getSubtypeInfo:fromSubtype];
    for (RelationSub *relSub in relSubs) {
        if (![sInfo enabledRelation:relSub.key]) continue;
        if ([relSub.otherSubtype isEqualToString:subtype] && [relSub.key isEqualToString:@"Id"]) {
            NSObject <Subtype> *osInfo = [Configuration getSubtypeInfo:relSub.otherSubtype];
            if (![osInfo enabledRelation:relSub.otherKey]) continue;
            NSObject <EntityInfo> *eInfo = [Configuration getInfo:osInfo.entity];
            if ([eInfo canCreate]) {
                return YES;
            }
        }
    }
    return NO;
}


// Returns an item's related items.
// The returned object is a dictionary that maps subtypes to a list of objects.
+ (NSDictionary *)getRelatedItems:(Item *)detail {
    NSMutableDictionary *relatedDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:[Configuration getSubtype:detail] entity:detail.entity];
    for (RelationSub *relSub in [RelationManager getRelations:sinfo.name entity:sinfo.entity]) {
        // *** NESTLE SPECIFIC ***
        //if ([Configuration isYes:@"NestleWholesaleAccount"] && [relSub.relation.srcKey isEqualToString:@"CustomText33"]) continue;
        if (![sinfo enabledRelation:relSub.key]) continue;
        NSMutableArray *related = [relatedDict objectForKey:relSub.otherSubtype];
        if (related == nil) {
            related = [[NSMutableArray alloc] initWithCapacity:1];
            [relatedDict setObject:related forKey:relSub.otherSubtype];
        }        
        NSString *refValue = [detail.fields valueForKey:relSub.key];
        if (refValue != nil && [refValue length] > 0 && ![refValue isEqualToString:@"No Match Row Id"]) {
            NSObject <Subtype> *rsinfo = [Configuration getSubtypeInfo:relSub.otherSubtype entity:relSub.otherEntity];
            NSArray *criterias = [NSArray arrayWithObject:[ValuesCriteria criteriaWithColumn:relSub.otherKey value:refValue]];
            NSArray *others = [EntityManager list:rsinfo.name entity:rsinfo.entity criterias:criterias additional:nil limit:RELATED_MAX_OBJ];
            NSString *suffix = nil;
            if (![relSub.key isEqualToString:@"Id"]) {
                CRMField *field = [FieldsManager read:detail.entity field:relSub.key];
                if (field != nil && ![field.code hasPrefix:relSub.otherEntity]) {
                    suffix = field.displayName;
                    if ([suffix hasSuffix:@" Id"] || [suffix hasSuffix:@" ID"]) {
                        suffix = [suffix substringToIndex:[suffix length] - 3];
                    }
                }
            }
            if ([others count] == 0 && ![relSub.key isEqualToString:@"Id"] && [relSub.subtype isEqualToString:relSub.entity]
                 && [relSub.otherSubtype isEqualToString:relSub.otherEntity]) {
                // could not find item in other entity, display instead the display field
                NSString *display = refValue;
                if ([relSub.fields count] > 0) {
                    NSString *tmp = [detail.fields objectForKey:[relSub.fields objectAtIndex:0]];
                    if (tmp != nil && [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
                        display = tmp;
                    }
                }
                NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:1];
                [item setObject:display forKey:@"Name"];
                if (suffix != nil) {
                    [item setObject:suffix forKey:@"Type"];
                }
                [item setObject:@"-1" forKey:@"gadget_id"];
                [related addObject:item];
                [item release];
            } else {
                for (Item *other in others) {
                    NSString *prefix = nil;
                    NSString *otherId = [other.fields valueForKey:@"gadget_id"];
                    // need to use the entity subtype so we have the same group info than the list
                    NSObject <Subtype> *gsinfo = [other.entity isEqualToString:@"Activity"] ? rsinfo : [Configuration getSubtypeInfo:other.entity];
                    NSString *groupId = [gsinfo getGroupName:other];
                    if ([groupId length] > 1) {
                        prefix = groupId;
                    }
                    NSString *displayName = [rsinfo getDisplayText:other];
                    // get all the related items for this subtype
                    BOOL exists = NO;
                    // avoid duplicates
                    for (NSDictionary *tmp in related) {
                        if ([[tmp valueForKey:@"gadget_id"] isEqualToString:otherId]) {
                            exists = YES;
                            break;
                        }
                    }
                    if (!exists) {
                        if (prefix != nil) {
                            displayName = [NSString stringWithFormat:@"%@ - %@", prefix, displayName];
                        }
                        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:1];
                        [item setObject:relSub forKey:@"relSub"];
                        [item setObject:refValue forKey:@"refValue"];
                        [item setObject:displayName forKey:@"Name"];
                        if (suffix != nil) {
                            [item setObject:suffix forKey:@"Type"];
                        } 
                        [item setObject:otherId forKey:@"gadget_id"];
                        [related addObject:item];
                        [item release];
                    }
                }
            }
                
            [others release];
        }
    }

    return relatedDict;
}

+ (Item *)getRelatedItem:(NSString *)subtype field:(NSString *)field value:(NSString *)value {
    if ([value length] == 0 || [value isEqualToString:@"No Match Row Id"]) {return nil;}
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    NSString *entity = sinfo == nil ? subtype : sinfo.entity;
    for (Relation *relation in [Relation getEntityRelations:entity]) {
        if ([relation.srcEntity isEqualToString:entity] && [relation.srcKey isEqualToString:field]) {
            return [EntityManager find:relation.destEntity column:relation.destKey value:value];
        }
    }
    return nil;
}

+ (NSString *)getRelatedEntity:(NSString *)subtype field:(NSString *)field {
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    NSString *entity = sinfo == nil ? subtype : sinfo.entity;
    for (Relation *relation in [Relation getEntityRelations:entity]) {
        if ([relation.srcEntity isEqualToString:entity] && [relation.srcKey isEqualToString:field]) {
            return relation.destEntity;
        }
    }
    return nil;

}


+ (BOOL)isCalculated:(NSString *)subtype field:(NSString *)field {
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    NSString *entity = sinfo == nil ? subtype : sinfo.entity;
    for (Relation *relation in [Relation getEntityRelations:entity]) {
        if ([relation.srcEntity isEqualToString:entity]) {
            if ([relation.srcFields containsObject:field]) {
                return YES;
            }
        }
    }
    return NO;
}


+ (BOOL)isKey:(NSString *)subtype field:(NSString *)field {
    NSObject <Subtype> *sinfo = [Configuration getSubtypeInfo:subtype];
    for (Relation *relation in [Relation getEntityRelations:sinfo.entity]) {
        if ([relation.srcEntity isEqualToString:sinfo.entity]) {
            if ([relation.srcKey isEqualToString:field]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
