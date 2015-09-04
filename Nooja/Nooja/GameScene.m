//
//  GameScene.m
//  Nooja
//
//  Created by Arnaud Marguerat on 4/18/12.
//  Copyright (c) 2012 Fellow Consulting. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

- (id)init {
    self = [super init];
    BackgroundLayer *background = [[BackgroundLayer alloc] init];
    [self addChild:background];

    GameLayer *game = [[GameLayer alloc] init];
    [self addChild:game];
    
    return self;
}

@end
