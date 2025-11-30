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
#import "FMDBManager.h"

@interface FollowViewController () <UITableViewDelegate, UITableViewDataSource, FollowTableViewCellDelegate, moreViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<FollowUserModel *> *users;
@property (nonatomic, assign) BOOL isLoadingMore;
- (NSMutableArray<FollowUserModel *> *)sortUsersBySpecialFollow:(NSArray<FollowUserModel *> *)userList;

@end

@implementation FollowViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"抖音关注";
  self.view.backgroundColor = [UIColor whiteColor];
  self.users = [NSMutableArray array];
  [NetworkManager sharedManager].group = 0;
  [NetworkManager sharedManager].hasMore = YES;
  [self setupTableView];
// [self loadFollowData];
//  NSDictionary *cache = [[NSUserDefaults standardUserDefaults] objectForKey:followKey];
//  if (cache) {
//      NSArray *users = [FollowUserModel arrayOfModelsFromDictionaries:cache error:nil];
//      for (FollowUserModel *m in users) {
//          [m loadLocalState];
//      }
//      self.users = [users mutableCopy];
//      [self.tableView reloadData];
//      [self sortUsersBySpecialFollow:nil];
//
//  }

  NSArray *lacalUsers = [[FMDBManager sharedManager] getUsersWithGroup:0 pageSize:13];
  if (lacalUsers.count > 0) {
    NSLog(@"从本地加载：%@",[NSDate date]);
    [self.users addObjectsFromArray:lacalUsers];
    [self.tableView reloadData];
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
  NSLog(@"刷新");
  [self loadFollowData];
}

- (void)loadFollowData {
  NSInteger group = [NetworkManager sharedManager].group;
  [[NetworkManager sharedManager] getFollowListWithGroup:[NetworkManager sharedManager].group success:^(NSArray<FollowUserModel *> * _Nonnull users, NSInteger nextGroup, BOOL hasMore) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.isLoadingMore = NO;
      //[self.users addObjectsFromArray:users];
      if (group == 0) {
        self.users = [users mutableCopy];
        [self.tableView reloadData];
      } else {
        NSInteger oldCount = self.users.count;
        [self.users addObjectsFromArray:users];

        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSInteger i = 0; i < users.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:oldCount + i inSection:0]];
        }

        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
      }
      //[self sortUsersBySpecialFollow:nil];
      [self.tableView reloadData];
      [self sortUsersBySpecialFollow:nil];
//                  [NetworkManager sharedManager].group = nextGroup;
//                  [NetworkManager sharedManager].hasMore = hasMore;

      NSLog(@"收到用户数量 = %ld", users.count);
      if (self.tableView.refreshControl.isRefreshing) {
        [self.tableView.refreshControl endRefreshing];
      }
    });
  } failure:^(NSString * _Nonnull error) {
    NSLog(@"请求失败");
    self.isLoadingMore = NO;
  }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![NetworkManager sharedManager].hasMore) return;
    if (self.isLoadingMore) return;

    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat visibleHeight = scrollView.frame.size.height;

    //提前 800 像素预加载）
    if (offsetY > contentHeight - visibleHeight - 800) {
        self.isLoadingMore = YES;
        [self loadFollowData];
    }
}


- (NSMutableArray<FollowUserModel *> *)sortUsersBySpecialFollow:(NSArray<FollowUserModel *> *)userList {
  NSMutableArray *targetArray = userList ? [userList mutableCopy] : [self.users mutableCopy];
  if (targetArray.count == 0) return [NSMutableArray array];

  NSMutableArray *special = [NSMutableArray array];
  NSMutableArray *normal = [NSMutableArray array];

  for (FollowUserModel *user in targetArray) {
      if (user.isSpecialBool) {
          [special addObject:user];
      } else {
          [normal addObject:user];
      }
  }
  NSMutableArray *result = [NSMutableArray arrayWithArray:special];
  [result addObjectsFromArray:normal];

  if (!userList) {
      self.users = result;
      [self.tableView reloadData];
  }

  return result;
}

//工具方法，简单工厂思想
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
  [self sortUsersBySpecialFollow:nil];
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
