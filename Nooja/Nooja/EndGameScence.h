//
//  EndGameScence.h
//  Nooja
//
//  Created by Hun Sokunpheaktra on 7/13/12.
//  Copyright (c) 2012 Fellow Consulting. All rights reserved.
//

#import "CCScene.h"
#import "cocos2d.h"

@interface EndGameScence : CCScene{
    
    
}

- (id)initWithScore:(int)totalScore fishCatched:(NSArray*)fc fishLost:(NSArray*)fl;

@end
