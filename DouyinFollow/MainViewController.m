//
//  MainViewController.m
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/20.
//

#import "MainViewController.h"
#import "FollowViewController.h"
#import "Masonry/Masonry.h"

@interface MainViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *underline;
@property (nonatomic, strong) FollowViewController *followVC;

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
  self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"互关", @"关注", @"粉丝", @"好友"]];
  self.segmentControl.selectedSegmentIndex = 1;

  //这里必须使用字典颜色
  [self.segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.grayColor}
                                    forState:UIControlStateNormal];
  [self.segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.blackColor}
                                    forState:UIControlStateSelected];

  [self.segmentControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];

  [self.view addSubview:self.segmentControl];

  self.segmentControl.translatesAutoresizingMaskIntoConstraints = NO;
  [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.view.mas_top).offset(70);
      make.left.equalTo(self.view.mas_left).offset(20);
      make.right.equalTo(self.view.mas_right).offset(-20);
      make.height.equalTo(@40);
  }];

  self.underline = [[UIView alloc] initWithFrame:[self underlineFrame:0]];
  self.underline.backgroundColor = [UIColor blackColor];
  self.underline.layer.cornerRadius = 1;
  [self.segmentControl addSubview:self.underline];
  [self setupPages];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self updateSegmentStyleAndUnderline];
}

- (CGRect)underlineFrame:(NSInteger)index {
    CGFloat segmentWidth = (self.view.bounds.size.width - 40) / 4;
    CGFloat underlineWidth = segmentWidth * 0.6;
    CGFloat x = segmentWidth * index + (segmentWidth - underlineWidth) / 2;
    return CGRectMake(x, 38, underlineWidth, 2);
}

- (void)setupPages {
  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  self.scrollView.pagingEnabled = YES;
  self.scrollView.showsHorizontalScrollIndicator = NO;
  self.scrollView.delegate = self;
  self.scrollView.bounces = NO;
  [self.view addSubview:self.scrollView];
  [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.segmentControl.mas_bottom).offset(20);
      make.left.equalTo(self.view.mas_left);
      make.right.equalTo(self.view.mas_right);
      make.bottom.equalTo(self.view.mas_bottom);
  }];
  NSArray *titles = @[@"暂无互关", @"关注页面", @"暂无粉丝", @"暂无朋友"];
  NSArray *colors = @[
      [UIColor whiteColor],
      [UIColor whiteColor],
      [UIColor whiteColor],
      [UIColor whiteColor]
  ];
  UIView *containerView = [[UIView alloc] init];
  [self.scrollView addSubview:containerView];
  [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self.scrollView);
      make.height.equalTo(self.scrollView);
  }];

  UIView *prevPage = nil;
  for (int i = 0; i < 4; i++) {
      UIView *page = [[UIView alloc] init];
      page.backgroundColor = colors[i];
      [containerView addSubview:page];      [page mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(containerView.mas_top);
            make.bottom.equalTo(containerView.mas_bottom);
            make.width.equalTo(self.view.mas_width);
            if (prevPage) {
                make.left.equalTo(prevPage.mas_right);
            } else {
                make.left.equalTo(containerView.mas_left);
            }
        }];

      if (i == 1) {
          FollowViewController *followVC = [[FollowViewController alloc] init];
          [page addSubview:followVC.view];
          [self addChildViewController:followVC];
          [followVC didMoveToParentViewController:self];
          self.followVC = followVC;

          [followVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
              make.edges.equalTo(page);
          }];
      } else {
          UILabel *label = [[UILabel alloc] init];
          label.text = titles[i];
          label.textAlignment = NSTextAlignmentCenter;
          label.textColor = [UIColor grayColor];
          label.font = [UIFont systemFontOfSize:16];
          [page addSubview:label];

          [label mas_makeConstraints:^(MASConstraintMaker *make) {
              make.centerX.equalTo(page.mas_centerX);
              make.top.equalTo(page.mas_top).offset(200);
              make.width.equalTo(@(self.view.bounds.size.width));
              make.height.equalTo(@40);
          }];
      }

      prevPage = page;
  }

  if (prevPage) {
      [prevPage mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.equalTo(containerView.mas_right);
      }];
  }
  dispatch_async(dispatch_get_main_queue(), ^{
      CGFloat width = self.view.bounds.size.width;
      [self.scrollView setContentOffset:CGPointMake(width, 0) animated:NO];
  });
}

- (void)segmentChanged:(UISegmentedControl *)seg {
    self.underline.frame = [self underlineFrame:seg.selectedSegmentIndex];
    CGFloat width = self.view.bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake(seg.selectedSegmentIndex * width, 0) animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / self.view.bounds.size.width;
    self.segmentControl.selectedSegmentIndex = index;
    self.underline.frame = [self underlineFrame:index];
}

- (void)updateSegmentStyleAndUnderline {
    NSInteger currentIndex = self.segmentControl.selectedSegmentIndex;
    self.underline.frame = [self underlineFrame:currentIndex];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;

    CGFloat segmentWidth = (self.view.bounds.size.width - 40) / 4;
    CGFloat underlineWidth = segmentWidth * 0.6;
    CGFloat percent = offsetX / self.view.bounds.size.width;

    CGFloat x = segmentWidth * percent + (segmentWidth - underlineWidth) / 2;

    self.underline.frame = CGRectMake(x, 38, underlineWidth, 2);
}
@end
