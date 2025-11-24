//
//  FollowTableViewCell.h
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/20.
//
#import <UIKit/UIKit.h>
@class FollowUserModel;

@protocol FollowTableViewCellDelegate <NSObject>
- (void)followCell:(UITableViewCell *)cell didClickFollowBtnWithModel:(FollowUserModel *)model;
- (void)followCell:(UITableViewCell *)cell didClickMoreBtnWithModel:(FollowUserModel *)model;
@end

@interface FollowTableViewCell : UITableViewCell

@property (nonatomic, weak) id<FollowTableViewCellDelegate> delegate;
@property (nonatomic, strong) FollowUserModel *currentModel;
- (void)setupWithModel:(FollowUserModel *)model;

@end
