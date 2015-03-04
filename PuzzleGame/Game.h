//
//  Game.h
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameProperties.h"
#import "GamePoint.h"

@interface Game : NSObject

+ (instancetype)sharedInstance;

- (void)getTitlesOfImages: (void(^)(NSArray *))completion;
- (NSArray *)getDataArray;

- (void)setupGameWithImageNamed: (NSString *)name;

- (GameProperties *)getGameProperties;
- (NSMutableArray *)generateHidingPath;

- (GamePoint *)getGamePointFromCGPoint: (CGPoint)point;
- (CGPoint)getCGPointFromGamePoint: (GamePoint *)gamePoint;
- (GamePoint *)getEmptyPoint;

@end
