//
//  Formula.h
//  CRMiOS
//
//  Created by Arnaud on 1/14/13.
//  Copyright (c) 2013 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@protocol Formula <NSObject>

- (NSString *)evaluateWithItem:(Item *)item;

@end
