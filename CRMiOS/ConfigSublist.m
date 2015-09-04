//
//  ConfigSublist.m
//  CRMiOS
//
//  Created by Sy Pauv Phou on 10/28/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import "ConfigSublist.h"


@implementation ConfigSublist

@synthesize name;
@synthesize fields;
@synthesize displayText;
@synthesize icon;

- (id)initWithName:(NSString *)newName icon:(NSString *)newIcon displayText:(NSString *)newDisplayText {
    self = [super init];
    self.name = newName;
    self.fields = [[NSMutableArray alloc] initWithCapacity:1];
    self.icon = newIcon;
    self.displayText = newDisplayText;
    return self;
}

@end
