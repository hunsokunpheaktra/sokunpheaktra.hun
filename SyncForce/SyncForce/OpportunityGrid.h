//
//  OpportunityGrid.h
//  SyncForce
//
//  Created by Gaeasys Admin on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountGrid.h"
#import "GridItem.h"
#import "DataModel.h"

@interface OpportunityGrid : AccountGrid {
    GridItem *gridItem;
}

@property (nonatomic,retain) GridItem* gridItem;

-(id)initWithGridItem:(GridItem*) pgridItem;

@end
