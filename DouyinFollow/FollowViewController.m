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
#import "SDWebImage/SDWebImage.h"

@interface FollowViewController () <UITableViewDelegate, UITableViewDataSource, FollowTableViewCellDelegate, moreViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<FollowUserModel *> *users;
@property (nonatomic, assign) BOOL isLoadingMore;
- (NSMutableArray<FollowUserModel *> *)sortUsersBySpecialFollow:(NSArray<FollowUserModel *> *)userList;

@end

@implementation FollowViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  //[[FMDBManager sharedManager] resetDB];
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
  NSLog(@"localUSers:%@",lacalUsers);
  if (lacalUsers.count > 0) {
    NSLog(@"从本地加载：%ld跳数据，时间：%@ ",lacalUsers.count, [NSDate date]);
    self.users = [lacalUsers mutableCopy];
    [self.tableView reloadData];
  }
  //dispatch_async(dispatch_get_global_queue(0, 0), ^{
  [self loadFollowData];
  //});
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
  NSLog(@"开始请求 group：%ld", group);
    [[NetworkManager sharedManager] getFollowListWithGroup:group
                                                   success:^(NSArray<FollowUserModel *> * _Nonnull users,
                                                             NSInteger nextGroup,
                                                             BOOL hasMore) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSLog(@"请求成功，返回用户数量 = %ld, nextGroup = %ld, hasMore = %d",users.count, nextGroup, hasMore);
            self.isLoadingMore = NO;
          if (users.count > 0) {
            [[FMDBManager sharedManager] saveUsers:users];
          }
          NSArray *finalUsers = [[FMDBManager sharedManager] getUsersWithGroup:group pageSize:13];
            if (group == 0) {
              if (users.count > 0) {
                NSLog(@"重制前:%ld",self.users.count);
               // [[FMDBManager sharedManager] resetDB];
                self.users = [users mutableCopy];
//                [[FMDBManager sharedManager] saveUsers:users];
//                NSLog(@"重制后:%ld",self.users.count);
//                [self.tableView reloadData];
              }
            } else {
              NSLog(@"追加前: %ld",self.users.count);
                [self.users addObjectsFromArray:users];
              NSLog(@"追加后: %ld",self.users.count);
              [[FMDBManager sharedManager] saveUsers:users];
            }
            [self sortUsersBySpecialFollow:nil];
            [self.tableView reloadData];
            [NetworkManager sharedManager].group = nextGroup;
            [NetworkManager sharedManager].hasMore = hasMore;
            if (self.tableView.refreshControl.isRefreshing) {
                [self.tableView.refreshControl endRefreshing];
            }

            NSLog(@"收到用户数量 = %ld", users.count);
        });
    } failure:^(NSString * _Nonnull error) {
        NSLog(@"请求失败");
        self.isLoadingMore = NO;

        // 如果刷新控件在刷新，结束刷新
        if (self.tableView.refreshControl.isRefreshing) {
            [self.tableView.refreshControl endRefreshing];
        }
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
  if (scrollView.isDragging) {
    NSLog(@"dragging");
    [[SDWebImageManager sharedManager] cancelAll];
  } else if (scrollView.isDecelerating){
    NSArray<NSURL *> *prefetchURLS = [self nextScreenImageURLs];
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchURLS];
  }else {
    NSLog(@"非isDragging非isDeclerating");
  }
}

- (NSArray<NSURL *> *)nextScreenImageURLs {
  NSArray *visible = [self.tableView indexPathsForVisibleRows];
  if (visible.count == 0) return @[];

  //最后一个 cell 的 indexPath
  NSIndexPath *last = [visible lastObject];
  NSInteger start = last.row + 1;
  NSInteger end = MIN(start + 13, self.users.count - 1); //下一屏幕

  NSMutableArray *urls = [NSMutableArray array];
  for (NSInteger i = start; i <= end; i++) {
      FollowUserModel *m = self.users[i];
      if (m.avatar.length > 0) {
          NSURL *url = [NSURL URLWithString:m.avatar];
          if (url) [urls addObject:url];
      }
  }
  NSLog(@"next");
  return urls;
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


#pragma mark - 列表滑动时暂停加载 停止时恢复
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  NSLog(@"预加载1");
    NSArray<NSURL *> *prefetchURLS = [self nextScreenImageURLs];
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchURLS];

    NSArray *cells = self.tableView.visibleCells;
    for (FollowTableViewCell *cell in cells) {
        [cell setupWithModel:cell.currentModel];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  NSLog(@"预加载2");
  if (!decelerate) {
    NSArray<NSURL *> *prefetchURLS = [self nextScreenImageURLs];
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchURLS];

    NSArray *cells = self.tableView.visibleCells;
    for (FollowTableViewCell *cell in cells) {
        [cell setupWithModel:cell.currentModel];
    }
  }
}


@end
