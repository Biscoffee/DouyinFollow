//
//  FollowTableViewCell.m
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/20.
//

#import "FollowTableViewCell.h"
#import "FollowUserModel.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>

static SDImageRoundCornerTransformer *avatarTransformer = nil;

@interface FollowTableViewCell ()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *specialTagLabel;
@property (nonatomic, strong) UIImageView *vImageView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *followBtn;
@property (nonatomic, strong) UIButton *moreBtn;

@end

@implementation FollowTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      [self setupStarCell];
      [self setupPositionWithMasonry];
  }
  return self;
}

- (void)setupStarCell {
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  self.backgroundColor = [UIColor whiteColor];

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      avatarTransformer = [SDImageRoundCornerTransformer transformerWithRadius:20
                                                                       corners:UIRectCornerAllCorners
                                                                   borderWidth:0
                                                                   borderColor:nil];
  });
  _avatarView = [[UIImageView alloc] init];
  _avatarView.clipsToBounds = NO;
  _avatarView.backgroundColor = [UIColor systemGray4Color];
  [self.contentView addSubview:_avatarView];

  _nameLabel = [[UILabel alloc] init];
  _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
  _nameLabel.textColor = [UIColor blackColor];
  [self.contentView addSubview:_nameLabel];

  _vImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"daV.png"]];
  _vImageView.contentMode = UIViewContentModeScaleAspectFit;
  _vImageView.hidden = YES;
  [self.contentView addSubview:_vImageView];

  _specialTagLabel = [[UILabel alloc] init];
  _specialTagLabel.text = @"特别关注";
  _specialTagLabel.font = [UIFont systemFontOfSize:12];
  _specialTagLabel.textColor = [UIColor grayColor];
//  _specialTagLabel.layer.borderColor = [UIColor grayColor].CGColor;
  //这两个为了ui
//  _specialTagLabel.layer.borderWidth = 0.5;
//  _specialTagLabel.layer.cornerRadius = 2.0;
//  _specialTagLabel.layer.masksToBounds = YES;
  _specialTagLabel.textAlignment = NSTextAlignmentCenter;
  _specialTagLabel.hidden = YES;
  [self.contentView addSubview:_specialTagLabel];

  _followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  _followBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
//  _followBtn.layer.cornerRadius = 3;
//  _followBtn.clipsToBounds = NO;
  [_followBtn addTarget:self action:@selector(followBtnClicked) forControlEvents:UIControlEventTouchUpInside];
  [self.contentView addSubview:_followBtn];

  _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  UIImage *moreImage = [UIImage imageNamed:@"gengduo-2.png"];
  [_moreBtn setImage:moreImage forState:UIControlStateNormal];
  _moreBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
  [_moreBtn addTarget:self action:@selector(moreBtnClicked) forControlEvents:UIControlEventTouchUpInside];
  [self.contentView addSubview:_moreBtn];

  _lineView = [[UIView alloc] init];
  _lineView.backgroundColor = [UIColor systemGrayColor];
  [self.contentView addSubview:_lineView];
}

- (void)setupPositionWithMasonry {
  [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView).offset(16);
    make.centerY.equalTo(self.contentView);
    make.width.height.equalTo(@40);
  }];

  [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.avatarView.mas_right).offset(12);
    make.centerY.equalTo(self.contentView);
  }];

  [self.vImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.nameLabel.mas_right).offset(4);
    make.centerY.equalTo(self.nameLabel);
    make.width.height.equalTo(@20);
  }];

  [self.specialTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.vImageView.mas_right).offset(6);
      make.centerY.equalTo(self.nameLabel);
      make.width.equalTo(@60);
      make.height.equalTo(@18);
    }];
//  if (self.currentModel.isV){
//    [self.specialTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//      make.left.equalTo(self.vImageView.mas_right).offset(6);
//      make.centerY.equalTo(self.nameLabel);
//      make.width.equalTo(@60);
//      make.height.equalTo(@18);
//    }];
//  } else {
//    [self.specialTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//      make.left.equalTo(self.nameLabel.mas_right).offset(6);
//      make.centerY.equalTo(self.nameLabel);
//      make.width.equalTo(@60);
//      make.height.equalTo(@18);
//    }];
//  }

  [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(self.contentView).offset(-16);
      make.centerY.equalTo(self.contentView);
      make.width.height.equalTo(@30);
  }];

  [self.followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(self.moreBtn.mas_left).offset(-8);
      make.centerY.equalTo(self.contentView);
      make.width.equalTo(@80);
      make.height.equalTo(@28);
  }];

  [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.contentView).offset(16);
      make.right.equalTo(self.contentView).offset(-16);
      make.bottom.equalTo(self.contentView);
      make.height.equalTo(@0.5);
  }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

  UIBezierPath *tagPath = [UIBezierPath bezierPathWithRoundedRect:self.specialTagLabel.bounds cornerRadius:(CGFloat)self.specialTagLabel.bounds.size.height/2];
  CAShapeLayer *tagMask = [CAShapeLayer layer];
  tagMask.path = tagPath.CGPath;
  self.specialTagLabel.layer.mask = tagMask;

  CAShapeLayer *tagBorderLayer = [CAShapeLayer layer];
  tagBorderLayer.path = tagPath.CGPath;
  tagBorderLayer.strokeColor = [UIColor grayColor].CGColor;
  tagBorderLayer.fillColor = [UIColor clearColor].CGColor;
  tagBorderLayer.lineWidth = 0.5;
  tagBorderLayer.name = @"specialTagBorder";
  tagBorderLayer.frame = self.specialTagLabel.bounds;
  [self.specialTagLabel.layer addSublayer:tagBorderLayer];

  // FollowBtn mask and border
  UIBezierPath *followBtnPath = [UIBezierPath bezierPathWithRoundedRect:self.followBtn.bounds cornerRadius:3.0];
  CAShapeLayer *followBtnMask = [CAShapeLayer layer];
  followBtnMask.path = followBtnPath.CGPath;
  self.followBtn.layer.mask = followBtnMask;
}

- (void)setupWithModel:(FollowUserModel *)model {
  self.currentModel = model;
  if (!self.currentModel) return;
  self.backgroundColor = model.isSpecialBool ? [UIColor systemGray5Color] : [UIColor whiteColor];

  if (model.avatar && model.avatar.length > 0) {
      NSURL *url = [NSURL URLWithString:model.avatar];

      //SDWebImage transformer：后台裁圆角，避免离屏渲染
      static SDImageRoundCornerTransformer *avatarTransformer = nil;
      static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
          avatarTransformer = [SDImageRoundCornerTransformer transformerWithRadius:20
                                                                           corners:UIRectCornerAllCorners
                                                                       borderWidth:0
                                                                       borderColor:nil];
      });
      //缩略图尺寸（40x40 pt * 屏幕 scale）
    UIScreen *screen = self.window.screen;
    CGSize avatarSize = CGSizeMake(40 * screen.scale,
                                   40 * screen.scale);

      [self.avatarView sd_setImageWithURL:url
                           placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]
                                    options:SDWebImageRetryFailed |
                                            SDWebImageLowPriority |
                                            SDWebImageScaleDownLargeImages |
                                            SDWebImageDecodeFirstFrameOnly
                                    context:@{
          SDWebImageContextImageTransformer: avatarTransformer,
          SDWebImageContextImageThumbnailPixelSize: @(avatarSize),
          SDWebImageContextStoreCacheType: @(SDImageCacheTypeMemory)
      }
                                   progress:nil
                                  completed:nil];
  } else {
      self.avatarView.image = nil;
  }

  self.nameLabel.text = [model shownName];
  self.vImageView.hidden = !model.isV;
  self.specialTagLabel.hidden = !model.isSpecialBool;

  if (self.currentModel.isMutualFollowBool) {
      [self.followBtn setTitle:@"互相关注" forState:UIControlStateNormal];
      self.followBtn.backgroundColor = [UIColor systemGray6Color];
      [self.followBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  } else if (self.currentModel.isFollowingBool) {
      [self.followBtn setTitle:@"已关注" forState:UIControlStateNormal];
      self.followBtn.backgroundColor = [UIColor systemGray6Color];
      [self.followBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  } else {
      [self.followBtn setTitle:@"关注" forState:UIControlStateNormal];
      self.followBtn.backgroundColor = [UIColor redColor];
      [self.followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  }
}

- (void)followBtnClicked {
  if ([self.delegate respondsToSelector:@selector(followCell:didClickFollowBtnWithModel:)]) {
      [self.delegate followCell:self didClickFollowBtnWithModel:self.currentModel];
  }
}

- (void)moreBtnClicked {
  if ([self.delegate respondsToSelector:@selector(followCell:didClickMoreBtnWithModel:)]) {
      [self.delegate followCell:self didClickMoreBtnWithModel:self.currentModel];
  }
}

//引用学长博客的一段话：而且依我本人之见，最好使用清除旧数据而不是remove多余的子视图。因为这个正在新建的cell后面也许也会进入自动释放池，而且它到时候也可能会被拿来复用，如果那个复用它的cell刚好需要显示button而这个被复用的cell连button这个视图都没添加到cell上，那直接向button添加数据时程序就会crash，所以清除所有数据是不错的选择，反正每次执行编辑函数：cellForRowAtIndexPath:时都会为对应行组的cell重新添加那些子视图上的数据（相当于覆写了旧数据），我们只需要在所有的重新添加数据操作之前讲被复用的cell上子视图的数据全删了就行。

- (void)prepareForReuse {
  [super prepareForReuse];
  [self.avatarView sd_cancelCurrentImageLoad];
  self.avatarView.image = nil;
//  self.avatarView.layer.cornerRadius = 0;
  self.nameLabel.text = nil;
  self.specialTagLabel.hidden = YES;
  self.vImageView.hidden = YES;
  self.currentModel = nil;
}


@end
