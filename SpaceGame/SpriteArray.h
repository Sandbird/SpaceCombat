//
//  SpriteArray.h
//  SpaceGame
//
//  Created by Daniel Quek on 25/12/12.
//  Copyright (c) 2012 Daniel Quek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

@interface SpriteArray : NSObject

- (id)initWithCapacity:(int)capacity spriteFrameName:(NSString *)spriteFrameName batchNode:(CCSpriteBatchNode *)batchNode;
- (id)nextSprite;
- (CCArray *)array;

@end
