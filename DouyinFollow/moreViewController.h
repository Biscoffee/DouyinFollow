//
//  moreViewController.h
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FollowUserModel;

@protocol moreViewControllerDelegate <NSObject>
- (void)userChangeIfspecial:(FollowUserModel *)model isSpecial:(BOOL)isSpecial;
- (void)userRemark:(FollowUserModel *)model remark:(NSString *)remark;
- (void)userCancelledFollow:(FollowUserModel *)model;
@end

@interface moreViewController : UIViewController
- (instancetype)initWithModel:(FollowUserModel *)model;
@property (nonatomic, weak) id<moreViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
