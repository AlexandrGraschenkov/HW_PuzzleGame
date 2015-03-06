//
//  Game.m
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import "Game.h"
#import "NetManager.h"

@interface Game () {
    NSArray *dataArray;
    GameProperties *properties;
    GamePoint *emptyPoint;
    int stepsCount;
    
}

typedef enum int16_t {
    StartBorderLeft,
    StartBorderRight,
    StartBorderTop,
    StartBorderBottom
}StartBorder;

@end

@implementation Game

+ (instancetype)sharedInstance
{
    static id _game = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _game = [[self alloc] init];
    });
    return _game;
}

- (void)getTitlesOfImages: (void(^)(NSArray *))completion
{
    [[NetManager sharedInstance] getTitles:^(NSArray *arr, NSError *error) {
        if (!error) {
            dataArray = arr;
            NSMutableArray *titles = [NSMutableArray new];
            for (NSDictionary *dict in dataArray) {
                [titles addObject:dict[@"folder_name"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(titles);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];
}

- (NSArray *)getDataArray
{
    return dataArray;
}

- (GameProperties *)getGameProperties
{
    return properties;
}

- (GamePoint *)getEmptyPoint
{
    return emptyPoint;
}

#pragma mark Point Calculations

- (NSArray *)getAvailiablePointsFromCurrent: (GamePoint *)currentPoint
{
    NSMutableArray *points = [NSMutableArray new];
    if (currentPoint.x - 1 >= 0) [points addObject:[[GamePoint alloc] initWithX:currentPoint.x - 1 Y:currentPoint.y]];
    if (currentPoint.y - 1 >= 0) [points addObject:[[GamePoint alloc] initWithX:currentPoint.x Y:currentPoint.y - 1]];
    if (currentPoint.x + 1 < properties.columnsCount) [points addObject:[[GamePoint alloc] initWithX:currentPoint.x + 1 Y:currentPoint.y]];
    if (currentPoint.y + 1 < properties.rowsCount) [points addObject:[[GamePoint alloc] initWithX:currentPoint.x Y:currentPoint.y + 1]];
    return points;
}

- (GamePoint *)getGamePointFromCGPoint: (CGPoint)point
{
    GamePoint *gamePoint = [GamePoint new];
    gamePoint.y = (int)(point.y / properties.elemHieght);
    gamePoint.x = (int)(point.x / properties.elemWidth);
    return gamePoint;
}

- (CGPoint)getCGPointFromGamePoint: (GamePoint *)gamePoint
{
    int x = gamePoint.x * properties.elemWidth;
    int y = gamePoint.y * properties.elemHieght;
    return CGPointMake((float)x, (float)y);
}

- (NSMutableArray *)generateHidingPath
{
    NSMutableArray *generatedPathOfPoints = [NSMutableArray new];
    [generatedPathOfPoints addObject:properties.startPoint];
    GamePoint *currentPoint = properties.startPoint;
    GamePoint *previousPoint = nil;
    GamePoint *selectedPoint;
    for (int k = stepsCount - 1; k > 0; k--) {
        NSArray *points = [self getAvailiablePointsFromCurrent:currentPoint];
        selectedPoint = points[arc4random_uniform((int)points.count)];
        if (previousPoint) {
            while (selectedPoint.x == previousPoint.x && selectedPoint.y == previousPoint.y) {
                selectedPoint = points[arc4random_uniform((int)points.count)];
            }
        }
        [generatedPathOfPoints addObject:selectedPoint];
        previousPoint = currentPoint;
        currentPoint = selectedPoint;
    }
    emptyPoint = [generatedPathOfPoints lastObject];
    return generatedPathOfPoints;
}

#pragma mark Game Settings

- (void)setupGameWithImageNamed: (NSString *)name
{
    properties = [[GameProperties alloc] initPropertiesWithImageNamed:name];
    [self generateStartPosition];
    stepsCount = arc4random_uniform(properties.rowsCount * properties.columnsCount - 1);
    while (stepsCount < 4) {
        stepsCount = arc4random_uniform(properties.rowsCount * properties.columnsCount - 1);
    }
}

- (void)generateStartPosition
{
    StartBorder startBorder = (StartBorder)arc4random_uniform(3);
    int positionInBorder;
    switch (startBorder) {
        case StartBorderLeft: {
            positionInBorder = arc4random_uniform(properties.rowsCount - 1);
            properties.startPoint = [[GamePoint alloc] initWithX:0 Y:positionInBorder];
            break;
        }
        case StartBorderRight: {
            positionInBorder = arc4random_uniform(properties.rowsCount - 1);
            properties.startPoint = [[GamePoint alloc] initWithX:properties.columnsCount - 1 Y:positionInBorder];
            break;
        }
        case StartBorderTop: {
            positionInBorder = arc4random_uniform(properties.columnsCount - 1);
            properties.startPoint = [[GamePoint alloc] initWithX:positionInBorder Y:0];
            break;
        }
        case StartBorderBottom: {
            positionInBorder = arc4random_uniform(properties.columnsCount - 1);
            properties.startPoint = [[GamePoint alloc] initWithX:positionInBorder Y:properties.rowsCount - 1];
            break;
        }
    }
}

@end
