//
//  Item.m
//  Reader
//
//  Created by Sy Pauv 
// 
//  Used by the Datagrid - value returned when user clicks on a row
//

#import "GridItem.h"


@implementation GridItem
@synthesize entityId,objectName,clickReason;


-(id)init{						//method called for the initialization of this object
	if(self==[super init]){}
	return self;
}

-(void)dealloc{					//method called when object is released
	[entityId release];			//release each member of this object
	[objectName release];
    [clickReason release];
	[super dealloc];
}


@end
