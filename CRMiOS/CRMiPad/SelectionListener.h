//
//  SelectionListener.h
//  CRMiOS
//
//  Created by Sy Pauv Phou on 5/12/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SelectionListener <NSObject>

- (void)didSelect:(NSString *)field valueId:(NSString *)valueId display:(NSString *)display;

@end
