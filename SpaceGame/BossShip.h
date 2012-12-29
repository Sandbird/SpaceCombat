//
//  BossShip.h
//  SpaceGame
//
//  Created by Daniel Quek on 29/12/12.
//  Copyright (c) 2012 Daniel Quek. All rights reserved.
//

#import "GameObject.h"

@class ActionLayer;

@interface BossShip : GameObject

-initWithWorld:(b2World *)world layer:(ActionLayer *)layer;
-(void)updateWithShipPosition:(CGPoint)shipPosition;

@end
