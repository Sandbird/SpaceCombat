//
//  SpriteArray.h
//  SpaceGame
//
//  Created by Daniel Quek on 25/12/12.
//  Copyright (c) 2012 Daniel Quek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "GameObject.h"

@interface SpriteArray : NSObject

- (id)initWithCapacity:(int)capacity spriteFrameName:(NSString *)spriteFrameName batchNode:(CCSpriteBatchNode *)batchNode world:(b2World *)world shapeName:(NSString *)shapeName maxHp:(int)maxHp healthBarType:(HealthBarType)healthBarType;
- (id)nextSprite;
- (CCArray *)array;

@end
