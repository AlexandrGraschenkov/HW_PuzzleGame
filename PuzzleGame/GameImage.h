//
//  GameImage.h
//  PuzzleGame
//
//  Created by Gena on 05.03.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GamePoint.h"

@interface GameImage : NSObject

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) GamePoint *position;

@end
