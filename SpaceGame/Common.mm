//
//  Common.m
//  SpaceGame
//
//  Created by Daniel Quek on 25/12/12.
//  Copyright (c) 2012 Daniel Quek. All rights reserved.
//

#import "Common.h"

float randomValueBetween(float low, float high) {
    return (((float) arc4random() / 0xFFFFFFFFu)*(high - low)) + low;
}
