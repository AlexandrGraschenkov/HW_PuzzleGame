//
//  ImageModel.h
//  HW_SlicedImages
//
//  Created by Admin on 19.04.15.
//  Copyright (c) 2015 ITIS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageViewContr.h"
@interface ImageModel : NSObject

@property (nonatomic) int xBegin;
@property (nonatomic) int yBegin;

@property (nonatomic) int xNow;
@property (nonatomic) int yNow;
@property (nonatomic) UIImageView *imgView;

-(void)initImg: (UIImageView *)imgsView : (CGRect *)frames;
-(BOOL)itYou: (int)x : (int)y;
-(BOOL)takeImg: (int)x : (int)y;
-(void)moveLeft;
-(void)moveRight;
-(void)moveDown;
-(void)moveUp;
-(void)takeYourPlace;
@end

