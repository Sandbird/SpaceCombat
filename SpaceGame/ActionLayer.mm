//
//  ActionLayer.m
//  SpaceGame
//
//  Created by Daniel Quek on 23/12/12.
//  Copyright 2012 Daniel Quek. All rights reserved.
//

#import "ActionLayer.h"
#import "Common.h"
#import "SimpleAudioEngine.h"
#import "SpriteArray.h"
#import "CCParallaxNode-Extras.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "GameObject.h"
#import "ShapeCache.h"
#import "SimpleContactListener.h"

#define kCategoryShip 0x1
#define kCategoryShipLaser 0x2
#define kCategoryEnemy 0x4
#define kCategoryPowerup 0x8

@implementation ActionLayer {
    CCLabelBMFont *_titleLabel1;
    CCLabelBMFont *_titleLabel2;
    CCMenuItemLabel *_playItem;
    CCSpriteBatchNode *_batchNode;
    GameObject *_ship;
    float _shipPointsPerSecY;
    double _nextAsteroidSpawn;
    SpriteArray *_asteroidsArray;
    SpriteArray *_laserArray;
    CCParallaxNode * _backgroundNode;
    CCSprite * _spacedust1;
    CCSprite * _spacedust2;
    CCSprite * _planetsunrise;
    CCSprite * _galaxy;
    CCSprite * _spacialanomaly;
    CCSprite * _spacialanomaly2;
    b2World *_world;
    GLESDebugDraw *_debugDraw;
    b2ContactListener *_contactListener;
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

- (void)invisNode:(GameObject *)sender {
    [sender destroy];
}

-(void)spawnShip {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    _ship = [[GameObject alloc]initWithSpriteFrameName:@"SpaceFlier_sm_1.png"
                                                 world:_world
                                             shapeName:@"SpaceFlier_sm_1"
                                                 maxHp:10];
    
    _ship.position = ccp(-_ship.contentSize.width/2, winSize.height * 0.5);
    [_ship revive];
    
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

-(void)setupArrays {
    _asteroidsArray = [[SpriteArray alloc]initWithCapacity:15
                                           spriteFrameName:@"asteroid.png"
                                                 batchNode:_batchNode
                                                     world:_world
                                                 shapeName:@"asteroid"
                                                     maxHp:1];
    
    _laserArray = [[SpriteArray alloc]initWithCapacity:15
                                       spriteFrameName:@"laserbeam_blue.png"
                                             batchNode:_batchNode
                                                 world:_world
                                             shapeName:@"laserbeam_blue"
                                                 maxHp:1];
}

-(void)setupBackground {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // Create the CCParallaxNode
    _backgroundNode = [CCParallaxNode node];
    [self addChild:_backgroundNode z:-2];
    
    // create the sprites you add to the CC ParallaxNode
    _spacedust1 = [CCSprite spriteWithFile:@"bg_front_spacedust.png"];
    _spacedust2 = [CCSprite spriteWithFile:@"bg_front_spacedust.png"];
    _planetsunrise = [CCSprite spriteWithFile:@"bg_planetsunrise.png"];
    _galaxy = [CCSprite spriteWithFile:@"bg_galaxy.png"];
    _spacialanomaly = [CCSprite spriteWithFile:@"bg_spacialanomaly.png"];
    _spacialanomaly2 = [CCSprite spriteWithFile:@"bg_spacialanomaly2.png"];

    // Determine relative movement speeds for spce dust and background
    CGPoint dustSpeed = ccp (0.1, 0.1);
    CGPoint bgSpeed = ccp(0.05, 0.05);
    
    //add children to CCParallaxNode
    [_backgroundNode addChild:_spacedust1
                            z:0
                parallaxRatio:dustSpeed
               positionOffset:ccp(0, winSize.height/2)];
    [_backgroundNode addChild:_spacedust2
                            z:0
                parallaxRatio:dustSpeed
               positionOffset:ccp(_spacedust1.contentSize.width * _spacedust1.scale, winSize.height/2)];
    [_backgroundNode addChild:_galaxy
                            z:-1
                parallaxRatio:bgSpeed
               positionOffset:ccp(0,winSize.height * 0.7)];
    [_backgroundNode addChild:_planetsunrise
                            z:-1
                parallaxRatio:bgSpeed
               positionOffset:ccp(600, winSize.height * 0)];
    [_backgroundNode addChild:_spacialanomaly z:-1
                parallaxRatio:bgSpeed
               positionOffset:ccp(900,winSize.height * 0.3)];
    [_backgroundNode addChild:_spacialanomaly2 z:-1
                parallaxRatio:bgSpeed
               positionOffset:ccp(1500,winSize.height * 0.9)];
}

-(void)setupWorld {
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    _world = new b2World(gravity);
    _contactListener = new SimpleContactListener(self);
    _world->SetContactListener(_contactListener);
}

-(void)setupDebugDraw {
    _debugDraw = new GLESDebugDraw(PTM_RATIO);
    _world->SetDebugDraw(_debugDraw);
    _debugDraw->SetFlags(b2Draw::e_shapeBit | b2Draw::e_jointBit);
}

-(void)testBox2D {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(winSize.width/2/PTM_RATIO,winSize.height/2/PTM_RATIO);
    
    b2Body *body = _world->CreateBody(&bodyDef);
    
    b2CircleShape circleShape;
    circleShape.m_radius = 0.25;
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circleShape;
    fixtureDef.density = 1.0;
    body->CreateFixture(&fixtureDef);
    
    body->ApplyAngularImpulse(0.01);
}

-(void)setupShapeCache {
    [[ShapeCache sharedShapeCache] addShapesWithFile:@"Shapes.plist"];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupWorld];
        [self setupDebugDraw];
//        [self testBox2D];
        [self setupShapeCache];
        
        [self setupTitle];
        [self setupSound];
        [self setupStars];
        [self setupBatchNode];
        [self setAccelerometerEnabled:YES];
        [self scheduleUpdate];
        [self setupArrays];
        [self setTouchEnabled:YES];
        [self setupBackground];

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

-(void)updateAsteriods:(ccTime)dt {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    //Is it time to spawn an asteroid?
    double curTime = CACurrentMediaTime();
    if (curTime > _nextAsteroidSpawn) {
        //Figure out the next time to spawn an asteroid
        float randSecs = randomValueBetween(0.20, 1.0);
        _nextAsteroidSpawn = randSecs + curTime;
        
        //Figure out a rand Y value to spawn at
        float randY = randomValueBetween(0.0, winSize.height);
        
        //Figure out a random amount of time to move from right to left
        float randDuration = randomValueBetween(2.0, 10.0);
        
        //Create a new asteroid sprite
        GameObject *asteroid = [_asteroidsArray nextSprite];
        [asteroid stopAllActions];
        asteroid.visible = YES;
        
        asteroid.position = ccp(winSize.width+asteroid.contentSize.width/2, randY);
        
        //set size to be one of 3 random sizes
        int randNum = arc4random() % 3;
        if (randNum == 0) {
            asteroid.scale = 0.25;
            asteroid.maxHp = 2;
        } else if (randNum == 1) {
            asteroid.scale = 0.5;
            asteroid.maxHp = 4;
        } else {
            asteroid.scale = 1.0;
            asteroid.maxHp = 6;
        }
        [asteroid revive];
        
        [asteroid runAction:[CCSequence actions:
                             [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-asteroid.contentSize.width, 0)],
                             [CCCallFuncN actionWithTarget:self selector:@selector(invisNode:)],
                             nil]];
    }
}

-(void)beginContact:(b2Contact *)contact {
    b2Fixture *fixtureA = contact->GetFixtureA();
    b2Fixture *fixtureB = contact->GetFixtureB();
    b2Body *bodyA = fixtureA->GetBody();
    b2Body *bodyB = fixtureB->GetBody();
    GameObject *spriteA = (__bridge GameObject *) bodyA->GetUserData();
    GameObject *spriteB = (__bridge GameObject *) bodyB->GetUserData();
    if (!spriteA.visible || !spriteB.visible) return;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    if ((fixtureA->GetFilterData().categoryBits &
         kCategoryShipLaser &&
         fixtureB->GetFilterData().categoryBits &
         kCategoryEnemy) ||
        (fixtureB->GetFilterData().categoryBits &
         kCategoryShipLaser &&
         fixtureA->GetFilterData().categoryBits &
         kCategoryEnemy))
    {
        // Determine enemy ship and laser
        GameObject *enemyShip = (GameObject*) spriteA;
        GameObject *laser = (GameObject *) spriteB;
        if (fixtureB->GetFilterData().categoryBits &
            kCategoryEnemy) {
            enemyShip = (GameObject*) spriteB;
            laser = (GameObject*) spriteA;
        }
        // Make sure not already dead
        if (!enemyShip.dead && !laser.dead) {
            [enemyShip takeHit];
            [laser takeHit];
            if ([enemyShip dead]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_large.caf"
                                                       pitch:1.0f pan:0.0f gain:0.25f];
            } else {
                [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_small.caf"
                                                       pitch:1.0f pan:0.0f gain:0.25f];
            }
        }
    }
}

-(void)endContact:(b2Contact *)contact {
    
}

-(void)updateCollisions:(ccTime)dt {
    for (CCSprite *laser in _laserArray.array) {
        if (!laser.visible) continue;
        
        for (CCSprite *asteroid in _asteroidsArray.array) {
            if (!asteroid.visible) continue;
            
            if (CGRectIntersectsRect(asteroid.boundingBox, laser.boundingBox)) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_large.caf"
                                                       pitch:1.0f pan:0.0f gain:0.25f];
                asteroid.visible = NO;
                laser.visible = NO;
                break;
            }
        }
    }
}

-(void)updateBackground:(ccTime)dt {
    CGPoint backgroundScrollVel = ccp(-1000, 0);
    _backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, dt));
}

- (void)visit {
    [super visit];
    NSArray *spaceDusts = @[_spacedust1, _spacedust2];
    for (CCSprite *spaceDust in spaceDusts) {
        if ([_backgroundNode
             convertToWorldSpace:spaceDust.position].x < -
            spaceDust.contentSize.width/2*self.scale) {
            [_backgroundNode
             incrementOffset:ccp(2*spaceDust.contentSize.width*
                                 spaceDust.scale,0)
             forChild:spaceDust];
        }
    }
    NSArray *backgrounds = @[_planetsunrise, _galaxy, _spacialanomaly,
    _spacialanomaly2];
    for (CCSprite *background in backgrounds) {
        if ([_backgroundNode
             convertToWorldSpace:background.position].x < -
            background.contentSize.width/2*self.scale) {
            [_backgroundNode incrementOffset:ccp(2000,0)
                                    forChild:background];
        }
    }
}

- (void)updateBox2D:(ccTime)dt {
    _world->Step(dt, 1, 1);
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            GameObject *sprite =
            (__bridge GameObject *)b->GetUserData();
            b2Vec2 b2Position =
            b2Vec2(sprite.position.x/PTM_RATIO,
                   sprite.position.y/PTM_RATIO);
            float32 b2Angle =
            -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
            b->SetTransform(b2Position, b2Angle);
        }
    }
}

- (void)update:(ccTime)dt {
    [self updateShipPos:dt];
    [self updateAsteriods:dt];
//    [self updateCollisions:dt];
    [self updateBackground:dt];
    [self updateBox2D:dt];
}

#pragma mark - Debug Drawing

-(void)draw
{
    [super draw];
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
    kmGLPushMatrix();
//    _world->DrawDebugData();
    kmGLPopMatrix();
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
//    float accelY = rollingY;
//    float accelZ = rollingZ;
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

#pragma mark - Touches

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"laser_ship.caf" pitch:1.0f pan:0.0f gain:0.25f];
    
    GameObject *shipLaser = [_laserArray nextSprite];
    [shipLaser stopAllActions];    
    shipLaser.position = ccpAdd(_ship.position, ccp(shipLaser.contentSize.width/2, 0));
    [shipLaser revive];
    
    [shipLaser runAction:[CCSequence actions:
                          [CCMoveBy actionWithDuration:0.5
                                              position:ccp(winSize.width, 0)],
                          [CCCallFuncN actionWithTarget:self
                                               selector:@selector(invisNode:)],
                          nil]];
}


@end
