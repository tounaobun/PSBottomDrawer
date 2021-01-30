//
//  PSBottomDrawer.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSBottomDrawer.h"
#import <Masonry/Masonry.h>
#import "UIView+Frame.h"

static const CGFloat kAnimateDuration = 0.25f;
static const NSInteger kUndraggableTag = 888;

@interface PSBottomDrawer ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIControl *dimmingView;
@property (nonatomic, strong) UIView *drawerContainer;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) UIEdgeInsets contentViewMargin;

@end

@implementation PSBottomDrawer

- (instancetype)init {
    if (self = [super init]) {
        [self configBaseView];
        [self addPanGestures];
    }
    return self;
}

- (void)setContentView:(UIView *)contentView {
    [self setContentView:contentView margin:UIEdgeInsetsZero];
}

- (void)setContentView:(UIView *)contentView margin:(UIEdgeInsets)margin {
    assert(_contentView == nil);
    _contentView = contentView;
    _contentViewMargin = margin;
    [self configContentView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(24.f, 24.f)];
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.path = path.CGPath;
    self.layer.mask = mask;
}

- (void)addPanGestures {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}

- (void)configBaseView {
    
    self.backgroundColor = [UIColor clearColor];
    // add dimming View
    [self addSubview:self.dimmingView];
    [self.dimmingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    // add drawer container
    [self addSubview:self.drawerContainer];
    [self.drawerContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.mas_bottom);
    }];
}

- (void)configContentView {
    [self.drawerContainer addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.drawerContainer).offset(self.contentViewMargin.left);
        make.top.equalTo(self.drawerContainer).offset(self.contentViewMargin.top + 24.f);
        make.right.equalTo(self.drawerContainer).offset(-self.contentViewMargin.right);
        make.bottom.equalTo(self.drawerContainer).offset(-self.contentViewMargin.bottom);
    }];
    
    UIScrollView *scrollView = [self findScrollViewInContentView:self.contentView];
    scrollView.delegate = self;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSArray *undraggableViews = [self findUndraggbleViewInContentView:self.contentView];
    for (UIView *unDraggableView in undraggableViews) {
        CGPoint point = [touch locationInView:unDraggableView];
        if (CGRectContainsPoint(unDraggableView.bounds, point)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Public Methods

- (void)presentToView:(UIView *)parentView {
    
    [self _presentToView:parentView];
}

- (void)presentToKeyWindow {
    
    [self _presentToView:[UIApplication sharedApplication].keyWindow];
}

- (void)dismissDrawer {
    [self _slideDrawerUp:NO animated:YES];
}

#pragma mark - Private Methods

- (UIScrollView *)findScrollViewInContentView:(UIView *)contentView {
    if ([contentView isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)contentView;
    }
    
    for (UIView *subView in contentView.subviews) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)subView;
        }
    }
    return nil;
}

- (NSArray *)findUndraggbleViewInContentView:(UIView *)contentView {
    NSMutableArray *unDraggbleViews = @[].mutableCopy;
    if (contentView.tag == kUndraggableTag) {
        [unDraggbleViews addObject:contentView];
    }
    
    for (UIView *subView in contentView.subviews) {
        if (subView.tag == kUndraggableTag) {
            [unDraggbleViews addObject:subView];
        }
    }
    return unDraggbleViews.copy;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < 0) {
        scrollView.panGestureRecognizer.enabled = NO;
    } else {
        scrollView.panGestureRecognizer.enabled = YES;
    }
}

- (void)onDrag:(UIPanGestureRecognizer *)sender {
    
    CGFloat percentThreshold = 0.35f;
    CGFloat minimumVelocitySpeed = 300.f;
    CGPoint translation = [sender translationInView:self.drawerContainer];
    
    [sender setTranslation:CGPointZero inView:self.drawerContainer];
    
    CGFloat newY = self.drawerContainer.y + translation.y;
    newY = MAX(newY, self.height - self.drawerContainer.height);
    
    CGFloat progress = (newY - (self.height - self.drawerContainer.height)) / self.drawerContainer.height;
    
    UIScrollView *scrollView = [self findScrollViewInContentView:self.contentView];
    if (scrollView) {
        if (scrollView.contentOffset.y > 0) {
            return;
        }
    }

    self.drawerContainer.y = newY;
    self.dimmingView.alpha = 1 - progress;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [sender velocityInView:self.drawerContainer];
        if (velocity.y > minimumVelocitySpeed || progress > percentThreshold) {
            [self dismissDrawer];
        } else {
            [UIView animateWithDuration:kAnimateDuration animations:^{
                self.drawerContainer.y = self.height - self.drawerContainer.height;
                self.dimmingView.alpha = 1.f;
            }];
        }
        
    }
}

- (void)_presentToView:(UIView *)parentView {
    [parentView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    [self layoutIfNeeded];
    [self _slideDrawerUp:YES animated:YES];
}

- (void)_slideDrawerUp:(BOOL)slideUp animated:(BOOL)animated {
    [UIView animateWithDuration:(animated ? kAnimateDuration : 0) animations:^{
        //
        self.dimmingView.alpha = slideUp ? 1.f : 0.f;
        [self.drawerContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            CGFloat containerHeight = [self.drawerContainer systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
            make.top.equalTo(self.mas_bottom).offset(slideUp ? -containerHeight : 0);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished && !slideUp) {
            !self.drawerCloseBlock?:self.drawerCloseBlock();
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Action Methods

#pragma mark - Property Getters

- (UIControl *)dimmingView {
    if (!_dimmingView) {
        _dimmingView = [[UIControl alloc] init];
        _dimmingView.alpha = 0;
        _dimmingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [_dimmingView addTarget:self action:@selector(dismissDrawer) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dimmingView;
}

- (UIView *)drawerContainer {
    if (!_drawerContainer) {
        _drawerContainer = [[UIView alloc] init];
        _drawerContainer.backgroundColor = [UIColor whiteColor];
        
        // add top line
        UIView *topLine = [[UIView alloc] init];
        topLine.backgroundColor = [UIColor colorWithRed:0xD8 green:0xD8 blue:0xD8 alpha:1];
        topLine.layer.cornerRadius = 3.f;
        [_drawerContainer addSubview:topLine];
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_drawerContainer);
            make.top.equalTo(_drawerContainer).offset(15);
            make.size.mas_equalTo(CGSizeMake(49, 6));
        }];
    }
    return _drawerContainer;
}

@end
