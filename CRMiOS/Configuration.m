//
//  Configuration.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "Configuration.h"


@implementation Configuration

@synthesize entities, subtypes, properties, licensed;
@synthesize level, version;

static Configuration *_configuration = nil;

- (id)init {
    self = [super init];
    self.properties = [[NSMutableDictionary alloc] initWithCapacity:1];
    self.entities = [[NSMutableArray alloc] initWithCapacity:1];
    self.subtypes = [[NSMutableArray alloc] initWithCapacity:1];
    self.licensed = [NSNumber numberWithBool:NO];
    return self;
    
}

- (void) dealloc
{
    [self.properties release];
    [self.subtypes release];
    [self.entities release];
    [super dealloc];
}


+ (void)reload {
    _configuration = [[Configuration alloc] init];
    
    // 1) Load default configuration
    ConfigLoader *configLoader = [[ConfigLoader alloc] init];
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"default_configuration" ofType:@"xml"];
    NSData *configContent = [NSData dataWithContentsOfFile:configPath options:NSUTF8StringEncoding error:NULL]; 
    _configuration = [configLoader loadConfig:configContent];
    
    // 2) Load override configuration
    ConfigLoader *overrideLoader = [[ConfigLoader alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *overridePath = [documentsDirectory stringByAppendingPathComponent:@"ipad.xml"];
    NSData *overrideContent = [NSData dataWithContentsOfFile:overridePath options:NSUTF8StringEncoding error:NULL];
    if (overrideContent != nil) {
        Configuration *overrideConfig = [overrideLoader loadConfig:overrideContent];
        if (overrideConfig.version != nil) {
            // override properties
            for (NSString *property in overrideConfig.properties) {
                NSString *overrideValue = [overrideConfig.properties objectForKey:property];
                if (overrideValue != nil && overrideValue.length > 0) {
                    [_configuration.properties setObject:overrideValue forKey:property];
                }
            }
            //_configuration.properties = overrideConfig.properties;
            // subtype overriding
            for (ConfigSubtype *overrideSubtype in overrideConfig.subtypes) {
                BOOL found = NO;
                for (ConfigSubtype *subtype in _configuration.subtypes) {
                    if ([subtype.entity isEqualToString:overrideSubtype.entity] && ([subtype.name isEqualToString:overrideSubtype.name])) {
                        subtype.actions = overrideSubtype.actions;
                        if ([overrideSubtype.detailLayout.pages count] > 0) {
                            subtype.detailLayout = overrideSubtype.detailLayout;
                        }
                        if ([overrideSubtype.mandatoryFields count]>0) {
                            subtype.mandatoryFields = overrideSubtype.mandatoryFields;
                        }
                        subtype.displayText = overrideSubtype.displayText;
                        subtype.secondaryText = overrideSubtype.secondaryText;
                        if (overrideSubtype.sublists != nil) {
                            [subtype.sublists addObjectsFromArray:overrideSubtype.sublists];
                        }
                        if (overrideSubtype.iconField != nil) {
                            subtype.iconField = overrideSubtype.iconField;
                            subtype.listIcons = overrideSubtype.listIcons;
                        }
                        if ([overrideSubtype.readonly count] > 0) {
                            subtype.readonly = overrideSubtype.readonly;
                        }
                        if ([overrideSubtype.disabledRelations count] > 0) {
                            subtype.disabledRelations = overrideSubtype.disabledRelations;
                        }
                        if ([overrideSubtype.customNames count] > 0) {
                            subtype.customNames = overrideSubtype.customNames;
                        }
                        if ([overrideSubtype.pdfLayout.sections count] > 0) {
                            subtype.pdfLayout.sections = overrideSubtype.pdfLayout.sections;
                        }
                        if ([overrideSubtype.filterField length] > 0 && [overrideSubtype.filters count] > 0) {
                            ConfigFilter *filter = [overrideSubtype.filters objectAtIndex:0];
                            if (![filter.name isEqualToString:@"null"]) {
                                subtype.filterField = overrideSubtype.filterField;
                                subtype.filters = overrideSubtype.filters;
                            }
                        }
                        
                        //override order field
                        if (overrideSubtype.orderField != nil) {
                            subtype.orderField = overrideSubtype.orderField;
                        }
                        //override group-by field
                        if (overrideSubtype.groupBy!=nil) {
                            subtype.groupBy = overrideSubtype.groupBy;
                        }
                        subtype.orderAscending =  overrideSubtype.orderAscending;
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    // new subtype, read the icon from the standard subtype
                    for (ConfigSubtype *subtype in _configuration.subtypes) {
                        if ([subtype.entity isEqualToString:overrideSubtype.entity] && ([subtype.name isEqualToString:subtype.entity])) {
                            overrideSubtype.iconName = subtype.iconName;
                        }
                    }
                    [_configuration.subtypes addObject:overrideSubtype];
                }
            }

            
            // entities overriding
            for (ConfigEntity *overrideEntity in overrideConfig.entities) {
                BOOL found = NO;
                for (ConfigEntity *configEntity in _configuration.entities) {
                    if ([configEntity.name isEqualToString:overrideEntity.name]) {
                        configEntity.enabled = overrideEntity.enabled;
                        configEntity.canCreate = overrideEntity.canCreate;
                        configEntity.canUpdate = overrideEntity.canUpdate;
                        configEntity.canDelete = overrideEntity.canDelete;
                        configEntity.hidden = overrideEntity.hidden;
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    [_configuration.entities addObject:overrideEntity];
                    BOOL idMissing = YES;
                    for (NSString *field in overrideEntity.fields) {
                        if ([field isEqualToString:@"Id"]) {
                            idMissing = NO;
                            break;
                        }
                    }
                    if (idMissing) {
                        [overrideEntity.fields addObject:@"Id"];
                    }
                }
            }
            
            // disable some subtypes?
            BOOL doAgain;
            do {
                doAgain = NO;
                for (ConfigSubtype *configSubtype in _configuration.subtypes) {
                    BOOL found = NO;
                    for (ConfigSubtype *overrideSubtype in overrideConfig.subtypes) {
                        if ([configSubtype.name isEqualToString:overrideSubtype.name]
                            || ([configSubtype.entity isEqualToString:overrideSubtype.entity]
                                && ![configSubtype.entity isEqualToString:@"Activity"])) {
                            found = YES;
                            break;
                        }
                    }
                    if (!found && ![configSubtype.name isEqualToString:@"User"]) {
                        [_configuration.subtypes removeObject:configSubtype];
                        doAgain = YES;
                        break;
                    }
                }
            } while (doAgain);
            
            // disable some entities?
            for (ConfigEntity *configEntity in _configuration.entities) {
                if ([configEntity.name isEqualToString:@"User"]) continue;
                // category should be enabled if product is enabled
                if ([configEntity.name isEqualToString:@"Category"]) {
                    BOOL hasProduct = NO;
                    for (ConfigEntity *overrideEntity in overrideConfig.entities) {
                        if ([overrideEntity.name isEqualToString:@"Product"]) {
                            hasProduct = YES;
                            break;
                        }
                    }
                    if (hasProduct) {
                        configEntity.enabled = YES;
                        continue;
                    }
                }
                BOOL found = NO;
                for (ConfigEntity *overrideEntity in overrideConfig.entities) {
                    if ([configEntity.name isEqualToString:overrideEntity.name]) {
                        configEntity.enabled = overrideEntity.enabled;
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    configEntity.enabled = NO;
                }
            }
        }
    }
    // 3) Compute a hashcode for configuration so that layout is updated each time there is a change
    int hashEntityContent = [[[NSString alloc] initWithData:configContent encoding:NSUTF8StringEncoding] hash];
    int hashOverrideContent = [[[NSString alloc] initWithData:overrideContent encoding:NSUTF8StringEncoding] hash];
    _configuration.level = [NSNumber numberWithInt:hashEntityContent * 37 + hashOverrideContent];
    
    // 4) fix the fields that might be missing in entities
    for (ConfigSubtype *configSubtype in _configuration.subtypes) {
        ConfigEntity *configEntity = nil;
        for (ConfigEntity *tmp in _configuration.entities) {
            if ([tmp.name isEqualToString:configSubtype.entity]) {
                configEntity = tmp;
                break;
            }
        }
        for (Page *page in configSubtype.detailLayout.pages) {
            for (Section *section in page.sections) {
                for (NSString *field in section.fields) {
                    if ([configEntity.fields indexOfObject:field] == NSNotFound) {
                        [configEntity.fields addObject:field];
                    }
                }
            }
        }
        for (NSString *field in [EvaluateTools getFieldsFromFormula:configSubtype.displayText]) {
            if (![configEntity.fields containsObject:field]) {
                [configEntity.fields addObject:field];
            }
        }
        for (NSString *field in [EvaluateTools getFieldsFromFormula:configSubtype.secondaryText]) {
            if (![configEntity.fields containsObject:field]) {
                [configEntity.fields addObject:field];
            }
        }
    }
    for (ConfigEntity *configEntity in _configuration.entities) {
        for (Relation *relation in [Relation getEntityRelations:configEntity.name]) {
            NSArray *relFields = nil;
            NSString *relKey = nil;
            if ([relation.srcEntity isEqualToString:configEntity.name]) {
                relFields = relation.srcFields;
                relKey = relation.srcKey;
            } else if ([relation.destEntity isEqualToString:configEntity.name]) {
                relFields = relation.destFields;
                relKey = relation.destKey;
            }
            if (relFields != nil) {
                if (![configEntity.fields containsObject:relKey]) {
                    [configEntity.fields addObject:relKey];
                }
                for (NSString *field in relFields) {
                    if (![configEntity.fields containsObject:field]) {
                        [configEntity.fields addObject:field];
                    }
                }
            }
        }
    }
    

}

+ (Configuration *)getInstance
{
	@synchronized([Configuration class])
	{
		if (!_configuration) {
            [Configuration reload];
        }
		return _configuration;
	}
    
	return nil;
}


+ (NSObject <EntityInfo> *) getInfo:(NSString *)entity {
    if ([entity rangeOfString:@" "].location != NSNotFound) {
        entity = [entity substringToIndex:[entity rangeOfString:@" "].location];
    }
    for (ConfigEntity *configEntity in [Configuration getInstance].entities) {
        if ([configEntity.name isEqualToString:entity]) {
            return configEntity;
        }
    }
    return nil;
}

// use preferably this one than the following
+ (NSObject <Subtype> *)getSubtypeInfo:(NSString *)subtype entity:(NSString *)entity {
    for (ConfigSubtype *configSubtype in [Configuration getInstance].subtypes) {
        if ([configSubtype.name isEqualToString:subtype] && [configSubtype.entity isEqualToString:entity]) {
            return configSubtype;
        }
    }
    return nil;
}

// should disappear and be replaced with the previous whenever possible
+ (NSObject <Subtype> *)getSubtypeInfo:(NSString *)subtype {
    for (ConfigSubtype *configSubtype in [Configuration getInstance].subtypes) {
        if ([configSubtype.name isEqualToString:subtype]) {
            return configSubtype;
        }
    }
    return nil;
}

+ (BOOL)isYes:(NSString *)property {
    NSString *value = [_configuration.properties objectForKey:property];
    return value != nil && [value caseInsensitiveCompare:@"YES"] == NSOrderedSame;
}


+ (NSArray *) getEntities {
    NSMutableArray *entities = [[NSMutableArray alloc] initWithCapacity:1];
    for (ConfigEntity *configEntity in [Configuration getInstance].entities) {
        if ([configEntity enabled]) {
            [entities addObject:configEntity.name];
        }
    }
    [entities sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return entities;
}


+ (NSString *)getSubtype:(Item *)item {
    NSString *subtypeName = nil;
    int criteriaCount = 0;
    for (ConfigSubtype *subtype in [Configuration getInstance].subtypes) {
        if ([subtype.entity isEqualToString:item.entity]) { 
            BOOL ok = YES;
            for (NSObject <Criteria> *criteria in subtype.criterias) {
                if ([criteria isKindOfClass:[ValuesCriteria class]]) {
                    if (![[item.fields objectForKey:[criteria column]] isEqualToString:[((ValuesCriteria *)criteria).values objectAtIndex:0]]) {
                        ok = NO;
                        break;
                    }       
                } else if ([criteria isKindOfClass:[NotInCriteria class]]) {
                    if ([[item.fields objectForKey:[criteria column]] isEqualToString:[((NotInCriteria *)criteria).values objectAtIndex:0]]) {
                        ok = NO;
                        break;
                    }       
                }
            }
            if (ok) {
                if (subtypeName == nil || [subtype.criterias count] > criteriaCount) {
                    subtypeName = subtype.name;
                    criteriaCount = [subtype.criterias count];
                }
            }

        }
    }
    return subtypeName;
}

+ (NSData *)companyLogo {

    NSString *value = [_configuration.properties objectForKey:@"companyLogo"];    
    [Base64 initialize];
    NSData *imageData = [Base64 decode:value];
    return imageData;

}

+ (NSString *)getProperty:(NSString *)property {
    return [_configuration.properties objectForKey:property];
}



+ (void)writeLicense:(NSString *)lic {

    NSLog(@"saving license %@",lic);
    if ([lic isEqualToString:@"yes"]) {
        [[Configuration getInstance] setLicensed:[NSNumber numberWithBool:YES]]; 
    }else{
        [[Configuration getInstance] setLicensed:[NSNumber numberWithBool:NO]]; 
    }
}

+ (BOOL)isLicensed{
    
    NSLog(@"licensed = %@",[[Configuration getInstance] licensed]);
    return [[[Configuration getInstance] licensed] boolValue];
}

@end
