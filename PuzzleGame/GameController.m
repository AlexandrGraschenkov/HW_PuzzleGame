//
//  GameController.m
//  PuzzleGame
//
//  Created by Gena on 03.03.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "GameController.h"
#import "Game.h"
#import "GameProperties.h"
#import "GameImage.h"

@interface GameController () {
    NSArray *imagesArray;
    UIView *mainView;
    GameProperties *properties;
    NSMutableArray *generatedPathOfPoints;
    GamePoint *emptyPoint;
}

@end

@implementation GameController


- (void)setMainView: (UIView *)view
{
    mainView = view;
}

- (void)startGame
{
    [self setBordersForImagesEnabled:YES];
    generatedPathOfPoints = [[Game sharedInstance] generateHidingPath];
    emptyPoint = [[Game sharedInstance] getEmptyPoint];
    [self startShuffleImages];
}

- (void)endGame
{
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self showHiddenImage];
    } completion:^(BOOL finished) {
        [self setBordersForImagesEnabled:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:mainView animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Compleated";
            [hud hide:YES afterDelay:1.0];
        });
        
    }];
}

- (GamePoint *)getEmptyPoint
{
    return emptyPoint;
}

- (void)setBordersForImagesEnabled: (BOOL)enabled
{
    float value = (enabled ? 1.0 : 0.0);
    UIColor *borderColor = [UIColor blackColor];
    for (int i = 0; i < properties.rowsCount; i++) {
        for (int j = 0; j < properties.columnsCount; j++) {
            GameImage *gameImage = imagesArray[i][j];
            [gameImage.imageView.layer setBorderColor:borderColor.CGColor];
            [gameImage.imageView.layer setBorderWidth:value];
        }
    }
}

- (void)showHiddenImage
{
    GameImage *gameImage = imagesArray[emptyPoint.y][emptyPoint.x];
    gameImage.imageView.alpha = 1;
}

- (void)downloadImages
{
    properties = [[Game sharedInstance] getGameProperties];
    NSMutableArray *rowsArray = [NSMutableArray new];
    for (int i = 0; i < properties.rowsCount; i++) {
        NSMutableArray *elementsInRowArray = [NSMutableArray new];
        for (int j = 0; j < properties.columnsCount; j++) {
            CGRect frame = CGRectMake(j * properties.elemWidth, i * properties.elemHieght, properties.elemWidth, properties.elemHieght);
            GameImage *gameImage = [GameImage new];
            gameImage.imageView =[[UIImageView alloc] initWithFrame:frame];
            gameImage.position = [[GamePoint alloc] initWithX:i Y:j];
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://dl.dropboxusercontent.com/u/55523423/NetExample/%@/%d_%d.png", properties.imageName, i, j]];
            [gameImage.imageView sd_setImageWithURL:imageURL];
            [mainView addSubview:gameImage.imageView];
            [elementsInRowArray addObject:gameImage];
        }
        [rowsArray addObject:elementsInRowArray];
    }
    imagesArray = [rowsArray copy];
}

- (void)startShuffleImages
{
    [UIView animateWithDuration:0.1 animations:^{
        GameImage *hiddenImage = imagesArray[properties.startPoint.y][properties.startPoint.x];
        hiddenImage.imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self shuffleImages];
    }];
}

- (void)shuffleImages
{
    if (generatedPathOfPoints.count == 1) return;
    [UIView animateWithDuration:0.1 animations:^{
        GamePoint *previousPoint = [generatedPathOfPoints firstObject];
        [generatedPathOfPoints removeObjectAtIndex:0];
        GamePoint *currentPoint = [generatedPathOfPoints firstObject];
        GameImage *previousImage = imagesArray[previousPoint.y][previousPoint.x];
        GameImage *currentImage = imagesArray[currentPoint.y][currentPoint.x];
        [self swapSomeImage:previousImage AnotherImageWithAnimation:currentImage];
    } completion:^(BOOL finished) {
        [self shuffleImages];
    }];
}

- (void)swapSomeImage: (GameImage *)someImage AnotherImageWithAnimation: (GameImage *)anotherImage
{
    GameImage *temp = [GameImage new];
    temp.imageView = [UIImageView new];
    temp.imageView.image = someImage.imageView.image;
    temp.position = someImage.position;

    someImage.imageView.image = anotherImage.imageView.image;
    someImage.position = anotherImage.position;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.1f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [someImage.imageView.layer addAnimation:transition forKey:nil];
    
    anotherImage.imageView.image = temp.imageView.image;
    anotherImage.position = temp.position;
    
    [anotherImage.imageView.layer addAnimation:transition forKey:nil];
    someImage.imageView.alpha = 1;
    anotherImage.imageView.alpha = 0;
}

#pragma mark Moving

- (void)moveImagesToRightFromX: (int)fromX
{
    GameImage *emptyImage = imagesArray[emptyPoint.y][emptyPoint.x];
    [UIView animateWithDuration:0.5 animations:^{
        for (int i = emptyPoint.x - 1; i >= fromX; i--) {
            GamePoint *destinationPoint = [[GamePoint alloc] initWithX:i + 1 Y:emptyPoint.y];
            CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
            GameImage *currentView = imagesArray[emptyPoint.y][i];
            CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
            [currentView.imageView setFrame:frame];
            imagesArray[destinationPoint.y][destinationPoint.x] = imagesArray[destinationPoint.y][i];
        }
    }];
    GamePoint *destinationPoint = [[GamePoint alloc] initWithX:fromX Y:emptyPoint.y];
    CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
    CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
    [emptyImage.imageView setFrame:frame];
    imagesArray[destinationPoint.y][destinationPoint.x] = emptyImage;
    
    emptyPoint.x = fromX;
}

- (void)moveImagesToLeftFromX: (int)fromX
{
    GameImage *emptyImage = imagesArray[emptyPoint.y][emptyPoint.x];
    [UIView animateWithDuration:0.5 animations:^{
        for (int i = emptyPoint.x + 1; i <= fromX; i++) {
            GamePoint *destinationPoint = [[GamePoint alloc] initWithX:i - 1 Y:emptyPoint.y];
            CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
            GameImage *currentView = imagesArray[emptyPoint.y][i];
            CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
            [currentView.imageView setFrame:frame];
            imagesArray[destinationPoint.y][destinationPoint.x] = imagesArray[destinationPoint.y][i];
        }
    }];
    GamePoint *destinationPoint = [[GamePoint alloc] initWithX:fromX Y:emptyPoint.y];
    CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
    CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
    [emptyImage.imageView setFrame:frame];
    imagesArray[destinationPoint.y][destinationPoint.x] = emptyImage;
    
    emptyPoint.x = fromX;
}

- (void)moveImagesToTopFromY: (int)fromY
{
    GameImage *emptyImage = imagesArray[emptyPoint.y][emptyPoint.x];
    [UIView animateWithDuration:0.5 animations:^{
        for (int j = emptyPoint.y + 1; j <= fromY; j++) {
            GamePoint *destinationPoint = [[GamePoint alloc] initWithX:emptyPoint.x Y:j - 1];
            CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
            GameImage *currentView = imagesArray[j][emptyPoint.x];
            CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
            [currentView.imageView setFrame:frame];
            imagesArray[destinationPoint.y][destinationPoint.x] = imagesArray[j][destinationPoint.x];
        }
    }];
    GamePoint *destinationPoint = [[GamePoint alloc] initWithX:emptyPoint.x Y:fromY];
    CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
    CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
    [emptyImage.imageView setFrame:frame];
    imagesArray[destinationPoint.y][destinationPoint.x] = emptyImage;
    
    emptyPoint.y = fromY;
}

- (void)moveImagesToBottomFromY: (int)fromY
{
    GameImage *emptyImage = imagesArray[emptyPoint.y][emptyPoint.x];
    [UIView animateWithDuration:0.5 animations:^{
        for (int j = emptyPoint.y - 1; j >= fromY; j--) {
            GamePoint *destinationPoint = [[GamePoint alloc] initWithX:emptyPoint.x Y:j + 1];
            CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
            GameImage *currentView = imagesArray[j][emptyPoint.x];
            CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
            [currentView.imageView setFrame:frame];
            imagesArray[destinationPoint.y][destinationPoint.x] = imagesArray[j][destinationPoint.x];
        }
    }];
    GamePoint *destinationPoint = [[GamePoint alloc] initWithX:emptyPoint.x Y:fromY];
    CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
    CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
    [emptyImage.imageView setFrame:frame];
    imagesArray[destinationPoint.y][destinationPoint.x] = emptyImage;
    
    emptyPoint.y = fromY;
}

#pragma mark Check

- (BOOL)checkForGameCompleated
{
    for (int i = 0; i < properties.rowsCount; i++) {
        for (int j = 0; j < properties.columnsCount; j++) {
            GameImage *gameImage = imagesArray[i][j];
            if (gameImage.position.x != i || gameImage.position.y != j) return NO;
        }
    }
    return YES;
}


@end
