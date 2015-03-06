//
//  GamePoint.m
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import "GamePoint.h"

@implementation GamePoint

- (GamePoint *)initWithX: (int)x
                       Y: (int)y
{
    GamePoint *point = [GamePoint new];
    point.x = x;
    point.y = y;
    return point;
}

@end