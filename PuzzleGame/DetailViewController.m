//
//  DetailViewController.m
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import "DetailViewController.h"
#import "Game.h"
#import "GameProperties.h"
#import "GameController.h"

@interface DetailViewController () <UIScrollViewDelegate> {
    GameProperties *properties;
    GameController *gameController;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthOfView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;

@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (IBAction)startGamePressed:(UIButton *)sender;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    gameController = [GameController new];
    properties = [[Game sharedInstance] getGameProperties];
    
    [self resizeMainView];
    
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 6.0;
    [self updateZoom];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    
    [self.mainView setUserInteractionEnabled:NO];
    [self.mainView addGestureRecognizer:singleTapGestureRecognizer];
    
    [gameController setMainView:self.mainView];
    [gameController downloadImages];
    [self.startButton setUserInteractionEnabled: YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)resizeMainView
{
    self.widthOfView.constant = properties.elemWidth * properties.columnsCount;
    self.heightOfView.constant = properties.elemHieght * properties.rowsCount;
    [self.mainView setNeedsUpdateConstraints];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    
    [self updateZoom];
    float imageWidth = self.mainView.frame.size.width;
    float imageHeight = self.mainView.frame.size.height;
    
    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20;
    
    // center image if it is smaller than screen
    float hPadding = (viewWidth - imageWidth) / 2.0;
    if (hPadding < 0) hPadding = 0;
    
    float vPadding = (viewHeight - imageHeight) / 2.0;
    if (vPadding < 0) vPadding = 0;
    
    self.constraintLeft.constant = hPadding;
    self.constraintRight.constant = hPadding;
    self.constraintTop.constant = vPadding;
    self.constraintBottom.constant = vPadding;
    
    [self.view layoutIfNeeded];
    [self.view updateConstraintsIfNeeded];
}

- (void)updateZoom
{
    float minZoom = MIN(self.view.bounds.size.width / self.widthOfView.constant,
                        self.view.bounds.size.height / self.heightOfView.constant);
    self.scrollView.minimumZoomScale = (minZoom < 1) ? minZoom : 1;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mainView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    float imageWidth = self.mainView.frame.size.width;
    float imageHeight = self.mainView.frame.size.height;
    
    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20;
    
    // center image if it is smaller than screen
    float hPadding = (viewWidth - imageWidth) / 2.0;
    if (hPadding < 0) hPadding = 0;
    
    float vPadding = (viewHeight - imageHeight) / 2.0;
    if (vPadding < 0) vPadding = 0;
    
    self.constraintLeft.constant = hPadding;
    self.constraintRight.constant = hPadding;
    self.constraintTop.constant = vPadding;
    self.constraintBottom.constant = vPadding;
    
    // Makes zoom out animation smooth and starting from the right point not from (0, 0)
    [self.view layoutIfNeeded];
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint touchLocation = [tapGestureRecognizer locationInView:self.mainView];
    GamePoint *touchInGamePoint = [[Game sharedInstance] getGamePointFromCGPoint:touchLocation];
    
    if (touchInGamePoint.y == [gameController getEmptyPoint].y) {
        if (touchInGamePoint.x < [gameController getEmptyPoint].x) {
            [gameController moveImagesToRightFromX:touchInGamePoint.x];
        }
        if (touchInGamePoint.x > [gameController getEmptyPoint].x) {
            [gameController moveImagesToLeftFromX:touchInGamePoint.x];
        }
    }
    if (touchInGamePoint.x == [gameController getEmptyPoint].x) {
        if (touchInGamePoint.y < [gameController getEmptyPoint].y) {
            [gameController moveImagesToBottomFromY:touchInGamePoint.y];
        }
        if (touchInGamePoint.y > [gameController getEmptyPoint].y) {
            [gameController moveImagesToTopFromY:touchInGamePoint.y];
        }
    }
    
    if ([gameController checkForGameCompleated]) {
        [gameController endGame];
        [self.startButton setUserInteractionEnabled:YES];
        [self.mainView setUserInteractionEnabled:NO];
    }
}

- (IBAction)startGamePressed:(UIButton *)sender {
    [gameController startGame];
    [self.mainView setUserInteractionEnabled:YES];
    [self.startButton setUserInteractionEnabled: NO];
}
@end
