//
//  ImageViewContr.m
//  HW_SlicedImages
//
//  Created by Admin on 21.02.15.
//  Copyright (c) 2015 ITIS. All rights reserved.
//
#include <stdlib.h>
#import "ImageViewContr.h"
#import <UIImageView+WebCache.h>
#import "ImageModel.h"
@import UIKit;

@implementation ImageViewContr
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupSizes];
    [self resizeMainView];
    [self createArrayOfEmptyImages];
    [self loadImages];
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.mainView setUserInteractionEnabled:NO];
    [self.mainView addGestureRecognizer:singleTapGestureRecognizer];
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=6.0;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self deviceOrientationDidChange];
}

-(void)deviceOrientationDidChange{

    UIView *subView = [self.scrollView.subviews objectAtIndex:0];
    CGFloat offsetX = MAX((self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5, 0.0);
    subView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,
                                 self.scrollView.contentSize.height * 0.5 + offsetY - 40 );
}

- (void)resizeMainView
{
    CGRect frame =  CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y, elemWidth * columnsCount, elemHieght*rowsCount);
    [self.mainView setFrame:frame];
}

- (void)setupSizes
{
    rowsCount = [self.dict[@"rows_count"] floatValue];
    columnsCount = [self.dict[@"columns_count"] floatValue];
    elemWidth = [self.dict[@"elem_width"] floatValue];
    elemHieght = [self.dict[@"elem_height"] floatValue];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mainView;
}

- (void)createArrayOfEmptyImages
{
    NSMutableArray *arr = [NSMutableArray new];
    NSMutableArray *arrImg = [NSMutableArray new];
    for (int i = 0; i < rowsCount; i++) {
        NSMutableArray *elementsInRow = [NSMutableArray new];
        for (int j = 0; j < columnsCount; j++) {
            CGRect frame = CGRectMake(j * elemWidth, i * elemHieght, elemWidth, elemHieght);
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
            ImageModel *imgM = [ImageModel new];
            [imgM initImg:imgView];
            [arrImg addObject:imgM];
            [self.mainView addSubview:imgView];
            [elementsInRow addObject:imgView];
        }
        [arr addObject:elementsInRow];
    }
    imageModelArray = [arrImg copy];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY - 50);
}

- (void)loadImages
{
    int y = 0;
    for (int i = 0; i < rowsCount; i++) {
        for (int j = 0; j < columnsCount; j++) {
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://dl.dropboxusercontent.com/u/55523423/NetExample/%@/%d_%d.png", self.dict[@"folder_name"], i, j]];
            ImageModel *mod = imageModelArray[y];
            [mod.imgView sd_setImageWithURL:imageURL];
            y++;
        }
    }
}

#pragma mark PuzzleGame
- (IBAction)startGame:(UIButton *)sender
{
    [self newGame];
    [self.mainView setUserInteractionEnabled:YES];
    UIColor *borderColor = [UIColor blackColor];
    ImageModel *qwe;
    
    for (int i = 0; i < imageModelArray.count; i++) {
        qwe = imageModelArray[i];
        [qwe.imgView.layer setBorderColor:borderColor.CGColor];
        [qwe.imgView.layer setBorderWidth:1.0];
    }
    
    [imageModelArray[imageModelArray.count/2] imgView].alpha = 0;
    alphaX = [imageModelArray[imageModelArray.count/2] xNow];
    alphaY = [imageModelArray[imageModelArray.count/2] yNow];
    [imageModelArray[imageModelArray.count/2] setXNow:-3 * elemWidth];
    [self generatedNewGame];
    [UIView animateWithDuration:1.5 delay:0.0 options:optind
                     animations:^{
                         [self stBut].alpha = 0;
                     }
                     completion:nil];
}

-(void)endGame
{
    [self.mainView setUserInteractionEnabled:NO];
    
    for (int i = 0; i < imageModelArray.count; i++) {
        UIColor *borderColor = [UIColor redColor];
        [[[imageModelArray[i] imgView] layer] setBorderColor:borderColor.CGColor];
        [[[imageModelArray[i] imgView] layer]  setBorderWidth:0.0];
    }
    CGRect frames = CGRectMake( [imageModelArray[imageModelArray.count / 2] xBegin], [imageModelArray[imageModelArray.count / 2] yBegin], elemWidth, elemHieght);
    [[imageModelArray[imageModelArray.count / 2] imgView] setFrame:frames];
    [UIView animateWithDuration:1.5 delay:0.0 options:optind
                     animations:^{
                         [imageModelArray[imageModelArray.count / 2] imgView].alpha = 1;
                     }
                     completion:nil];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ура!!!" message:@"Красавчик" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [UIView animateWithDuration:1.5 delay:0.0 options:optind
                     animations:^{
                         [self stBut].alpha = 1;
                     }
                     completion:nil];
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint touchLocation = [tapGestureRecognizer locationInView:self.mainView];
    int xx = alphaX;
    int yy = alphaY;
    BOOL b = false;
    
    for (int i = 0; i < imageModelArray.count; i++) {
        
        if ([imageModelArray[i] itYou:touchLocation.x :touchLocation.y]) {
            xx = [imageModelArray[i] xNow];
            yy = [imageModelArray[i] yNow];
        }
        
        if (alphaX < touchLocation.x && alphaX + elemWidth > touchLocation.x && touchLocation.x - elemWidth< [imageModelArray[i] xNow] && touchLocation.x  > [imageModelArray[i] xNow]) {
            if (alphaY < touchLocation.y && touchLocation.y > [imageModelArray[i] yNow] && alphaY < [imageModelArray[i] yNow]  ) {
                [imageModelArray[i] moveUp];
            }  else if (alphaY > touchLocation.y && alphaY > [imageModelArray[i] yNow] && touchLocation.y - elemHieght < [imageModelArray[i] yNow] ){
                [imageModelArray[i] moveDown];
            }
            b = true;
        }
    
        if (alphaY < touchLocation.y  && alphaY + elemHieght > touchLocation.y && alphaY - 1 < [imageModelArray[i] yNow] && alphaY + elemHieght > [imageModelArray[i] yNow] ) {
            if (alphaX < touchLocation.x && touchLocation.x  > [imageModelArray[i] xNow] && alphaX < [imageModelArray[i] xNow]) {
                [imageModelArray[i] moveLeft];
            }else if (alphaX > touchLocation.x && touchLocation.x - elemWidth < [imageModelArray[i] xNow] && alphaX > [imageModelArray[i] xNow]) {
                [imageModelArray[i] moveRight];
            }
            b = true;
        }
    }
    
    if (b) {
        alphaX = xx;
        alphaY = yy;
    }
    
    if (self.checkEndGame) {
        [self endGame];
    }
}

-(BOOL)checkEndGame
{
    int c = 0;
    for (int i = 0; i < imageModelArray.count; i++) {
        if(!([imageModelArray[i] xNow] == [imageModelArray[i] xBegin] && [imageModelArray[i] yNow] == [imageModelArray[i] yBegin]))
        {
            c++;
            if (c == 2){
                return false;
            }
        }else{
            
        }
    }
    return true;
}

#pragma mark space created for PuzzleGame
-(void)generatedNewGame
{
    int tick = 20;
    for (int i = 0; i < tick; i++) {
        NSArray *s = [self findImg];
        int r = arc4random_uniform(s.count-1);
        int x = [s[r] intValue];
        for (int j = 0 ; j < imageModelArray.count; j++) {
            [imageModelArray[j] setDelay: i*0.5];
        }
        [UIView animateWithDuration:0.5 delay:0.0 options:optind
                         animations:^{
                                     [self touchImg:[imageModelArray[x] xNow] :[imageModelArray[x] yNow]];                 }
                         completion:nil];
        for (int j = 0 ; j < imageModelArray.count; j++) {
            [imageModelArray[j] setDelay: 0];
        }
    }
}

-(NSArray *)findImg
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageModelArray.count; i++) {
        if ([imageModelArray[i] takeImg:alphaX :alphaY]) {
            [arr addObject:[NSNumber numberWithInt:i]];
        }
    }
    NSArray *arr2 = [arr copy];
    return arr2;
}

-(void)touchImg: (int)x : (int)y
{
    CGPoint touchLocation = CGPointMake(x, y);
    BOOL b = true;
    
    for (int i = 0; i < imageModelArray.count; i++) {
        if (i != imageModelArray.count/2) {
            if (alphaX <= touchLocation.x && alphaX  >= touchLocation.x && touchLocation.x  <= [imageModelArray[i] xNow] && touchLocation.x  >= [imageModelArray[i] xNow]) {
                if (alphaY <= touchLocation.y && touchLocation.y >= [imageModelArray[i] yNow] && alphaY <= [imageModelArray[i] yNow]  ) {
                    [imageModelArray[i] moveUp];
                }  else if (alphaY >= touchLocation.y && alphaY >= [imageModelArray[i] yNow] && touchLocation.y <= [imageModelArray[i] yNow] ){
                    [imageModelArray[i] moveDown];
                }
                b = true;
            }
            
            if (alphaY <= touchLocation.y  && alphaY >= touchLocation.y && alphaY  <= [imageModelArray[i] yNow] && alphaY  >= [imageModelArray[i] yNow] ) {
                if (alphaX <= touchLocation.x && touchLocation.x  >= [imageModelArray[i] xNow] && alphaX <= [imageModelArray[i] xNow]) {
                    [imageModelArray[i] moveLeft];
                }else if (alphaX >= touchLocation.x && touchLocation.x  <= [imageModelArray[i] xNow] && alphaX >= [imageModelArray[i] xNow]) {
                    [imageModelArray[i] moveRight];
                }
                b = true;
            }
        }
    }
    
    if (b) {
        alphaX = touchLocation.x;
        alphaY = touchLocation.y;
    }
}

#pragma mark NewGame
-(void)newGame
{
    for (int i = 0; i < imageModelArray.count; i++) {
        [imageModelArray[i] takeYourPlace];
    }
}
@end

