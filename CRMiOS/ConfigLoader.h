//
//  ConfigLoader.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSXMLParser.h>
#import "DetailLayout.h"
#import "Section.h"
#import "Page.h"
#import "ConfigSubtype.h"
#import "Action.h"
#import "Configuration.h"
#import "BetweenCriteria.h"
#import "NotInCriteria.h"
#import "ConfigFilter.h"
#import "ConfigSublist.h"
#import "PropertyManager.h"

@class Configuration;

@interface ConfigLoader : NSObject<NSXMLParserDelegate> {
    NSMutableString *currentText;  
    Configuration *configuration;
    NSNumber *level;
    NSDictionary *currentAttributes;
    // for compatibility with old sublist handling
    // to remove in the future
    NSString *currentSublist;
}

@property (nonatomic, retain) NSMutableString *currentText;
@property (nonatomic, retain) Configuration *configuration;
@property (nonatomic, retain) NSNumber *level;
@property (nonatomic, retain) NSDictionary *currentAttributes;

- (Configuration *)loadConfig:(NSData *)content;


@end
