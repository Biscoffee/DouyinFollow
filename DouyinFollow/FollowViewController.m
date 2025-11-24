//
//  FollowViewController.m
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/20.
//

#import "FollowViewController.h"
#import "FollowUserModel.h"
#import "FollowTableViewCell.h"
#import "NetworkManager.h"
#import "moreViewController.h"
#import <Masonry/Masonry.h>

@interface FollowViewController () <UITableViewDelegate, UITableViewDataSource, FollowTableViewCellDelegate, moreViewControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<FollowUserModel *> *users;
- (NSMutableArray<FollowUserModel *> *)sortUsersBySpecialFollow:(NSArray<FollowUserModel *> *)userList;
- (void)sortUsersBySpecialFollow;
@end

@implementation FollowViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"抖音关注";
  self.view.backgroundColor = [UIColor whiteColor];
  self.users = [NSMutableArray array];
  [self setupTableView];
  NSDictionary *cache = [[NSUserDefaults standardUserDefaults] objectForKey:followKey];
  if (cache) {
    NSArray *data = cache[@"data"];
    NSArray *users = [FollowUserModel arrayOfModelsFromDictionaries:data error:nil];
    for (FollowUserModel *m in users) {
        [m loadLocalState];
    }
    self.users = [users mutableCopy];
    [self.tableView reloadData];
    [self sortUsersBySpecialFollow:nil];
  }

  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [self loadFollowData];
  });
}

- (void)setupTableView {
  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.rowHeight = 72;
  //不再自适应计算，直接禁用
  self.tableView.estimatedSectionHeaderHeight = 0;
  self.tableView.estimatedSectionFooterHeight = 0;
  //可以提前布局
  self.tableView.estimatedRowHeight = 72;

  [self.tableView registerClass:[FollowTableViewCell class] forCellReuseIdentifier:@"FollowCell"];
  self.tableView.tableFooterView = [UIView new];
  self.tableView.showsVerticalScrollIndicator = NO;
  [self.view addSubview:self.tableView];
  [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) { make.edges.equalTo(self.view); }];

  UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
  [refresh addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
  self.tableView.refreshControl = refresh;
}

- (void)handleRefresh {
  [self loadFollowDataWithRefresh:YES];
}

- (void)loadFollowData {
  [self loadFollowDataWithRefresh:NO];
}

- (void)loadFollowDataWithRefresh:(BOOL)isRefresh {
    NSLog(@"现在时间%@", [NSDate date]);
    [[NetworkManager sharedManager] getFollowListSuccess:^(NSArray<FollowUserModel *> *userList) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *sortedUsers = [self sortUsersBySpecialFollow:userList];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"UI渲染时间：%@", [NSDate date]);
                self.users = sortedUsers;
                [self.tableView reloadData];
                if (isRefresh && self.tableView.refreshControl.refreshing) {
                    [self.tableView.refreshControl endRefreshing];
                }
            });
        });
    } failure:^(NSString *errorMsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRefresh && self.tableView.refreshControl.refreshing) {
                [self.tableView.refreshControl endRefreshing];
            }
            [self showAlertWithMessage:errorMsg];
        });
    }];
}



- (NSMutableArray<FollowUserModel *> *)sortUsersBySpecialFollow:(NSArray<FollowUserModel *> *)userList {
    // 如果传入了数组，就排序传入的数组；没传入就用当前self.users
    NSArray *targetArray = userList ?: self.users;
    if (targetArray.count == 0) return [NSMutableArray array];

    // 核心排序逻辑（只写一次）
    NSArray *sortedArray = [targetArray sortedArrayUsingComparator:^NSComparisonResult(FollowUserModel *u1, FollowUserModel *u2) {
        if (u1.isSpecialBool && !u2.isSpecialBool) {
            return NSOrderedAscending; // 特别关注排前面
        } else if (!u1.isSpecialBool && u2.isSpecialBool) {
            return NSOrderedDescending; // 普通关注排后面
        } else {
            return NSOrderedSame; // 保持原有顺序
        }
    }];

    NSMutableArray *result = [sortedArray mutableCopy];

    // 如果是对self.users排序（没传入数组），直接更新并刷新UI
    if (!userList) {
        self.users = result;
        [self.tableView reloadData];
    }

    return result;
}


- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowCell" forIndexPath:indexPath];
  [cell setupWithModel:self.users[indexPath.row]];
  cell.delegate = self;
  return cell;
}

- (void)followCell:(FollowTableViewCell *)cell didClickFollowBtnWithModel:(FollowUserModel *)model {
    model.isFollowing = @(!model.isFollowingBool);
    if (!model.isFollowingBool) {
        model.isSpecial = @NO;
        model.isMutualFollow = @NO;
    }
    [model saveLocalState];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) return;

    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];

    [self sortUsersBySpecialFollow];
}

- (void)followCell:(FollowTableViewCell *)cell didClickMoreBtnWithModel:(FollowUserModel *)model {
  if (!model.isFollowingBool) {
      [self showAlertWithMessage:@"未关注，无法使用"];
      return;
  }
  moreViewController *moreVC = [[moreViewController alloc] initWithModel:model];
  moreVC.delegate = self;
  [self presentViewController:moreVC animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  FollowUserModel *model = self.users[indexPath.row];
  NSString *msg = [NSString stringWithFormat:@"已选中：%@", model.shownName];

  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                 message:msg
                                                          preferredStyle:UIAlertControllerStyleAlert];
  [self presentViewController:alert animated:YES completion:nil];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [alert dismissViewControllerAnimated:YES completion:nil];
  });

  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)userChangeIfspecial:(FollowUserModel *)model isSpecial:(BOOL)isSpecial {
  model.isSpecial = @(isSpecial);
  [model saveLocalState];
  [self sortUsersBySpecialFollow:nil];
  NSString *message = isSpecial ? @"已设为特别关注" : @"已取消特别关注";
  [self showAlertWithMessage:message];
//  [self.tableView reloadData];
}

- (void)userRemark:(FollowUserModel *)model remark:(NSString *)remark {
  model.remarkName = remark;
  [model saveLocalState];
  [self.tableView reloadData];
  [self showAlertWithMessage:@"备注已保存"];
}

- (void)userCancelledFollow:(FollowUserModel *)model {
  model.isFollowing = @NO;
  model.isSpecial = @NO;
  [model saveLocalState];
  [self.tableView reloadData];
  [self showAlertWithMessage:@"已取消关注"];
}


@end
