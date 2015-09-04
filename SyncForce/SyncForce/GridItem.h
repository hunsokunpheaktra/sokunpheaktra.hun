//
//  Item.h
//  Reader
//
//  Created by Sy Pauv on 9/29/11.
//  Copyright 2011 GAEASYS. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GridItem : NSObject {
    
    NSString *entityId;			// entity id = salesforce id
	NSString *objectName;		//entity selected
    NSString *clickReason;
    
}

@property(nonatomic,retain) NSString *entityId;
@property(nonatomic,retain) NSString *objectName;
@property(nonatomic,retain) NSString *clickReason;

@end
