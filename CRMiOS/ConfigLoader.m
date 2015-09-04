//
//  ConfigLoader.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ConfigLoader.h"


@implementation ConfigLoader

@synthesize currentText;
@synthesize configuration;
@synthesize level;
@synthesize currentAttributes;

- (Configuration *)loadConfig:(NSData *)content {
    self.configuration = [[Configuration alloc] init];
    self.currentText = [[NSMutableString alloc] init];   
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:content];
    self.level = [NSNumber numberWithInt:0];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
    //[content release];
    [self.currentText release];
    return self.configuration;
}


- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.level = [NSNumber numberWithInt:[self.level intValue] + 1];
    self.currentAttributes = attributeDict;
    
    if ([elementName isEqualToString:@"configuration"]) {
        self.configuration.level = [NSNumber numberWithInt:[[attributeDict objectForKey:@"level"] intValue]];
        self.configuration.version = [attributeDict objectForKey:@"version"];
    }
    
    if ([elementName isEqualToString:@"entity"]) {
        ConfigEntity *configEntity = [[ConfigEntity alloc] initWithEntity:[attributeDict objectForKey:@"name"]];
        configEntity.searchField = [attributeDict objectForKey:@"search-field"];
        configEntity.searchField2 = [attributeDict objectForKey:@"alternate-search-field"];
        [self.configuration.entities addObject:configEntity];
        if ([attributeDict objectForKey:@"enabled"]!=nil) {
            if ([[attributeDict objectForKey:@"enabled"] caseInsensitiveCompare:@"NO"] == NSOrderedSame) {
                configEntity.enabled = NO;
            } 
        }
        if ([attributeDict objectForKey:@"sync-filter"]!=nil) {
            [PropertyManager save:[NSString stringWithFormat:@"ownerFilter%@", configEntity.name] value:[attributeDict objectForKey:@"sync-filter"]];
        }
        if ([attributeDict objectForKey:@"can-create"]!=nil) {
            if ([[attributeDict objectForKey:@"can-create"] caseInsensitiveCompare:@"NO"] == NSOrderedSame) {
                configEntity.canCreate = NO;
            }
        }
        if ([attributeDict objectForKey:@"can-delete"]!=nil) {
            if ([[attributeDict objectForKey:@"can-delete"] caseInsensitiveCompare:@"NO"] == NSOrderedSame) {
                configEntity.canDelete = NO;
            }
        }
        if ([attributeDict objectForKey:@"can-update"]!=nil) {
            if ([[attributeDict objectForKey:@"can-update"] caseInsensitiveCompare:@"NO"] == NSOrderedSame) {
                configEntity.canUpdate = NO;
            }
        }
        if ([attributeDict objectForKey:@"hidden"]!=nil) {
            if ([[attributeDict objectForKey:@"hidden"] caseInsensitiveCompare:@"YES"] == NSOrderedSame) {
                configEntity.hidden = YES;
            }
        }
        [configEntity release];
    }
    
    // for compatibility with old XML sublist format
    // to remove in the future
    if ([elementName isEqualToString:@"sublist"]) {
        currentSublist = [attributeDict objectForKey:@"name"];
    }
    
    if ([elementName isEqualToString:@"sublist-layout"]) {

        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        ConfigSublist *sublist = [[ConfigSublist alloc] initWithName:[attributeDict objectForKey:@"name"] icon:[attributeDict objectForKey:@"icon-name"] displayText:[attributeDict objectForKey:@"display-text"]];
        [configSubtype.sublists addObject:sublist];
        [sublist release];
        
    }
    
    if ([elementName isEqualToString:@"subtype"]) {
        
        ConfigSubtype *configSubtype = [[ConfigSubtype alloc] initWithEntity:[attributeDict objectForKey:@"entity"]];
        if ([attributeDict objectForKey:@"icon-name"] != nil) {
            configSubtype.iconName = [attributeDict objectForKey:@"icon-name"];
        }
        if ([attributeDict objectForKey:@"name"] != nil) {
            configSubtype.name = [attributeDict objectForKey:@"name"];
        }
        configSubtype.displayText = [attributeDict objectForKey:@"display-text"];
        configSubtype.secondaryText = [attributeDict objectForKey:@"secondary-text"];
        if ([attributeDict objectForKey:@"group-by"] != nil) {
            configSubtype.groupBy = [attributeDict objectForKey:@"group-by"];
        }
        if ([attributeDict objectForKey:@"order-field"] != nil) {
            if ([[attributeDict objectForKey:@"order-field"] rangeOfString:@":"].location == NSNotFound) { // Bug #5441
                configSubtype.orderField = [attributeDict objectForKey:@"order-field"];
            }
        }
        if ([attributeDict objectForKey:@"can-create"]!=nil) {
            if ([[attributeDict objectForKey:@"can-create"] caseInsensitiveCompare:@"NO"] == NSOrderedSame) {
                configSubtype.canCreate = NO;
            }
        }
        if ([attributeDict objectForKey:@"order-ascending"] != nil) {
            configSubtype.orderAscending = ![[[attributeDict objectForKey:@"order-ascending"] uppercaseString]isEqualToString:@"NO"];
        }
        if ([attributeDict objectForKey:@"depend-field"] != nil && [attributeDict objectForKey:@"depend-value"] != nil) {
            NSObject <Criteria> *criteria = [ValuesCriteria criteriaWithColumn:[attributeDict objectForKey:@"depend-field"] value:[attributeDict objectForKey:@"depend-value"]];
            configSubtype.name = [attributeDict objectForKey:@"depend-value"];
            [configSubtype.criterias addObject:criteria];
        }
         
        [self.configuration.subtypes addObject:configSubtype];
        [configSubtype release];
    }
    
    if ([elementName isEqualToString:@"criteria"]) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        NSString *field = [attributeDict objectForKey:@"field"];
        NSObject <Criteria> *criteria = nil;
        if ([self.currentAttributes objectForKey:@"different"] != nil) {
            criteria = [[NotInCriteria alloc] initWithColumn:field values:[NSArray arrayWithObject:[self.currentAttributes objectForKey:@"different"]]];
        } else {
            criteria = [ValuesCriteria criteriaWithColumn:field value:[self.currentAttributes objectForKey:@"value"]];
        }
        [configSubtype.criterias addObject:criteria];
    }
    
    if ([elementName isEqualToString:@"action"]) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        NSString *actionName = [attributeDict objectForKey:@"name"];
        Action *action = [[Action alloc] initWithName:actionName];
        action.entity = [attributeDict objectForKey:@"target-entity"];
        NSString *strclone = [attributeDict objectForKey:@"clone"]==nil?@"":[attributeDict objectForKey:@"clone"];
        action.clone = [strclone caseInsensitiveCompare:@"YES"] == NSOrderedSame;
        NSString *strUpdate = [attributeDict objectForKey:@"update"]==nil?@"":[attributeDict objectForKey:@"update"];
        action.update = [strUpdate caseInsensitiveCompare:@"YES"] == NSOrderedSame;
        [configSubtype.actions addObject:action];
        [action release];
    }
    if ([elementName isEqualToString:@"icons"]) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        configSubtype.iconField = [attributeDict objectForKey:@"icon-field"];
    }
    if ([elementName isEqualToString:@"filter-set"]) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        configSubtype.filterField = [attributeDict objectForKey:@"field"];
    }
    if ([elementName isEqualToString:@"page"]) {
        Page *page = [[Page alloc] initWithName:[attributeDict objectForKey:@"name"]];
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        [configSubtype.detailLayout.pages addObject:page];
        [page release];
    }
    
    if ([elementName isEqualToString:@"section"] && [self.level intValue] == 6) {
        Section *section = [[Section alloc] initWithName:[attributeDict objectForKey:@"name"]];
        NSString *isgroup = [attributeDict objectForKey:@"grouping"]==nil?@"":[attributeDict objectForKey:@"grouping"];
        if ([isgroup caseInsensitiveCompare:@"yes"] == NSOrderedSame) {
            section.isGrouping = YES;
        }
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        Page *page = [configSubtype.detailLayout.pages lastObject];
        [page.sections addObject:section];
        [section release];
    }
    if ([elementName isEqualToString:@"section"] && [self.level intValue] == 5) {
        Section *section = [[Section alloc] initWithName:[attributeDict objectForKey:@"name"]];
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        [configSubtype.pdfLayout.sections addObject:section];
        [section release];
    }

    [self.currentText release];
    self.currentText = [[NSMutableString alloc] init];
    
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    // entity fields
    if ([elementName isEqualToString:@"field"] && [self.level intValue] == 4) {
        ConfigEntity *configEntity = [self.configuration.entities lastObject];
        if ([configEntity.fields indexOfObject:self.currentText] == NSNotFound) {
            [configEntity.fields addObject:self.currentText];
        }
    }
    // disabled relations
    if ([elementName isEqualToString:@"disabled-relation"]) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        [configSubtype.disabledRelations addObject:self.currentText];
    }
    // pdf layout fields
    if ([elementName isEqualToString:@"field"] && [self.level intValue] == 6) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        Section *section = [configSubtype.pdfLayout.sections lastObject];
        [section.fields addObject:self.currentText];
    }
    // sublist fields
    if ([elementName isEqualToString:@"sublist-field"]) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        ConfigSublist *configSublist = [configSubtype.sublists lastObject];
        [configSublist.fields addObject:self.currentText];
    }
    // sublist field : compatibility with old XML version
    if ([elementName isEqualToString:@"field"] && [self.level intValue] == 5) {
        ConfigEntity *configEntity = [self.configuration.entities lastObject];
        for (ConfigSubtype *configSubtype in self.configuration.subtypes) {
            if ([configSubtype.entity isEqualToString:configEntity.name]) {
                for (ConfigSublist *configSublist in configSubtype.sublists) {
                    if ([configSublist.name isEqualToString:currentSublist]) {
                        [configSublist.fields addObject:self.currentText];
                        break;
                    }
                }
            }
        }
    }
    // layout fields
    if ([elementName isEqualToString:@"field"] && [self.level intValue] == 7) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        if ([self.currentAttributes objectForKey:@"custom-name"]!=nil) {
            [configSubtype.customNames setObject:[self.currentAttributes objectForKey:@"custom-name"] forKey:self.currentText];
        }
        if ([[self.currentAttributes objectForKey:@"readonly"] isEqualToString:@"true"]) {
            [configSubtype.readonly addObject:self.currentText];
        }
        Page *page = [configSubtype.detailLayout.pages lastObject];
        Section *section = [page.sections lastObject];
        [section.fields addObject:self.currentText];
    }
    // mandatory fields
    if ([elementName isEqualToString:@"mandatory-field"] && [self.level intValue] == 5) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        [configSubtype.mandatoryFields addObject:self.currentText];
    }
    // list icons
    if ([elementName isEqualToString:@"icon"] && [self.level intValue] == 6) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        [configSubtype.listIcons setObject:self.currentText forKey:[self.currentAttributes objectForKey:@"value"]];
    }
    // list filter
    if ([elementName isEqualToString:@"filter"]) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        ConfigFilter *configFilter = [[ConfigFilter alloc] initWithName:self.currentText];
        if ([self.currentAttributes objectForKey:@"start"] != nil && [self.currentAttributes objectForKey:@"end"] != nil) {
            configFilter.criteria = [[BetweenCriteria alloc] initWithColumn:[configSubtype filterField] start:[self.currentAttributes objectForKey:@"start"] end:[self.currentAttributes objectForKey:@"end"]];
        } else if ([self.currentAttributes objectForKey:@"different"] != nil) {
            configFilter.criteria = [[NotInCriteria alloc] initWithColumn:[configSubtype filterField] values:[NSArray arrayWithObject:[self.currentAttributes objectForKey:@"different"]]];
        } else {
            configFilter.criteria = [ValuesCriteria criteriaWithColumn:[configSubtype filterField] value:[self.currentAttributes objectForKey:@"value"]];
        }
        if ([[self.currentAttributes objectForKey:@"optional"] isEqualToString:@"YES"]) {
            configFilter.optional = YES;
        }
        [configSubtype.filters addObject:configFilter];
    }
    // action fields
    if ([elementName isEqualToString:@"set-field"]) {
        ConfigSubtype *configSubtype = [self.configuration.subtypes lastObject];
        Action *action = [configSubtype.actions lastObject];
        [action.fields setObject:self.currentText forKey:[self.currentAttributes objectForKey:@"name"]];
    }
    
    //Property    
    if ([elementName isEqualToString:@"property"]) {
        if ([self.currentAttributes objectForKey:@"name"] != nil) {
            [self.configuration.properties setObject:self.currentText forKey:[self.currentAttributes objectForKey:@"name"]];
        }
        
        // iAdsEnabled
        // mergeAddressBook
        // facebookEnabled
        // linkedinEnabled
        
    }

    [self.currentText release];
    self.currentText = [[NSMutableString alloc] init];
    self.level = [NSNumber numberWithInt:[self.level intValue] - 1];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentText appendString:string];
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Error : %@", [parseError description]);
}

- (void) dealloc
{
    [self.currentText release];
    [self.configuration release];
    [super dealloc];
}

@end
