//
//  moreViewController.m
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/22.
//

#import "moreViewController.h"
#import "FollowUserModel.h"
#import "FollowViewController.h"
#import <Masonry/Masonry.h>

@interface moreViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) FollowUserModel *model;
@property (nonatomic, strong) UISwitch *specialSwitch;

@end

@implementation moreViewController

- (instancetype)initWithModel:(FollowUserModel *)model {
  self = [super init];
  if (self) {
      self.model = model;
      self.modalPresentationStyle = UIModalPresentationOverFullScreen;//覆盖于屏幕，背后的内容不可交互

      self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;//淡入设置
  }
  return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self setupSubviews];
}

- (void)setupSubviews {
  UIView *container = [[UIView alloc] init];
  container.backgroundColor = [UIColor systemGray6Color];
  container.layer.cornerRadius = 12;
  [self.view addSubview:container];
  [container mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.equalTo(self.view);
      make.bottom.equalTo(self.view);
      make.height.mas_equalTo(340);
  }];

  UILabel *titleLabel = [[UILabel alloc] init];
  titleLabel.text = self.model.shownName;
  titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
  [container addSubview:titleLabel];
  [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(container).offset(20);
      make.left.equalTo(container).offset(20);
  }];

  UILabel *idLabel = [[UILabel alloc] init];
  idLabel.text = [NSString stringWithFormat:@"抖音号: %@", self.model.userId];
  idLabel.font = [UIFont systemFontOfSize:12];
  idLabel.textColor = [UIColor grayColor];
  [container addSubview:idLabel];
  [idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(titleLabel.mas_bottom).offset(8);
      make.left.equalTo(container).offset(20);
  }];

  UIView *specialView = [[UIView alloc] init];
  [container addSubview:specialView];
  specialView.backgroundColor = [UIColor whiteColor];
  specialView.layer.cornerRadius = 3;
 [specialView mas_makeConstraints:^(MASConstraintMaker *make) {
   make.top.equalTo(idLabel.mas_bottom).offset(20);
   make.left.right.equalTo(container);
   make.height.mas_equalTo(55);
 }];

  UILabel *specialLabel = [[UILabel alloc] init];
  specialLabel.text = @"特别关注";
  specialLabel.font = [UIFont systemFontOfSize:16];
  [specialView addSubview:specialLabel];
  [specialLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(specialView).offset(20);
      make.centerY.equalTo(specialView).offset(-8);
  }];

  UILabel *specialDesc = [[UILabel alloc] init];
  specialDesc.text = @"作品优先推荐，更新及时提示";
  specialDesc.font = [UIFont systemFontOfSize:10];
  specialDesc.textColor = [UIColor grayColor];
  [specialView addSubview:specialDesc];
  [specialDesc mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(specialLabel);
      make.top.equalTo(specialLabel.mas_bottom).offset(2);
  }];

  _specialSwitch = [[UISwitch alloc] init];
//ai说：iOS本质上不允许修改Switch的frame，所以必须使用transform，但是我修改他和Masonry后依旧不能实现这个swtch的缩小 固在这搁置
//_specialSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
  _specialSwitch.on = self.model.isSpecialBool;
  [_specialSwitch addTarget:self action:@selector(specialSwitchChanged:)
           forControlEvents:UIControlEventValueChanged];
  [specialView addSubview:_specialSwitch];
  [_specialSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerY.equalTo(specialView);
      make.right.equalTo(specialView).offset(-20);
  }];

  UIView *line1 = [[UIView alloc] init];
  line1.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
  [container addSubview:line1];
  [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(specialView.mas_bottom).offset(10);
      make.left.right.equalTo(container).inset(20);
      make.height.mas_equalTo(0.5);
  }];

  UIButton *groupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  [container addSubview:groupBtn];
  groupBtn.backgroundColor = [UIColor whiteColor];
  groupBtn.layer.cornerRadius = 3;
  [groupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(line1.mas_bottom);
      make.left.right.equalTo(container);
      make.height.mas_equalTo(50);
  }];

  UILabel *groupLabel = [[UILabel alloc] init];
  groupLabel.text = @"设置分组";
  groupLabel.font = [UIFont systemFontOfSize:16];
  [groupBtn addSubview:groupLabel];
  [groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(groupBtn).offset(20);
      make.centerY.equalTo(groupBtn);
  }];

  UIImageView *groupIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jiedianhuiyuanfenzu.png"]];
  groupIcon.contentMode = UIViewContentModeScaleAspectFit;
  [groupBtn addSubview:groupIcon];
  [groupIcon mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(groupBtn).offset(-20);
      make.centerY.equalTo(groupBtn);
      make.width.height.mas_equalTo(20);
  }];

  [groupBtn addTarget:self action:@selector(groupBtnClicked) forControlEvents:UIControlEventTouchUpInside];

  UIView *line2 = [[UIView alloc] init];
  line2.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
  [container addSubview:line2];
  [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(groupBtn.mas_bottom);
      make.left.right.equalTo(container).inset(20);
      make.height.mas_equalTo(0.5);
  }];

  UIButton *remarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  [container addSubview:remarkBtn];
  remarkBtn.backgroundColor = [UIColor whiteColor];
  remarkBtn.layer.cornerRadius = 3;
  [remarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(line2.mas_bottom);
      make.left.right.equalTo(container);
      make.height.mas_equalTo(50);
  }];

  UILabel *remarkLabel = [[UILabel alloc] init];
  remarkLabel.text = @"设置备注";
  remarkLabel.font = [UIFont systemFontOfSize:16];
  [remarkBtn addSubview:remarkLabel];
  [remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(remarkBtn).offset(20);
      make.centerY.equalTo(remarkBtn);
  }];

  UIImageView *remarkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bianxie.png"]];
  remarkIcon.contentMode = UIViewContentModeScaleAspectFit;
  [remarkBtn addSubview:remarkIcon];
  [remarkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(remarkBtn).offset(-20);
      make.centerY.equalTo(remarkBtn);
      make.width.height.mas_equalTo(20);
  }];

  [remarkBtn addTarget:self action:@selector(remarkBtnClicked) forControlEvents:UIControlEventTouchUpInside];

  UIView *line3 = [[UIView alloc] init];
  line3.backgroundColor = [UIColor systemGray5Color];
  [container addSubview:line3];
  [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(remarkBtn.mas_bottom);
      make.left.right.equalTo(container);
      make.height.mas_equalTo(12);
  }];

  UIButton *unfollowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  [container addSubview:unfollowBtn];
  [unfollowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(line3.mas_bottom);
      make.left.right.equalTo(container);
      make.height.mas_equalTo(50);
  }];

  UILabel *unfollowLabel = [[UILabel alloc] init];
  unfollowLabel.text = @"取消关注";
  unfollowBtn.backgroundColor = [UIColor whiteColor];
  unfollowLabel.textColor = [UIColor redColor];
  unfollowLabel.font = [UIFont systemFontOfSize:16];
  [unfollowBtn addSubview:unfollowLabel];
  [unfollowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(unfollowBtn).offset(20);
      make.centerY.equalTo(unfollowBtn);
  }];

  UIImageView *unfollowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"minus.png"]];
  unfollowIcon.contentMode = UIViewContentModeScaleAspectFit;
  [unfollowBtn addSubview:unfollowIcon];
  [unfollowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(unfollowBtn).offset(-20);
      make.centerY.equalTo(unfollowBtn);
      make.width.height.mas_equalTo(20);
  }];

  [unfollowBtn addTarget:self action:@selector(unfollowBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    //识别手势实现点击背景关闭
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissThisPage)];
  tap.delegate = self;
  [self.view addGestureRecognizer:tap];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
  shouldReceiveTouch:(UITouch *)touch {
      //c i处判断避免在container关闭
  return ![touch.view isDescendantOfView:self.view.subviews.firstObject];
}

- (void)specialSwitchChanged:(UISwitch *)sender {
  if ([self.delegate respondsToSelector:@selector(userChangeIfspecial:isSpecial:)]) {
      [self.delegate userChangeIfspecial:self.model isSpecial:sender.on];
  }
}

- (void)remarkBtnClicked {
  UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"设置备注" message:nil preferredStyle:UIAlertControllerStyleAlert];
  [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      textField.placeholder = @"请输入备注";
      textField.text = self.model.remarkName;
  }];
  [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
  [ac addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      NSString *remark = ac.textFields.firstObject.text ?: @"";
      if ([self.delegate respondsToSelector:@selector(userRemark:remark:)]) {
          [self.delegate userRemark:self.model remark:remark];
      }
    [self dismissViewControllerAnimated:YES completion:nil];
  }]];
  [self presentViewController:ac animated:YES completion:nil];
}

- (void)unfollowBtnClicked {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认取消关注？" message:nil preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
  [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
      if ([self.delegate respondsToSelector:@selector(userCancelledFollow:)]) {
          [self.delegate userCancelledFollow:self.model];
      }
    [self dismissViewControllerAnimated:YES completion:nil];
  }]];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)groupBtnClicked {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                 message:@"此功能暂未开放"
                                                          preferredStyle:UIAlertControllerStyleAlert];
  [self presentViewController:alert animated:YES completion:nil];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [alert dismissViewControllerAnimated:YES completion:nil];
    [self dismissThisPage];
  });
//  [self dismissThisPage];
}

- (void)dismissThisPage {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


