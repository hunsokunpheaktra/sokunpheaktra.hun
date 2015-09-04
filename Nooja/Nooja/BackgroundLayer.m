//
//  BackgroundLayer.m
//  Nooja
//
//  Created by Arnaud Marguerat on 4/18/12.
//  Copyright (c) 2012 Fellow Consulting. All rights reserved.
//

#import "BackgroundLayer.h"

@implementation BackgroundLayer

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        CCSprite *background= [CCSprite spriteWithFile:@"background3.png"];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        background.position = ccp(winSize.width/2, winSize.height/2);
        background.scaleX = winSize.width/1024;
        background.scaleY = winSize.height/512;
        [self addChild:background];	

	}
	return self;
}

@end
