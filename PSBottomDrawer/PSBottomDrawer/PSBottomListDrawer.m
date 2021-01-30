//
//  PSBottomListDrawer.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSBottomListDrawer.h"
#import <Masonry/Masonry.h>

@interface PSBottomListDrawer ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<NSString *> *items;

@end

@implementation PSBottomListDrawer

- (instancetype)initWithItems:(NSArray<NSString *> *)items {
    if (self = [super init]) {
        self.items = items;
        [self setContentView:self.tableView margin:UIEdgeInsetsMake(30, 0, 30, 0)];
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    !self.pickListItemBlock?:self.pickListItemBlock(indexPath.row);
    [self dismissDrawer];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.items[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
    cell.textLabel.text = title;
    return cell;
}

#pragma mark - Property Getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.items.count * 60);
        }];
    }
    return _tableView;
}

@end
