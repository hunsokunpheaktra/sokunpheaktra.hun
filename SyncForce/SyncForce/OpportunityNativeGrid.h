//
//  OpportunityGrid.h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountNativeGrid.h"
#import "GridItem.h"

@interface OpportunityNativeGrid : AccountNativeGrid {
    GridItem *gridItem;
}

@property (nonatomic,retain) GridItem* gridItem;

-(id)initWithGridItem:(GridItem*) pgridItem;

@end
