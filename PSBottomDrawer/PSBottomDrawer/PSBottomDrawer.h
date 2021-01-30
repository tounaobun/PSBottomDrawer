//
//  PSBottomDrawer.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BottomDrawerDidCloseBlock)(void);

/// Drawer slided from bottom.
@interface PSBottomDrawer : UIView

/// drawer close block
@property (nonatomic, copy) BottomDrawerDidCloseBlock drawerCloseBlock;

/**
 * set Content View only once with margin set to (0,0,0,0)
 */
- (void)setContentView:(UIView *)contentView;

- (void)setContentView:(UIView *)contentView margin:(UIEdgeInsets)margin;

/*
 * Slide drawer in its parent View.
 */
- (void)presentToView:(UIView *)parentView;

/*
 * Slide drawer in key window.
 */
- (void)presentToKeyWindow;

/*
 * Dismiss Drawer
 */
- (void)dismissDrawer;

@end
