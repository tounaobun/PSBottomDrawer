//
//  ViewController.m
//  PSBottomDrawer
//
//  Created by Benson Tommy on 2021/1/30.
//

#import "ViewController.h"
#import "PSBottomListDrawer.h"

@interface ViewController ()

@property (nonatomic, strong) PSBottomListDrawer *drawer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)openDrawer:(id)sender {
    
    NSMutableArray *titlesArray = @[].mutableCopy;
    for (int i = 0; i < 5; i++) {
        [titlesArray addObject:[NSString stringWithFormat:@"title:%@", @(i)]];
    }
    
    PSBottomDrawer *drawer = [[PSBottomListDrawer alloc] initWithItems:titlesArray];
    [drawer presentToKeyWindow];
}

@end
