//
//  Sublist.h
//  CRMiOS
//
//  Created by Arnaud Marguerat on 9/25/12.
//  Copyright (c) 2012 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol Sublist <NSObject>


- (NSString *)name;
- (NSString *)displayText;
- (NSString *)icon;
- (NSArray *)fields;

@end
