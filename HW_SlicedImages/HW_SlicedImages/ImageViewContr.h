//
//  ImageViewContr.h
//  HW_SlicedImages
//
//  Created by Admin on 21.02.15.
//  Copyright (c) 2015 ITIS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageModel.h"

@interface ImageViewContr : UIViewController
{
    CGFloat rowsCount;
    CGFloat columnsCount;
    CGFloat elemWidth;
    CGFloat elemHieght;
    NSArray *imagesArray;
    NSArray *imageViewArray;
    NSArray *imageModelArray;
    NSArray *moveArray;
    int alphaX;
    int alphaY;
}

@property (nonatomic, strong) NSDictionary *dict;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
-(void)endGame;
-(BOOL)checkEndGame;
@end
