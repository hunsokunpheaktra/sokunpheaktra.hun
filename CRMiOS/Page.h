//
//  Page.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 6/24/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Page : NSObject {
    NSString *name;
    NSMutableArray *sections;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *sections;

- (id)initWithName:(NSString *)newName;

@end
