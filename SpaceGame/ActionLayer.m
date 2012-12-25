//
//  ActionLayer.m
//  SpaceGame
//
//  Created by Daniel Quek on 23/12/12.
//  Copyright 2012 Daniel Quek. All rights reserved.
//

#import "ActionLayer.h"
#import "SimpleAudioEngine.h"

@implementation ActionLayer {
    CCLabelBMFont *_titleLabel1;
    CCLabelBMFont *_titleLabel2;
    CCMenuItemLabel *_playItem;
    CCSpriteBatchNode *_batchNode;
    CCSprite *_ship;
    float _shipPointsPerSecY;
}

+(id)scene {
    CCScene *scene = [CCScene node];
    ActionLayer *layer = [ActionLayer node];
    [scene addChild:layer];
    
    return scene;
}

-(void)removeNode:(CCNode *)sender {
    [sender removeFromParent];
}

-(void)spawnShip {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    _ship = [CCSprite spriteWithSpriteFrameName:@"SpaceFlier_sm_1.png"];
    _ship.position = ccp(-_ship.contentSize.width/2,
                         winSize.height * 0.5);
    [_batchNode addChild:_ship z:1];
    
    [_ship runAction:[CCSequence actions:
                      [CCEaseOut actionWithAction:[CCMoveBy actionWithDuration:0.5 position:ccp(_ship.contentSize.width/2 + winSize.width *0.3, 0)] rate:4.0],
                      [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:0.5 position:ccp(-winSize.width *0.2, 0)] rate:4.0],
                      nil]];
    
    CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCAnimation *animation = [CCAnimation animation];
    [animation addSpriteFrame:[cache spriteFrameByName:@"SpaceFlier_sm_1.png"]];
    [animation addSpriteFrame:[cache spriteFrameByName:@"SpaceFlier_sm_2.png"]];
    animation.delayPerUnit = 0.2;
    
    [_ship runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]]];
}

-(void)playTapped:(id)sender {
    [[SimpleAudioEngine sharedEngine]playEffect:@"powerup.caf"];
    NSArray *nodes = @[_titleLabel1, _titleLabel2, _playItem];
    for (CCNode *node in nodes) {
        [node runAction:[CCSequence actions:
                         [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:0] rate:4.0],
                         [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                         nil]];
    }
    
    [self spawnShip];
}

-(void)setupTitle {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *fontName = @"SpaceGameFont.fnt";
    
    _titleLabel1 = [CCLabelBMFont labelWithString:@"Space Game" fntFile:fontName];
    _titleLabel1.scale = 0;
    _titleLabel1.position = ccp(winSize.width/2, winSize.height * 0.8);
    [self addChild:_titleLabel1 z:100];
    [_titleLabel1 runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:1.0],
      [CCCallBlock actionWithBlock:^{
         [[SimpleAudioEngine sharedEngine]playEffect:@"title.caf"];
     }],
      [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:1.0 scale:0.5] rate:4.0],
      nil]];
    
    _titleLabel2 = [CCLabelBMFont labelWithString:@"Starter Kit" fntFile:fontName];
    _titleLabel2.scale = 0;
    _titleLabel2.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:_titleLabel2 z:100];
    [_titleLabel2 runAction:[CCSequence actions:
                             [CCDelayTime actionWithDuration:2.0],
                             [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:1.0 scale:1.25] rate:4.0], nil]];
    
    CCLabelBMFont *playLabel = [CCLabelBMFont labelWithString:@"Play" fntFile:fontName];
    _playItem = [CCMenuItemLabel itemWithLabel:playLabel target:self selector:@selector(playTapped:)];
    _playItem.scale = 0;
    _playItem.position = ccp(winSize.width/2, winSize.height * 0.3);
    
    CCMenu *menu = [CCMenu menuWithItems:_playItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [_playItem runAction:[CCSequence actions:
                          [CCDelayTime actionWithDuration:2.0],
                          [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:0.5] rate:4.0],
                          nil]];
}


-(void)setupSound {
    [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"SpaceGame.caf" loop:YES];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"explosion_large.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"explosion_small.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"laser_enemy.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"laser_ship.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"shake.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"powerup.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"boss.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"cannon.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"title.caf"];
}

-(void)setupStars {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    NSArray *starsArray = @[@"Stars1.plist", @"Stars2.plist", @"Stars3.plist"];
    for (NSString *stars in starsArray) {
        CCParticleSystemQuad *starsEffect = [CCParticleSystemQuad particleWithFile:stars];
        starsEffect.position = ccp(winSize.width*1.5, winSize.height/2);
        starsEffect.posVar = ccp(starsEffect.posVar.x, (winSize.height/2)*1.5);
        [self addChild:starsEffect];
    }
}

-(void)setupBatchNode {
    _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"Sprites.pvr.ccz"];
    [self addChild:_batchNode z:-1];
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"Sprites.plist"];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupTitle];
        [self setupSound];
        [self setupStars];
        [self setupBatchNode];
        [self setAccelerometerEnabled:YES];
        [self scheduleUpdate];
    }
    return self;
}

-(void)updateShipPos:(ccTime)dt
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float maxY = winSize.height - _ship.contentSize.height/2;
    float minY = _ship.contentSize.height/2;
    
    float newY = _ship.position.y + (_shipPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    _ship.position = ccp(_ship.position.x, newY);
}

- (void)update:(ccTime)dt {
    [self updateShipPos:dt];
}

#pragma mark - Apple Sample code for accelerometer

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration {
#define kFilteringFactor 0.75
    static UIAccelerationValue rollingX = 0, rollingY = 0, rollingZ = 0;
    rollingX = (acceleration.x * kFilteringFactor) +
    (rollingX * (1.0 - kFilteringFactor));
    rollingY = (acceleration.y * kFilteringFactor) +
    (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (acceleration.z * kFilteringFactor) +
    (rollingZ * (1.0 - kFilteringFactor));
    float accelX = rollingX;
    float accelY = rollingY;
    float accelZ = rollingZ;
//    NSLog(@"accelX: %f, accelY: %f, accelZ: %f",
//          accelX, accelY, accelZ);
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
#define kRestAccelX 0.6
#define kShipMaxPointsPerSec (winSize.height*0.5)
#define kMaxDiffX 0.2
    float accelDiffX = kRestAccelX - ABS(accelX);
    float accelFractionX = accelDiffX / kMaxDiffX;
    float pointsPerSecX = kShipMaxPointsPerSec * accelFractionX;
    _shipPointsPerSecY = pointsPerSecX;
}

@end
