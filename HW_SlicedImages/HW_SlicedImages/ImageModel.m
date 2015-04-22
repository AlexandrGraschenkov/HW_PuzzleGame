//
//  ImageModel.m
//  HW_SlicedImages
//
//  Created by Admin on 19.04.15.
//  Copyright (c) 2015 ITIS. All rights reserved.
//

#import "ImageModel.h"

@interface ImageModel(){
    
    CGRect *frame;
    CGFloat elemWidth;
    CGFloat elemHeight;
}

@end

@implementation ImageModel

-(void)initImg: (UIImageView *)imgsView : (CGRect *)frames
{
    _imgView = imgsView;
    frame = frames;
    elemHeight = _imgView.frame.size.height;
    elemWidth = _imgView.frame.size.width;
    _xBegin = _imgView.frame.origin.x;
    _yBegin = _imgView.frame.origin.y;
    _xNow = _xBegin;
    _yNow = _yBegin;
    self.delay = 0.0;
}

-(BOOL)itYou: (int)x : (int)y
{
    BOOL b = false;
    if (x > _xNow && y > _yNow && x < _xNow+elemWidth && y < _yNow + elemHeight) {
        b = true;
    }
        return b;
}

-(BOOL)takeImg: (int)x : (int)y
{
    if (x == _xNow || y == _yNow ) {
        return true;
    }
    return false;
}

# pragma mark Move
-(void)moveUp
{
    _yNow -= elemHeight;
    CGRect frames = CGRectMake( _xNow, _yNow, elemWidth, elemHeight);
    [UIView animateWithDuration:0.5 delay:self.delay options:optind
                     animations:^{
                         [_imgView setFrame:frames];
                     }
                     completion:nil];
}

-(void)moveDown
{
    _yNow += elemHeight;
    CGRect frames = CGRectMake( _xNow, _yNow, elemWidth, elemHeight);
    [UIView animateWithDuration:0.5 delay:self.delay options:optind
                     animations:^{
                         [_imgView setFrame:frames];
                     }
                     completion:nil];
}

-(void)moveRight
{
    _xNow += elemWidth;
    CGRect frames = CGRectMake( _xNow, _yNow, elemWidth, elemHeight);
    [UIView animateWithDuration:0.5 delay:self.delay options:optind
                     animations:^{
                         [_imgView setFrame:frames];
                     }
                     completion:nil];
}

-(void)moveLeft
{
    _xNow -= elemWidth;
    CGRect frames = CGRectMake( _xNow, _yNow, elemWidth, elemHeight);
    [UIView animateWithDuration:0.5 delay:self.delay options:optind
                     animations:^{
                         [_imgView setFrame:frames];
                     }
                     completion:nil];
}

#pragma mark TakeYourPlace
-(void)takeYourPlace
{
    CGRect frames = CGRectMake( _xBegin, _yBegin, elemWidth, elemHeight);
    [_imgView setFrame:frames];
    _xNow = _xBegin;
    _yNow = _yBegin;
}

@end