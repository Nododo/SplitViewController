//
//  JZGDetailController.m
//  JZGChryslerForPad
//
//  Created by 杜维欣 on 16/4/18.
//  Copyright © 2016年 Beijing JingZhenGu Information Technology Co.Ltd. All rights reserved.
//

#import "JZGDetailViewController.h"
#import "JZGTableView.h"
#import "JZGDetailContentFlowLayout.h"

static NSString * const collectionID  = @"collectionID";
static NSString * const tableID       = @"tableID";
static CGFloat  const tableCellHeight = 100;


@interface JZGDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic,weak)JZGTableView *leftMenu;

@property (nonatomic,weak)UICollectionView *contentScrollView;

@end

@implementation JZGDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.leftMenu registerClass:[UITableViewCell class] forCellReuseIdentifier:tableID];
    [self.contentScrollView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionID];
    [self.contentScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self.contentScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addViewControllers];
}

#pragma mark - 添加各个控制器

- (void)addViewControllers {
    for (int i = 0; i < 5; i ++) {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = kRandomColor;
        vc.title = [NSString stringWithFormat:@"%d",i];
        [self addChildViewController:vc];
    }
}

#pragma mark - lazy methods

- (JZGTableView *)leftMenu {
    if (!_leftMenu) {
        JZGTableView *leftMenu = [[JZGTableView alloc] init];
//        leftMenu.bounces = NO; 是否允许没占满的情况下滑动
        leftMenu.delegate = self;
        leftMenu.dataSource = self;
        [self.view addSubview:leftMenu];
        _leftMenu = leftMenu;
    }
    return _leftMenu;
}

- (UICollectionView *)contentScrollView {
    if (!_contentScrollView) {
        JZGDetailContentFlowLayout *layout = [[JZGDetailContentFlowLayout alloc] init];
        UICollectionView *contentScrollView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        contentScrollView.backgroundColor = [UIColor whiteColor];
        contentScrollView.delegate = self;
        contentScrollView.dataSource = self;
        contentScrollView.scrollEnabled = NO;
        [self.view addSubview:contentScrollView];
        _contentScrollView = contentScrollView;
    }
    return _contentScrollView;
}

#pragma mark - 界面布局

- (void)viewDidLayoutSubviews
{
    [_leftMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.top.equalTo(@(0));
        make.width.equalTo(self.view).multipliedBy(DETAILMENUPERCENT);
        make.height.equalTo(self.view);
    }];
    
    [_contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftMenu.mas_right);
        make.top.equalTo(@(0));
        make.width.equalTo(self.view).multipliedBy(1 - DETAILMENUPERCENT);
        make.height.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.childViewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableID forIndexPath:indexPath];
    cell.backgroundColor = kRandomColor;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_contentScrollView setContentOffset:CGPointMake(0, indexPath.row * self.view.height)];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.childViewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionID forIndexPath:indexPath];

    UIViewController *vc = self.childViewControllers[indexPath.row];
    
    vc.view.frame = CGRectMake(0, 0, self.contentScrollView.width, self.contentScrollView.height);
    
    [cell.contentView addSubview:vc.view];
    
    return cell;
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint newPoint = [change[@"new"] CGPointValue];
        CGFloat contentY = newPoint.y;
        int row = contentY / self.view.height;
        [self setRootNavigationTitle: self.childViewControllers[row].title];
        [_leftMenu selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

@end
