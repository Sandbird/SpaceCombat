//
//  ParticleSystemArray.h
//  SpaceGame
//
//  Created by Daniel Quek on 27/12/12.
//  Copyright (c) 2012 Daniel Quek. All rights reserved.
//

#import "cocos2d.h"

@interface ParticleSystemArray : NSObject

-(id)initWithFile:(NSString *)file capacity:(int)capacity parent:(CCNode *)parent;
-(id)nextParticleSystem;
-(CCArray *)array;

@end
