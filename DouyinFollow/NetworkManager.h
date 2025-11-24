//
//  NetworManager.h
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/22.
//

#import <UIKit/UIKit.h>
#import "FollowUserModel.h"
#import "AFNetworking/AFNetworking.h"
#define followKey @"FollowListCacheKey"
NS_ASSUME_NONNULL_BEGIN

typedef void(^SuccessBlock)(NSArray<FollowUserModel *> *userList);
typedef void(^FailureBlock)(NSString *error);

@interface NetworkManager : NSObject
+ (instancetype)sharedManager;

- (void)getFollowListSuccess:(SuccessBlock)success failure:(FailureBlock)failure;
@end

NS_ASSUME_NONNULL_END
