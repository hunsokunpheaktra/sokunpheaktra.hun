//
//  HelloWorldLayer.h
//  Nooja
//
//  Created by Arnaud Marguerat on 4/18/12.
//  Copyright Fellow Consulting 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "Fish.h"

// HelloWorldLayer
@interface GameLayer : CCLayer
{
    CGFloat time;
    CGFloat playerX;
    CGFloat targetX;
    CGFloat playerAmp;
    CGFloat playerOsc;
    NSMutableArray *fishes;
    CGFloat nextGroup;
    int difficulty;
    int success;
    BOOL chainBroken;
    
    // Music
    CGPoint musicCoord;
    float musicTimer;
    
    // Cristal
    BOOL cristalVisible;
    CGFloat cristalTimer;
    CGFloat cristalX;
    CGFloat cristalAmp;
    CGFloat cristalOsc;
    
    // Chain
    int *chainCpt;
    CGFloat *chainTimer;
    CGFloat *chainX;
    
    //bar timer
    CCProgressTimer *timerValue;
    CCProgressTimer *score;
    ALuint soundEffect;
    NSMutableArray *fishCatch;
    NSMutableArray *fishLost;
    
}

@property (nonatomic, retain) NSMutableArray *fishes;

- (void)update:(ccTime)deltaTime;
- (void)movePlayer:(NSSet *)touches;
- (int)fishCount;
- (void)afterAnimation:(id)sender;
- (void)endAnimation:(id)sender;
- (void)endGame;
- (void)stopEffect;

@end
