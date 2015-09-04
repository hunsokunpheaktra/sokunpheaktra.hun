//
//  SfMergeRecords.h
//  SyncForce
//
//  Created by Gaeasys on 12/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncListener.h"
#import "SyncProcess.h"
#import "EntityRequest.h"

@interface SfMergeRecords : EntityRequest {
   
    SyncProcess *synprocess;
    NSArray* listLocalRecords;
    
    NSMutableArray* array;
    NSArray *listFilter;
 
}


@property (nonatomic, retain) SyncProcess *synprocess;

@property (nonatomic, retain) NSMutableArray* array;
@property (nonatomic, retain) NSArray* listLocalRecords;


- (id)initWithSynProcess:(NSString *)newEntity listener:(SyncProcess*)newListener;
-(void) continueProcess;

@end
