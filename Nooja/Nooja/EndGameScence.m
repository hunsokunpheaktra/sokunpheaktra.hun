//
//  EndGameScence.m
//  Nooja
//
//  Created by Hun Sokunpheaktra on 7/13/12.
//  Copyright (c) 2012 Fellow Consulting. All rights reserved.
//

#import "EndGameScence.h"
#import "GameScene.h"

@interface EndGameLayer : CCLayer{
    int gameScore;
    NSArray *fishCatch;
    NSArray *fishLost;
    CGFloat time;
}
- (id)initWithScore:(int)totalScore fishCatched:(NSArray*)fc fishLost:(NSArray*)fl;
- (void)update:(ccTime)deltaTime;
- (NSString*)getRank;
@end

@implementation EndGameLayer

- (id)initWithScore:(int)totalScore fishCatched:(NSArray*)fc fishLost:(NSArray*)fl{
    
    self = [super init];
    self.isTouchEnabled = YES;
    gameScore = totalScore;
    fishCatch = fc;
    fishLost = fl;
    if(self){
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background= [CCSprite spriteWithFile:@"background3.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        background.scaleX = winSize.width/1024;
        background.scaleY = winSize.height/512;
        [self addChild:background];
        
        CCSprite *fish = [CCSprite spriteWithFile:@"fish1.png"];
        fish.position = ccp(winSize.width*.45,winSize.height*.5);
        fish.scaleX = winSize.width/300;
        fish.scaleY = winSize.height/230;
        [self addChild:fish];
        
        CCLabelTTF *score = [CCLabelTTF labelWithString:@"Game Score :" dimensions:CGSizeZero alignment:UITextAlignmentRight fontName:@"FrankfurterDEE" fontSize:winSize.width/20];
        score.position = ccp(winSize.width*.3,winSize.height*.8);
        [self addChild:score];
        
        CCLabelTTF *scoreNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",totalScore] dimensions:CGSizeZero alignment:UITextAlignmentRight fontName:@"FrankfurterDEE" fontSize:winSize.width/20];
        scoreNumber.tag = 0;
        scoreNumber.position = ccp(winSize.width*.64,winSize.height*.8);
        [self addChild:scoreNumber];
        
        CCLabelTTF *fishCatctText = [CCLabelTTF labelWithString:@"Fish Catched :" dimensions:CGSizeZero alignment:UITextAlignmentRight fontName:@"FrankfurterDEE" fontSize:winSize.width/18];
        fishCatctText.position = ccp(winSize.width*.3,winSize.height*.67);
        [self addChild:fishCatctText];
        
        CCLabelTTF *fishCatchNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",fc.count] dimensions:CGSizeZero alignment:UITextAlignmentRight fontName:@"FrankfurterDEE" fontSize:winSize.width/18];
        fishCatchNumber.position = ccp(winSize.width*.64,winSize.height*.67);
        [self addChild:fishCatchNumber];
        
        float locationX = winSize.width*.7;
        
        //fish catch sprite
        for(NSNumber *number in fishCatch){
            int index = [number intValue];
            
            CCSprite *fishSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"fish%d.png",index]];
            fishSprite.scaleX = winSize.width/2400;
            fishSprite.scaleY = winSize.height/2000;
            fishSprite.position = ccp(locationX,winSize.height*.67);
            
            if(locationX < winSize.width){
                locationX += 50;
            }else{
                locationX = winSize.width;
            }
            
            //[self addChild:fishSprite];
            
        }
        
        CCLabelTTF *fishLose = [CCLabelTTF labelWithString:@"Fish Lost :" dimensions:CGSizeZero alignment:UITextAlignmentRight fontName:@"FrankfurterDEE" fontSize:winSize.width/18];
        fishLose.position = ccp(winSize.width*.3,winSize.height*.54);
        [self addChild:fishLose];
        
        CCLabelTTF *fishLoseNumber = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",fl.count] dimensions:CGSizeZero alignment:UITextAlignmentRight fontName:@"FrankfurterDEE" fontSize:winSize.width/18];
        fishLoseNumber.position = ccp(winSize.width*.64,winSize.height*.54);
        [self addChild:fishLoseNumber];
        
        CCLabelTTF *rank = [CCLabelTTF labelWithString:@"Rank :" dimensions:CGSizeZero alignment:UITextAlignmentRight fontName:@"FrankfurterDEE" fontSize:winSize.width/18];
        rank.position = ccp(winSize.width*.3,winSize.height*.41);
        [self addChild:rank];
        
        CCLabelTTF *rankLetter = [CCLabelTTF labelWithString:[self getRank] dimensions:CGSizeZero alignment:UITextAlignmentRight fontName:@"FrankfurterDEE" fontSize:winSize.width/18];
        rankLetter.tag = 1;
        rankLetter.position = ccp(winSize.width*.64,winSize.height*.41);
        [self addChild:rankLetter];
        
        CCSprite *buttonBackground = [CCSprite spriteWithFile:@"PlayAgain.png"];
        buttonBackground.scaleX = winSize.width/600;
        buttonBackground.scaleY = winSize.height/250;
        buttonBackground.position = ccp(winSize.width*.5,winSize.height*.19);
        [self addChild:buttonBackground];
        
        CCLabelTTF *playAgain = [CCLabelTTF labelWithString:@"Play Again " dimensions:CGSizeZero alignment:UITextAlignmentCenter fontName:@"FrankfurterDEE" fontSize:winSize.width/20];
        playAgain.tag = 2;
        playAgain.position = ccp(winSize.width*.51,winSize.height*.22);
        [self addChild:playAgain];
        
        //[self schedule:@selector(update:) interval:.1];

    }
    
    return self;
    
}

- (NSString*)getRank{
    
    NSString *rank = @"";
    int b = fishCatch.count - fishLost.count;
    
    if(b < 0){
        rank = @"E";
    }else if(b < 5){
        rank = @"D";
    }else if(b < 10){
        rank = @"C";
    }else if(b < 15){
        rank = @"B";
    }else{
        rank = @"A";
    }
    
    return rank;
}

- (void)update:(ccTime)deltaTime {
    time += deltaTime;
    CCLabelTTF *scoreNumber = (CCLabelTTF*)[self getChildByTag:0];
    int score = [scoreNumber.string intValue];
    
    //score increase
    if(score < gameScore){
        score++;
        scoreNumber.string = [NSString stringWithFormat:@"%d",score];
    }
    
    //rank player
    NSString *rand = @"ABCDE";
    int index = arc4random() % 5;
    CCLabelTTF *rankLetter = (CCLabelTTF*)[self getChildByTag:1];
    if(time < 4){
        rankLetter.string = [NSString stringWithFormat:@"%c",[rand characterAtIndex:index]];
    }else if(time == 5){
        rankLetter.string = [self getRank];
    }
    
    
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    UITouch* touch = [touches anyObject];
    CCSprite *playAgain = (CCSprite*)[self getChildByTag:2];
    
    CGPoint location = [touch locationInView:touch.view];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if(CGRectContainsPoint(playAgain.boundingBox , location)){
        [self unscheduleAllSelectors];
        GameScene *scence = [[GameScene alloc] init];
        CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:scence];
        [[CCDirector sharedDirector] replaceScene:transition];
    }
    
}

@end

@implementation EndGameScence

- (id)initWithScore:(int)totalScore fishCatched:(NSArray*)fc fishLost:(NSArray*)fl{
    
    self = [super init];
    
    if(self){
        EndGameLayer *endLayer = [[EndGameLayer alloc] initWithScore:totalScore fishCatched:fc fishLost:fl];
        [self addChild:endLayer];
    }
    
    return self;
    
}

- (id)init{
    self = [super init];
    
    if(self){
        EndGameLayer *endLayer = [[EndGameLayer alloc] initWithScore:40 fishCatched:[[NSArray alloc] init] fishLost:[[NSArray alloc] init]];
        [self addChild:endLayer];
    }
    
    return self;
}


@end
