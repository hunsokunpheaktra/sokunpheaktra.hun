//
//  SyncListener.h
//  CRMiPad
//
//  Created by Sy Pauv Phou on 4/8/11.
//  Copyright 2011 Fellow Consulting AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SyncListener <NSObject>

- (void)syncEnd:(NSString *)error sendReport:(BOOL)sendReport;
- (void)syncStart;
- (void)syncProgress:(NSString *)entity;
- (void)syncConfig;

@end
