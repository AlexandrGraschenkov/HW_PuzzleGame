//
//  GamePoint.h
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GamePoint : NSObject

@property (nonatomic) int x;
@property (nonatomic) int y;

- (GamePoint *)initWithX: (int)x
                       Y: (int)y;

@end