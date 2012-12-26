//
//  ActionLayer.h
//  SpaceGame
//
//  Created by Daniel Quek on 23/12/12.
//  Copyright 2012 Daniel Quek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@interface ActionLayer : CCLayer {
    
}

+(id)scene;
-(void)beginContact:(b2Contact *)contact;
-(void)endContact:(b2Contact *)contact;

@end
