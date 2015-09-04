//
//  HelloWorldLayer.m
//  Nooja
//
//  Created by Arnaud Marguerat on 4/18/12.
//  Copyright Fellow Consulting 2012. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "GameScene.h"
#import "EndGameScence.h"

@implementation GameLayer

@synthesize fishes;

// on "init" you need to initialize your instance
// tags : 
//   1-3    = waves
//   4      = player
//   5-8    = fishes
//   9      = music
//   10-13  = plouf
//   14     = cristal
//   15-17  = chain
//   18-20  = combo
//   21-23  = lose

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"poissons game avec piano.mp3"];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = .9;
        
        self.fishes = [[NSMutableArray alloc] initWithCapacity:4];
        fishCatch = [[NSMutableArray alloc] initWithCapacity:1];
        fishLost = [[NSMutableArray alloc] initWithCapacity:1];
        self->difficulty = 1;
        self->chainTimer = malloc(sizeof(CGFloat) * 3);
        chainTimer[0] = 0; chainTimer[1] = 0;
        self->chainX = malloc(sizeof(CGFloat) * 3);
        self->chainCpt = malloc(sizeof(int) * 3);
        chainCpt[0] = 0; chainCpt[1] = 0;
        self->cristalVisible = NO;
        self->cristalTimer = 1.5;
        self->nextGroup = 1;
        self->success = 0;
        self->targetX = 0.5f;
        self->playerX = targetX;
        self->playerAmp = 0;
        self->musicTimer = 0;
        
        for (int i = 0; i < 4; i++) {
            Fish *fish = [[[Fish alloc] init] autorelease];
            fish.type = 0;
            [self->fishes addObject:fish];
        }
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *barTime = [CCSprite spriteWithFile:@"BarBackground.png"];
        barTime.scaleX = winSize.width / 550;
        barTime.scaleY = winSize.height / 350;
        barTime.position = ccp(winSize.width*.9 , winSize.height*.6);
        [self addChild:barTime];
        
        CCSprite *timeLost= [CCSprite spriteWithFile:@"Progressbar.png"];
        timeLost.tag = 32;
        timeLost.opacity = 120;
        timeLost.scaleX = winSize.width / 550;
        timeLost.scaleY = winSize.height / 350;
        timeLost.position = ccp(winSize.width*.9 , (winSize.height*.6));
        [self addChild:timeLost];
        
        timerValue = [CCProgressTimer progressWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"Progressbar.png"]];
        timerValue.scaleX = winSize.width / 550;
        timerValue.scaleY = winSize.height / 350;
        timerValue.position = ccp(winSize.width*.9 , (winSize.height*.6));
        timerValue.type = kCCProgressTimerTypeVerticalBarBT;
        [timerValue runAction:[CCProgressFromTo actionWithDuration:40.f from:100 to:0]];
        [self addChild:timerValue];
        
        CCSprite *barScore = [CCSprite spriteWithFile:@"BarBackground.png"];
        barScore.position = ccp(winSize.width*.1 , (winSize.height*.6)-1);
        barScore.scaleX = winSize.width / 550;
        barScore.scaleY = winSize.height / 350;
        [self addChild:barScore];
        
        score = [CCProgressTimer progressWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"Progressbar.png"]];
        score.position = ccp(winSize.width*.1 , (winSize.height*.6)-1);
        score.scaleX = winSize.width / 550;
        score.scaleY = winSize.height / 350;
        score.type = kCCProgressTimerTypeVerticalBarBT;
        score.percentage = 0;
        [self addChild:score];
        
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:@"" fontName:@"FrankfurterDEE" fontSize:winSize.width/30];
        scoreLabel.tag = 30;
        scoreLabel.visible = NO;
        scoreLabel.position = CGPointMake((winSize.width*.1)+6 , winSize.height*.6);
        [self addChild:scoreLabel];
        
        CCLabelTTF *comboScore = [CCLabelTTF labelWithString:@"" fontName:@"FrankfurterDEE" fontSize:winSize.width/30];
        comboScore.tag = 31;
        comboScore.visible = NO;
        comboScore.position = CGPointMake((winSize.width*.1)+6 , winSize.height*.55);
        [self addChild:comboScore];
        
        for (int i = 0; i < 3; i++) {
            
            CCSprite *wave= [CCSprite spriteWithFile:@"waves.png"];
            wave.tag = i + 1;
            //wave.position = ccp(winSize.width*(7+i)/16 , winSize.height*(2 - i)/14);
            wave.scaleX = winSize.width/800;
            wave.scaleY = winSize.height/400;
            wave.color = ccc3(175 +i * 40, 128 + i * 63, 175 +i * 40);
            [self addChild:wave];
            
            if (i == 1) {
                for (int i = 0; i < 4; i++) {
                    CCSprite *fish = [CCSprite spriteWithFile:[NSString stringWithFormat:@"fish%d.png", (i+1)]];
                    fish.scaleX = winSize.width/1600;
                    fish.scaleY = winSize.height/1200;
                    fish.tag = 5 + i;
                    [self addChild:fish];
                    
                    CCSprite *plouf = [CCSprite spriteWithFile:@"plouf.png"];
                    plouf.scaleX = winSize.width/1000;
                    plouf.scaleY = winSize.height/600;
                    plouf.tag = 10 + i;
                    plouf.visible = NO;
                    [self addChild:plouf];
                }
                
                CCSprite *cristal = [CCSprite spriteWithFile:@"cristal.png"];
                cristal.scaleX = winSize.width/1500;
                cristal.scaleY = winSize.height/1100;
                cristal.tag = 14;
                [self addChild:cristal];
                 
                CCSprite *player = [CCSprite spriteWithFile:@"player.png"];
                player.scaleX = winSize.width/1000;
                player.scaleY = winSize.height/800;
                player.tag = 4;
                [self addChild:player];
                
                CCSprite *music = [CCSprite spriteWithFile:@"music.png"];
                music.scaleX = winSize.width/1200;
                music.scaleY = winSize.height/800;
                music.tag = 9;
                music.visible = NO;
                [self addChild:music];
            }	
        }
    
        for (int j = 0; j < 3; j++) {   
            NSString *file = @"chaine.png";
            if (j == 1) file = @"combo.png";
            if (j == 2) file = @"lose.png";
            
            CCSprite *chain = [CCSprite spriteWithFile:file];
            chain.scaleX = winSize.width/1800;
            chain.scaleY = winSize.height/1200;
            chain.tag = 15 + j * 3;
            chain.visible = NO;
            [self addChild:chain];
            
            for (int i = 0; i < 2; i++) {
                CCLabelTTF *chainText = [CCLabelTTF labelWithString:j == 1 ? @"Combo" : @"Chaîne" fontName:@"FrankfurterDEE" fontSize: winSize.width/40];
                if (j == 2 && i == 1) {
                    [chainText setString:@"perdue"];
                }
                chainText.tag = 16 + i + j * 3;
                chainText.visible = NO;
                chainText.rotation = -10;
                [self addChild:chainText];
            }
        }
        self.isTouchEnabled = YES;
        [self schedule:@selector(update:)];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	free(chainTimer);
    free(chainX);
    free(chainCpt);
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (void)afterAnimation:(id)sender{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelTTF *scoreLabel = (CCLabelTTF*)[self getChildByTag:30];
    
    scoreLabel.position = CGPointMake(scoreLabel.position.x, winSize.height*.6);
    
    [scoreLabel stopAllActions];
    scoreLabel.string = @"";
    
}

- (void)endAnimation:(id)sender{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelTTF *comboText = (CCLabelTTF*)[self getChildByTag:31];
    
    comboText.position = CGPointMake(comboText.position.x, winSize.height*.55);
    [comboText stopAllActions];
    comboText.string = @"";
    
}

-(void)update:(ccTime)deltaTime {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    // update all the timers
    time += deltaTime;
    // player oscillation
    if (playerAmp > 0) {
        playerOsc += deltaTime;
        playerAmp -= deltaTime * 3;
    } else {
        playerOsc = 0;
    }
    // cristal
    if (cristalVisible == NO) {
        if (cristalTimer > 0) {
            cristalTimer -= deltaTime;
        } else {
            cristalVisible = YES;
            do {
                cristalX = (arc4random()%100) * 0.008 + 0.1;
            } while (fabs(cristalX - playerX) < .3);
            cristalAmp = 8; 
        }
    }
    if (cristalAmp > 0) {
        cristalOsc += deltaTime;
        cristalAmp -= deltaTime * 20;
    } else {
        cristalOsc = 0;
    }
    // chain
    for (int j = 0; j < 3; j++) {
        if (chainTimer[j] > 0) {
            chainTimer[j] -= deltaTime;
        }
    }
    // music
    if (musicTimer > 0) {
        musicTimer -= deltaTime;
        
    }
    
    // fishes
    if ([self fishCount] == 0) {
        self->nextGroup -= deltaTime;
        if (self->nextGroup < 0) {
            self->success = 0;
            chainBroken = NO;
            for (int i = 0; i < MIN(4, self->difficulty); i++) {
                for (Fish *fish in self->fishes) {
                    if (fish.type == 0) {
                        fish.bounce = arc4random()%2 + 1;
                        fish.position = -i * 0.25;
                        fish.sourceX = (arc4random()%100) / 400.0;
                        fish.targetX = fish.sourceX + 0.4 + (arc4random()%100) / 800.0;
                        fish.type = 1;
                        break;
                    }
                }
            }
        }
    }
    
    // player movement
    CGFloat dx = targetX - playerX;
    if (dx > 20) dx = 20;
    if (dx < - 20) dx = -20;
    playerX += dx * 20 * deltaTime;
    
    CCLabelTTF *scoreLabel = (CCLabelTTF*)[self getChildByTag:30];
    scoreLabel.visible = YES;
    NSString *musicName = @"";
    
    // Fish movement
    for (Fish *fish in self->fishes) {
        
        int index = [self->fishes indexOfObject:fish]+1;
        
        if (fish.type != 0) {
            fish.position += deltaTime * (.6 + difficulty * .01);
            if (fish.position > 1 && fish.bounce > 0) {
                // missed a fish
                if (chainBroken == FALSE) {
                    
                    [fishLost addObject:[NSNumber numberWithInt:index]];
                    
                    chainBroken = YES;   
                    chainCpt[0] = 0;
                    chainCpt[1] = 0;
                    
                    if (arc4random() % 2 == 0) musicName = @"cassure chaine.wav";
                    else musicName = @"cassure chaine 2.wav";
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:musicName];
                    scoreLabel.string = score.percentage > 0 ? @"-10" : @"";
                    score.percentage -= 5;
                    
                    CCSequence *sequence = 
                        [CCSequence actions:[CCMoveTo actionWithDuration:.4 position:CGPointMake(scoreLabel.position.x, winSize.height*.55)],[CCCallFunc actionWithTarget:self selector:@selector(afterAnimation:)],nil];
                    [scoreLabel stopAllActions];
                    [scoreLabel runAction:sequence];
                    
                    if (difficulty > 1) {
                        chainTimer[2] = 1;
                        chainX[2] = [fish getX];
                    }              
                    difficulty = 1;
                }
            }
            if (fish.position > 1.5 || [fish getX] > 1.1) {
                fish.type = 0;
                if ([self fishCount] == 0) {
                    nextGroup += 0.2 + (arc4random()%100) * 0.005;
                }
            }
            if (fish.position > .94 && fish.position < .98 && [fish getX] > playerX - .12 && [fish getX] < playerX + .12) {
                
                [fishCatch addObject:[NSNumber numberWithInt:index]];
                
                if (fishCatch.count % 4 == 0) musicName = @"POISSONS double 0.wav";
                if (fishCatch.count % 4 == 1) musicName = @"POISSONS double 1.wav";
                if (fishCatch.count % 4 == 2) musicName = @"POISSONS double 2.wav";
                if (fishCatch.count % 4 == 3) musicName = @"POISSONS triple 1.wav";
                
                [[SimpleAudioEngine sharedEngine] playEffect:musicName];
                score.percentage += 5;
                
                //display score text
                scoreLabel.string = @"+10";
                CCSequence *sequence = 
                [CCSequence actions:[CCMoveTo actionWithDuration:.4 position:CGPointMake(scoreLabel.position.x, winSize.height*.65)],[CCCallFunc actionWithTarget:self selector:@selector(afterAnimation:)],nil];
                [scoreLabel stopAllActions];
                [scoreLabel runAction:sequence];
            
                playerAmp = 3;
                fish.bounce--;
                musicCoord = CGPointMake(([fish getX] + playerX) / 2, [fish getY]);
                musicTimer = 1;
                CGFloat newPosition = 1 - fish.position;
                CGFloat newTargetX = 0.2 + (arc4random()%100) / 400.0;
                
                if (fish.bounce == 0) {
                    newTargetX += 1.5;
                    success++;
                    if (!chainBroken && success == MIN(4, difficulty)) {
                        
                        // all the fishes have bounced
                        chainTimer[0] = 1;
                        chainX[0] = playerX;
                        chainCpt[0]++;            
                        CCLabelTTF *chainText = (CCLabelTTF *) [self getChildByTag:17];
                        [chainText setString:[NSString stringWithFormat:@"x %d", chainCpt[0]]];
                        
                        score.percentage += (chainCpt[0]*2.5);
                        
                        CCLabelTTF *comboScore = (CCLabelTTF*)[self getChildByTag:31];
                        comboScore.visible = YES;
                        [comboScore setString:[NSString stringWithFormat:@"+%d", (chainCpt[0]*5)]];
                        CCSequence *sequence = 
                        [CCSequence actions:[CCMoveTo actionWithDuration:.4 position:CGPointMake(comboScore.position.x, winSize.height*.6)],[CCCallFunc actionWithTarget:self selector:@selector(endAnimation:)],nil];
                        [comboScore stopAllActions];
                        [comboScore runAction:sequence];

                        difficulty++;
                    }
                }
                
                CGFloat newSourceX = ([fish getX] - newPosition * newTargetX) / (1 - newPosition);
                fish.targetX = newTargetX;
                fish.sourceX = newSourceX;
                fish.position = newPosition;
                
            }
        }

    }
    
    // cristal
    if (cristalVisible) {
        if (cristalX > playerX - .15 && cristalX < playerX + .15) {
            cristalVisible = NO;
            cristalTimer += 1.0 + (arc4random()%100) * 0.005;
            musicCoord = CGPointMake((cristalX + playerX) / 2, 0.2);
            musicTimer = 1;
            chainTimer[1] = 1;
            chainX[1] = (playerX + cristalX) / 2;
            chainCpt[1]++;
            CCLabelTTF *chainText = (CCLabelTTF *) [self getChildByTag:20];
            [chainText setString:[NSString stringWithFormat:@"x %d", chainCpt[1]]];
        }
    }
    
    // display waves
    for (int i = 0; i < 3; i++) {
        CCSprite *wave = (CCSprite *) [self getChildByTag:i + 1];
        wave.rotation = sinf(time*4 + i) * 2;
        wave.position = ccp(winSize.width*(7+i+sinf(time*4 + i)*.1)/16 , winSize.height*(2 - i+cosf(time*4 + i)*.1)/14);
    }

    // display player
    CCSprite *player = (CCSprite *) [self getChildByTag:4];
    player.position = ccp(winSize.width * playerX , winSize.height*(10 + sinf(playerOsc * 16) * playerAmp)/100);
    
    // display cristal
    CCSprite *cristal = (CCSprite *) [self getChildByTag:14];
    cristal.visible = cristalVisible;
    cristal.position = ccp(winSize.width * cristalX , winSize.height*(10 - cosf(cristalOsc * 16) * cristalAmp)/100);

    // display fishes
    for (int i = 0; i < 4; i++) {
        CCSprite *fishSprite = (CCSprite *) [self getChildByTag:i + 5];
        CCSprite *ploufSprite = (CCSprite *) [self getChildByTag:i + 10];
        Fish *fish = [self->fishes objectAtIndex:i];
        if (fish.type != 0) {
            if (fish.position < 1) {
                fishSprite.visible = YES;
                ploufSprite.visible = NO;
                if (fish.targetX < fish.sourceX) {
                    fishSprite.flipX = YES;
                } else {
                    fishSprite.flipX = NO;
                }
                fishSprite.position = ccp(winSize.width*[fish getX] , winSize.height*[fish getY]);
            } else {
                fishSprite.visible = NO;
                ploufSprite.visible = YES;
                ploufSprite.position = ccp(winSize.width*[fish getX] , winSize.height*[fish getY]);
            }
        } else {
            fishSprite.visible = NO;
            ploufSprite.visible = NO;
        }
    }
    
    // display music
    CCSprite *music = (CCSprite *) [self getChildByTag:9];
    if (musicTimer > 0) {
        music.visible = YES;
        music.position = ccp(winSize.width * musicCoord.x , winSize.height*(musicCoord.y + (1 - musicTimer) * 0.1));
        if (musicTimer < 0.25) {
            music.opacity = musicTimer * 4 * 128;
        } else if (musicTimer > 0.75) {
            music.opacity = (1 - musicTimer) * 4 * 128;
        } else {
            music.opacity = 128;
        }
    } else {
        music.visible = NO;
    }

    // display chain and combo
    for (int j = 0; j < 3; j++) {
        CCSprite *chain = (CCSprite *) [self getChildByTag:15 + j * 3];
        if (chainTimer[j] > 0) {
            chain.visible = YES;
            chain.position = ccp(winSize.width * chainX[j], winSize.height*(0.3 + (MIN(1 - chainTimer[j], 0.5)) * .9));
            if (chainTimer[j] < 0.25) {
                chain.opacity = chainTimer[j] * 4 * 255;
            } else if (chainTimer[j] > 0.75) {
                chain.opacity = (1 - chainTimer[j]) * 4 * 255;
            } else {
                chain.opacity = 255;
            }
            for (int i = 0; i < 2; i++) {
                CCLabelTTF *chainText = (CCLabelTTF *) [self getChildByTag:16 + i + j * 3];
                chainText.visible = YES;
                chainText.position = ccp(chain.position.x, chain.position.y + (0.04 - (j == 1 ? 0.02 : 0) - i * 0.05) * winSize.height);
                chainText.opacity = chain.opacity;
            }
        } else {
            chain.visible = NO;        
            for (int i = 0; i < 2; i++) {
                CCLabelTTF *chainText = (CCLabelTTF *) [self getChildByTag:16 + i + j * 3];
                chainText.visible = NO;
            }
        }
    }
    
    //change timer bar and sound when time near end less than 20
    if(timerValue.percentage < 20 && soundEffect == 0){
        CCSprite *timeLost = (CCSprite*)[self getChildByTag:32];
        timeLost.texture = [[CCTextureCache sharedTextureCache] addImage:@"Progressbar Waring.png"];
        timerValue.sprite.texture = [[CCTextureCache sharedTextureCache] addImage:@"Progressbar WaringShow.png"];
        
        soundEffect = [[SimpleAudioEngine sharedEngine] playEffect:@"ALARM 1.wav"];
        [self performSelector:@selector(stopEffect) withObject:nil afterDelay:1.0];
    }
    
    //check time end
    if(timerValue.percentage == 0){
        [self unscheduleAllSelectors];
        [self endGame];
    }
    
}

- (void)stopEffect{
    [[SimpleAudioEngine sharedEngine] stopEffect:soundEffect];
}

- (void)endGame{
    
    EndGameScence *scence = [[EndGameScence alloc] initWithScore:(int)score.percentage fishCatched:fishCatch fishLost:fishLost];
    CCTransitionPageTurn *transition = [CCTransitionPageTurn transitionWithDuration:1.0 scene:scence];
    [[CCDirector sharedDirector] replaceScene:transition];
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
}

- (int)fishCount {
    int cpt = 0;
    for (Fish *fish in self->fishes) {
        if (fish.type != 0) {
            cpt++;
        }
    }
    return cpt;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self movePlayer:touches];
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self movePlayer:touches];  
}


- (void)movePlayer:(NSSet *)touches {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:touch.view];
    location = [[CCDirector sharedDirector] convertToGL:location];
    targetX = location.x / winSize.width;
}

@end
