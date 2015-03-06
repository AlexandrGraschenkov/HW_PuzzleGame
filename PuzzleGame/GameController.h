//
//  GameController.h
//  PuzzleGame
//
//  Created by Gena on 03.03.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GamePoint.h"

@interface GameController : NSObject

- (void)startGame;
- (void)endGame;
- (void)setMainView: (UIView *)view;
- (void)downloadImages;

- (GamePoint *)getEmptyPoint;

- (void)moveImagesToLeftFromX: (int)fromX;
- (void)moveImagesToRightFromX: (int)fromX;
- (void)moveImagesToTopFromY: (int)fromY;
- (void)moveImagesToBottomFromY: (int)fromY;

- (BOOL)checkForGameCompleated;

@end
