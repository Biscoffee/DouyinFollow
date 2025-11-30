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

typedef void(^SuccessBlock)(NSArray<FollowUserModel *> *users, NSInteger nextPage, BOOL hasMore);
typedef void(^FailureBlock)(NSString *error);

@interface NetworkManager : NSObject
@property (nonatomic, assign) NSInteger group;
@property (nonatomic, assign) BOOL hasMore;
+ (instancetype)sharedManager;
- (void)getFollowListWithGroup:(NSInteger)group
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
