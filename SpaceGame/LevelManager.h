//
//  LevelManager.h
//  SpaceGame
//
//  Created by Daniel Quek on 28/12/12.
//  Copyright (c) 2012 Daniel Quek. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GameStateTitle = 0,
    GameStateNormal,
    GameStateDone
} GameState;

@interface LevelManager : NSObject

@property (assign) GameState gameState;

- (int)curLevelIdx;
- (void)nextStage;
- (void)nextLevel;
- (BOOL)update;
- (float)floatForProp:(NSString *)prop;
- (NSString *)stringForProp:(NSString *)prop;
- (BOOL)boolForProp:(NSString *)prop;
- (BOOL)hasProp:(NSString *)prop;

@end
