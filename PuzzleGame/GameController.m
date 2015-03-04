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

@interface GameController () {
    NSArray *imagesArray;
    NSArray *imagesCopyArray;
    UIView *mainView;
    GameProperties *properties;
    NSMutableArray *generatedPathOfPoints;
    UIImageView *hiddenImage;
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
    [self makeCopyOfImages];
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
            UIImageView *imageView = imagesArray[i][j];
            [imageView.layer setBorderColor:borderColor.CGColor];
            [imageView.layer setBorderWidth:value];
        }
    }
}

- (void)showHiddenImage
{
    UIImageView *image = imagesArray[emptyPoint.y][emptyPoint.x];
    image.alpha = 1;
}

- (void)makeCopyOfImages
{
    for (int i = 0; i < properties.rowsCount; i++) {
        for (int j = 0; j < properties.columnsCount; j++) {
            UIImageView *imgView = imagesArray[i][j];
            UIImageView *imageView = imagesCopyArray[i][j];
            imageView.image = imgView.image;
        }
    }
}

- (void)downloadImages
{
    properties = [[Game sharedInstance] getGameProperties];
    NSMutableArray *rowsArray = [NSMutableArray new];
    NSMutableArray *rowsCopyArray = [NSMutableArray new];
    for (int i = 0; i < properties.rowsCount; i++) {
        NSMutableArray *elementsInRowArray = [NSMutableArray new];
        NSMutableArray *elementsInRowCopyArray = [NSMutableArray new];
        for (int j = 0; j < properties.columnsCount; j++) {
            CGRect frame = CGRectMake(j * properties.elemWidth, i * properties.elemHieght, properties.elemWidth, properties.elemHieght);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            UIImageView *imageCopyView = [[UIImageView alloc] initWithFrame:frame];
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://dl.dropboxusercontent.com/u/55523423/NetExample/%@/%d_%d.png", properties.imageName, i, j]];
            [imageView sd_setImageWithURL:imageURL];
            [mainView addSubview:imageView];
            [elementsInRowArray addObject:imageView];
            [elementsInRowCopyArray addObject:imageCopyView];
        }
        [rowsArray addObject:elementsInRowArray];
        [rowsCopyArray addObject:elementsInRowCopyArray];
    }
    imagesArray = [rowsArray copy];
    imagesCopyArray = [rowsCopyArray copy];
}

- (void)startShuffleImages
{
    [UIView animateWithDuration:0.1 animations:^{
        hiddenImage = imagesArray[properties.startPoint.y][properties.startPoint.x];
        hiddenImage.alpha = 0.0;
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
        UIImageView *previousImage = imagesArray[previousPoint.y][previousPoint.x];
        UIImageView *currentImage = imagesArray[currentPoint.y][currentPoint.x];
        [self swapSomeImage:previousImage AnotherImageWithAnimation:currentImage];
    } completion:^(BOOL finished) {
        [self shuffleImages];
    }];
}

- (void)swapSomeImage: (UIImageView *)someImage AnotherImageWithAnimation: (UIImageView *)anotherImage
{
    UIImageView *temp = [UIImageView new];
    temp.image = someImage.image;
    someImage.image = anotherImage.image;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.1f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [someImage.layer addAnimation:transition forKey:nil];
    
    anotherImage.image = temp.image;
    
    
    [anotherImage.layer addAnimation:transition forKey:nil];
    someImage.alpha = 1;
    anotherImage.alpha = 0.0;
}

#pragma mark Moving

- (void)moveImagesToRightFromX: (int)fromX
{
    UIImageView *emptyImage = imagesArray[emptyPoint.y][emptyPoint.x];
    [UIView animateWithDuration:0.5 animations:^{
        for (int i = emptyPoint.x - 1; i >= fromX; i--) {
            GamePoint *destinationPoint = [[GamePoint alloc] initWithX:i + 1 Y:emptyPoint.y];
            CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
            UIImageView *currentView = imagesArray[emptyPoint.y][i];
            CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
            [currentView setFrame:frame];
            imagesArray[destinationPoint.y][destinationPoint.x] = imagesArray[destinationPoint.y][i];
        }
    }];
    GamePoint *destinationPoint = [[GamePoint alloc] initWithX:fromX Y:emptyPoint.y];
    CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
    CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
    [emptyImage setFrame:frame];
    imagesArray[destinationPoint.y][destinationPoint.x] = emptyImage;
    
    emptyPoint.x = fromX;
}

- (void)moveImagesToLeftFromX: (int)fromX
{
    UIImageView *emptyImage = imagesArray[emptyPoint.y][emptyPoint.x];
    [UIView animateWithDuration:0.5 animations:^{
        for (int i = emptyPoint.x + 1; i <= fromX; i++) {
            GamePoint *destinationPoint = [[GamePoint alloc] initWithX:i - 1 Y:emptyPoint.y];
            CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
            UIImageView *currentView = imagesArray[emptyPoint.y][i];
            CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
            [currentView setFrame:frame];
            imagesArray[destinationPoint.y][destinationPoint.x] = imagesArray[destinationPoint.y][i];
        }
    }];
    GamePoint *destinationPoint = [[GamePoint alloc] initWithX:fromX Y:emptyPoint.y];
    CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
    CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
    [emptyImage setFrame:frame];
    imagesArray[destinationPoint.y][destinationPoint.x] = emptyImage;
    
    emptyPoint.x = fromX;
}

- (void)moveImagesToTopFromY: (int)fromY
{
    UIImageView *emptyImage = imagesArray[emptyPoint.y][emptyPoint.x];
    [UIView animateWithDuration:0.5 animations:^{
        for (int j = emptyPoint.y + 1; j <= fromY; j++) {
            GamePoint *destinationPoint = [[GamePoint alloc] initWithX:emptyPoint.x Y:j - 1];
            CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
            UIImageView *currentView = imagesArray[j][emptyPoint.x];
            CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
            [currentView setFrame:frame];
            imagesArray[destinationPoint.y][destinationPoint.x] = imagesArray[j][destinationPoint.x];
        }
    }];
    GamePoint *destinationPoint = [[GamePoint alloc] initWithX:emptyPoint.x Y:fromY];
    CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
    CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
    [emptyImage setFrame:frame];
    imagesArray[destinationPoint.y][destinationPoint.x] = emptyImage;
    
    emptyPoint.y = fromY;
}

- (void)moveImagesToBottomFromY: (int)fromY
{
    UIImageView *emptyImage = imagesArray[emptyPoint.y][emptyPoint.x];
    [UIView animateWithDuration:0.5 animations:^{
        for (int j = emptyPoint.y - 1; j >= fromY; j--) {
            GamePoint *destinationPoint = [[GamePoint alloc] initWithX:emptyPoint.x Y:j + 1];
            CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
            UIImageView *currentView = imagesArray[j][emptyPoint.x];
            CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
            [currentView setFrame:frame];
            imagesArray[destinationPoint.y][destinationPoint.x] = imagesArray[j][destinationPoint.x];
        }
    }];
    GamePoint *destinationPoint = [[GamePoint alloc] initWithX:emptyPoint.x Y:fromY];
    CGPoint destPoint = [[Game sharedInstance] getCGPointFromGamePoint:destinationPoint];
    CGRect frame = CGRectMake(destPoint.x, destPoint.y, properties.elemWidth, properties.elemHieght);
    [emptyImage setFrame:frame];
    imagesArray[destinationPoint.y][destinationPoint.x] = emptyImage;
    
    emptyPoint.y = fromY;
}

#pragma mark Check

- (BOOL)checkForGameCompleated
{
    for (int i = 0; i < properties.rowsCount; i++) {
        for (int j = 0; j < properties.columnsCount; j++) {
            UIImageView *first = imagesArray[i][j];
            UIImageView *second = imagesCopyArray[i][j];
            if (emptyPoint.x == j && emptyPoint.y == i) {
                continue;
            }
            if (first.image != second.image) return NO;
        }
    }
    return YES;
}


@end
