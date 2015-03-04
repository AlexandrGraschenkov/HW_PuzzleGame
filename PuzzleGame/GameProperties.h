//
//  GameProperties.h
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GamePoint;

@interface GameProperties : NSObject

@property (nonatomic, assign) CGFloat rowsCount;
@property (nonatomic, assign) CGFloat columnsCount;
@property (nonatomic, assign) CGFloat elemWidth;
@property (nonatomic, assign) CGFloat elemHieght;
@property (nonatomic, strong) NSString *imageName;
@property GamePoint *startPoint;

- (GameProperties *)initPropertiesWithImageNamed: (NSString *)imageName;

@end