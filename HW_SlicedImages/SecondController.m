//
//  SecondController.m
//  HW_SlicedImages
//
//  Created by Артур Сагидулин on 25.02.15.
//  Copyright (c) 2015 Артур Сагидулин. All rights reserved.
//

#import "SecondController.h"
#import "NetManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImageManager.h>

@interface SecondController () <UIScrollViewDelegate> {
}
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat rows;
@property (nonatomic) CGFloat columns;
@property (nonatomic, strong) UIScrollView *scrollViewPointer;
@property (nonatomic, strong) UIView *contentViewPointer;
@property (nonatomic, strong) NSDictionary *viewsDictionary;
@property (nonatomic, strong) NSDictionary *contentDict;
@property (nonatomic, strong) NSMutableArray *pic;
@property (nonatomic, strong) NSMutableArray *picCopy;
@property (nonatomic) NSString *name;
@property (nonatomic) BOOL show;
@property (nonatomic,strong) UIImageView *currentPosition;
@property (nonatomic) CGFloat leftBorder;
@property (nonatomic) CGFloat rightBorder;
@property (nonatomic) CGFloat topBorder;
@property (nonatomic) CGFloat bottomBorder;
@property (nonatomic) int currentX;
@property (nonatomic) int currentY;
@property (nonatomic) NSMutableArray *path;
@property (nonatomic) int equal;
@property (weak, nonatomic) IBOutlet UIButton *solveButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic, weak) NSString *tempSwitch;
@property (nonatomic) int tempCount;
- (IBAction)started:(id)sender;
- (IBAction)solve:(UIButton *)sender;
@end

@implementation SecondController
static int moveX[] = {0,1,0,-1};
static int moveY[] = {-1,0,1,0};

@synthesize folder;
-(void)viewDidLoad{
    [super viewDidLoad];
    [_solveButton setHidden:YES];
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    UIView *contentView = [[UIView alloc] init];
    [self.view addSubview:scrollView];
    [scrollView addSubview:contentView];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollViewPointer = scrollView;
    self.contentViewPointer = contentView;
    [self setSizes];
    scrollView.maximumZoomScale = 4.0;
    scrollView.minimumZoomScale = MIN(self.view.bounds.size.width / (self.width*self.columns),
                                      self.view.bounds.size.height / (self.height*self.rows));
    scrollView.delegate = self;
    [self getImageGrid];
    [self fillGrid];
    _show = NO;
}

-(void)setSizes{
    self.rows = [self.folder[@"rows_count"] floatValue];
    self.columns = [self.folder[@"columns_count"] floatValue];
    self.width = [self.folder[@"elem_width"] floatValue];
    self.height = [self.folder[@"elem_height"] floatValue];
    self.name = self.folder[@"folder_name"];
    
    self.viewsDictionary = NSDictionaryOfVariableBindings(_scrollViewPointer, _contentViewPointer);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollViewPointer]|" options:0 metrics: 0 views:_viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollViewPointer]|" options:0 metrics: 0 views:_viewsDictionary]];
    
    [_scrollViewPointer addConstraint:[NSLayoutConstraint
                              constraintWithItem:_scrollViewPointer
                              attribute:NSLayoutAttributeTrailing
                              relatedBy:NSLayoutRelationEqual
                              toItem:_contentViewPointer
                              attribute:NSLayoutAttributeTrailing
                              multiplier:1.0
                              constant:0.0]];
    
    [_scrollViewPointer addConstraint:[NSLayoutConstraint
                                       constraintWithItem:_contentViewPointer
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:_scrollViewPointer
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0
                                       constant:0.0]];
    [_scrollViewPointer addConstraint:[NSLayoutConstraint
                                       constraintWithItem:_contentViewPointer
                                       attribute:NSLayoutAttributeTop
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:_scrollViewPointer
                                       attribute:NSLayoutAttributeTop
                                       multiplier:1.0
                                       constant:0.0]];
    [_scrollViewPointer addConstraint:[NSLayoutConstraint
                                       constraintWithItem:_scrollViewPointer
                                       attribute:NSLayoutAttributeBottom
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:_contentViewPointer
                                       attribute:NSLayoutAttributeBottom
                                       multiplier:1.0
                                       constant:0.0]];

    self.contentDict = @{@"content":_contentViewPointer};
    NSString *contentWidth = [NSString stringWithFormat:@"H:[content(%f)]",self.width*self.columns];
    NSString *contentHeight = [NSString stringWithFormat:@"V:[content(%f)]",self.height*self.rows];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:contentWidth options:0 metrics:nil views:_contentDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:contentHeight options:0 metrics:nil views:_contentDict]];
}

-(void)getImageGrid{
    NSMutableArray *imageGrid = [[NSMutableArray alloc] initWithCapacity:self.rows];
    NSMutableArray *tempRow = [[NSMutableArray alloc] initWithCapacity:self.columns];
    for (int i=0; i<self.rows; i++) {
        [tempRow removeAllObjects];
        for (int j=0; j<self.columns; j++) {
            CGRect pieceOfPic = CGRectMake(j * self.width, i * self.height, self.width, self.height);
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:pieceOfPic];
            [_contentViewPointer addSubview:imgView];
            [tempRow addObject:imgView];
        }
        [imageGrid insertObject:[NSMutableArray arrayWithArray:tempRow] atIndex:i];
    }
    self.pic = [imageGrid copy];
}
-(void)fillGrid{
    for (int i=0; i<self.rows; i++) {
        for (int j=0; j<self.columns; j++) {
            NSString *strURL = [NSString stringWithFormat:@"https://dl.dropboxusercontent.com/u/55523423/NetExample/%@/%d_%d.png",self.name,i,j];
            NSURL *imgURL = [NSURL URLWithString:strURL];
            [[[self.pic objectAtIndex:i] objectAtIndex:j] sd_setImageWithURL:imgURL];
        }
    }
}
-(void)showBlackGrid{
    _show = !_show;
    for (int i=0; i<[_pic count]; i++) {
        for (int j=0; j<[[_pic objectAtIndex:i] count]; j++) {
            [[_pic[i][j] layer] setBorderColor:[[UIColor blackColor] CGColor]];
            [[_pic[i][j] layer] setBorderWidth:(_show ? 1 : 0)];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self changeConstantsOfConstraints];
}
-(void)changeConstantsOfConstraints{
    float contentWidth = _contentViewPointer.frame.size.width;
    float contentHeight = _contentViewPointer.frame.size.height;
    
    float superviewWidth = self.view.bounds.size.width;
    float superviewHeight = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20;
    
    float hPadding = (superviewWidth - contentWidth) / 2.0;
    if (hPadding < 0) hPadding = 0;
    
    float vPadding = (superviewHeight - contentHeight) / 2.0;
    if (vPadding < 0) vPadding = 0;
    
    for(NSLayoutConstraint *constraint in _scrollViewPointer.constraints)
    {
        if (constraint.firstAttribute == 6 || constraint.firstAttribute == 5) {
            constraint.constant = hPadding;
        } else if (constraint.firstAttribute == 3 || constraint.firstAttribute == 4) {
            constraint.constant = vPadding;
        }
    }
    [self.view layoutIfNeeded];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    [self changeConstantsOfConstraints];
    [self.view updateConstraintsIfNeeded];
}

- (IBAction)started:(id)sender {
    [self showBlackGrid];
    [self initGame];
    [_contentViewPointer setUserInteractionEnabled:YES];
    [_startButton setEnabled:NO];
    [_solveButton setHidden:NO];
}

-(void)initGame{
    _picCopy =[[NSMutableArray alloc] initWithArray:_pic copyItems:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [_contentViewPointer setUserInteractionEnabled:NO];
    [_contentViewPointer addGestureRecognizer:tap];
    [self prepareGameTable];
    
}
-(void)tapHandler:(UITapGestureRecognizer *)tapGestureRecognizer{
    NSLog(@"tapped");
    CGPoint tap = [tapGestureRecognizer locationInView:_contentViewPointer];
    _currentX = _currentPosition.frame.origin.x/_width;
    _currentY = _currentPosition.frame.origin.y/_height;
    int xCoord = (int)(tap.x/_width);
    int yCoord = (int)(tap.y/_height);
    static int moveX[] = {0,1,0,-1};
    static int moveY[] = {-1,0,1,0};
    if (xCoord==_currentX) {
        if (yCoord<_currentY) {
            int diff = (_currentPosition.frame.origin.y)/_height-yCoord;
            [self move:diff :moveY[0] :moveX[0] :@"user"];
            
        }
        if (yCoord>_currentY) {
            int diff = yCoord-_currentY;
            [self move:diff :moveY[2] :moveX[2] :@"user"];
        }
    }
    if (yCoord==_currentY) {
        if (xCoord<_currentX) {
            int diff = _currentX-xCoord;
            [self move:diff :moveY[3] :moveX[3] :@"user"];
            
        }
        if (xCoord>_currentX) {
            int diff = xCoord-_currentX;
            [self move:diff :moveY[1] :moveX[1] :@"user"];
        }
    }
}
-(void)prepareGameTable{
    UIImageView *startBlock = _pic[0][0];
    _path = [NSMutableArray new];
    _currentPosition = startBlock;
    _currentX = 0;
    _currentY = 0;
    _leftBorder = [_pic[0][0] frame].origin.x;
    _rightBorder = [[_pic[0] lastObject] frame].origin.x;
    _topBorder = [_pic[0][0] frame].origin.y;
    _bottomBorder = [_pic[_pic.count-1][0] frame].origin.y;
    [UIView animateWithDuration:0.5 animations:^{
        [startBlock setAlpha:0];
    } completion:^(BOOL finished) {
        [self generateMovement:4];
    }];
}
-(void)generateMovement:(int)iterations{
    //int direction =arc4random_uniform(4);
    _tempCount = 0;
    _tempSwitch = nil;
    if (iterations>0) {
        for (int i = 0; i < 4; ++i) {
            if ((i==0 && _currentY!=0 && ([[_path lastObject] integerValue]!=2)&&
                                        ([[_path lastObject] integerValue]!=0)) ||
                (i==1 && _currentX!=(_columns-1) && ([[_path lastObject] integerValue]!=3)&&
                                        ([[_path lastObject] integerValue]!=1)) ||
                (i==2 && _currentY!=(_rows-1) && ([[_path lastObject] integerValue]!=0)&&
                                        ([[_path lastObject] integerValue]!=2)) ||
                (i==3 && _currentX!=0 && ([[_path lastObject] integerValue]!=1)&&
                                        ([[_path lastObject] integerValue]!=3))) {
                
                    [_path addObject:[NSNumber numberWithInt:i]];
                    [self move:iterations :moveY[i] :moveX[i] :@"generate"];
                    return;
                }
        }
    }
}


-(void)move:(int)times:(int)dirY:(int)dirX:(NSString*)switcher{
    
    float duration = 0.07;
    if ([switcher isEqual:@"generate"]) duration = 0.4;
    if (times>0) {
        UIImageView *targetPosition = _pic[_currentY+dirY][_currentX+dirX];
        CGRect targetFrame= targetPosition.frame;
        CGRect currentFrame = _currentPosition.frame;
        [_pic[_currentY] exchangeObjectAtIndex:_currentX withObjectAtIndex:_currentX+dirX];
        UIImageView *temp = _pic[_currentY][_currentX];
        [_pic[_currentY] replaceObjectAtIndex:_currentX withObject:targetPosition];
        [_pic[_currentY+dirY] replaceObjectAtIndex:_currentX withObject:temp];
        [UIView animateWithDuration:duration animations:^{
            _currentPosition.frame = targetFrame;
            targetPosition.frame = currentFrame;
        }completion:^(BOOL finished) {
            _currentY +=dirY;
            _currentX +=dirX;
            [self isComplete];
            if ([_tempSwitch isEqualToString:@"generate"]) {
                [self generateMovement:_tempCount-1];
            } else if ([switcher isEqual:@"generate"]) {
                BOOL repeat =arc4random_uniform(2);
                _tempSwitch = @"generate";
                _tempCount = times;
                if (repeat && ((dirY<0 && (_currentY-1>0))||(dirY>0 && (_currentY+1<([_pic count]-1)))||
                               (dirY==0 && ( (dirX<0 && _currentX-1>0)||
                                            (dirX>0 && _currentX+1<([_pic[0] count]-1)) ) ) )) {
                    [self move:1 :dirY :dirX :@"user"];
                } else [self generateMovement:times-1];
            } else if ([switcher isEqual:@"AI"]){
                [self AImove];
            } else if ([switcher isEqual:@"user"]) [self move:times-1 :dirY :dirX :@"user"];
        }];
    } else return;
}

-(void)isComplete{
    _equal = 0;
    for (int i=0; i<[_pic count]; i++) {
        for (int j=0; j<[[_pic objectAtIndex:i] count]; j++) {
            NSURL *temp = [[[_pic objectAtIndex:i] objectAtIndex:j] sd_imageURL];
            NSURL *temp2 = [[[_picCopy objectAtIndex:i] objectAtIndex:j] sd_imageURL];
            if ([temp isEqual:temp2]) {
                _equal+=1;
            }
        }
    }
    if (_equal==(_rows*_columns)) {
        NSLog(@"YOU WIN!");
        [UIView animateWithDuration:0.5 animations:^{
            [_currentPosition setAlpha:1.0];
            [self showBlackGrid];
            [_startButton setEnabled:YES];
            _scrollViewPointer.zoomScale = _scrollViewPointer.minimumZoomScale;
        }completion:^(BOOL finished) {
            [self endGame];
        }];
    } else NSLog(@"%d/%lu",_equal,[_pic count]*[[_pic objectAtIndex:0] count]);
}

- (IBAction)solve:(UIButton *)sender {
    [_contentViewPointer setUserInteractionEnabled:YES];
    [_path removeAllObjects];
    [self AImove];
}

-(void)AImove{
    NSURL *on;
    NSURL *mustBeOn;
    
    for (int i = 0; i < 4; ++i) {
        if ((i==0 && (_currentY!=0) && ([[_path lastObject] integerValue]!=2)) ||
            (i==1 && (_currentX<([_pic[0] count]-1)) && ([[_path lastObject] integerValue]!=3)) ||
            (i==2 && (_currentY<([_pic count]-1)) && ([[_path lastObject] integerValue]!=0)) ||
            (i==3 && (_currentX!=0) && ([[_path lastObject] integerValue]!=1))) {
                on = [[[_pic objectAtIndex:_currentY+moveY[i]] objectAtIndex:_currentX + moveX[i]] sd_imageURL];
                mustBeOn = [[[_picCopy objectAtIndex:_currentY+moveY[i]] objectAtIndex:_currentX+moveX[i]] sd_imageURL];
                NSLog(@"i=%d",i);
                if (![on isEqual:mustBeOn]) {
                    NSLog(@"Moved!");
                    [_path addObject:[NSNumber numberWithInt:i]];
                    [self move:1 :moveY[i] :moveX[i] :@"AI"];
                    return;
                } else if (i==3) {
                    if ((_currentY<([_pic count]-1))) {
                        [_path addObject:[NSNumber numberWithInt:i]];
                        [self move:1 :moveY[2] :moveX[2] :@"AI"];
                        return;
                    }
                }
            }
        }

}

-(void)endGame{
    UILabel *label = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label setText:@"Красавчик!"];
    [label setTextColor:[UIColor redColor]];
    UIFont *myFont = [label font];
    [myFont fontWithSize:48];
    [label setFont:myFont];
    [label setAlpha:0];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setContentMode:UIViewContentModeCenter];
    [_contentViewPointer addSubview:label];
    [_contentViewPointer addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_contentViewPointer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [_contentViewPointer addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_contentViewPointer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:label
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:0
                                                                   constant:400];
    NSLayoutConstraint *labelHeight = [NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:0
                                                                    constant:200];
    [_contentViewPointer addConstraint:labelHeight];
    [_contentViewPointer addConstraint:labelWidth];
    [_contentViewPointer layoutIfNeeded];
    [_contentViewPointer updateConstraints];
    [UIView animateWithDuration:1.0 animations:^{
        [label setAlpha:1.0];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            [label setAlpha:0];
        }];
    }];
}

@end
