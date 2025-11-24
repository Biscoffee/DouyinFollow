//
//  NetworManager.m
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/22.
//

#import "NetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import "FollowUserModel.h"
//#define followKey @"FollowListCacheKey"
@implementation NetworkManager

+ (instancetype)sharedManager {
    static NetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetworkManager alloc] init];
    });
    return manager;
}

- (void)getFollowListSuccess:(SuccessBlock)success failure:(FailureBlock)failure {
  //创建一个单里session
  static AFHTTPSessionManager *session;
  static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
          session = [AFHTTPSessionManager manager];
          session.responseSerializer = [AFHTTPResponseSerializer serializer];
        //session.responseSerializer = [AFJSONResponseSerializer serializer];
          session.requestSerializer.timeoutInterval = 10;
      });
    NSString *url = @"https://m1.apifoxmock.com/m1/7448820-7183141-default/api/v1/user/follow/list";
    NSLog(@"kais1下载数据%@", [NSDate date]);
    [session GET:url parameters:nil headers:nil progress:nil
         success:^(NSURLSessionDataTask *task, id resultObject) {
//      NSDictionary *dict = (NSDictionary *)resultObject;
//      NSArray *data = dict[@"data"];
//      if ([dict[@"code"] integerValue] != 200) {
//          if (failure) {
//            NSLog(@"接口错误");
//          }
//          return;
//      }
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:resultObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@", dict);
        if ([dict[@"code"] integerValue] != 200) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
              failure(@"接口错了");
            }
          });
            return;
        }

        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:followKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
            NSArray *data = dict[@"data"];
    //      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError *parseErr = nil;
            NSArray *users = [FollowUserModel arrayOfModelsFromDictionaries:data error:&parseErr];
            if (parseErr) {
                if (failure) {
                  failure(@"请求失败");
                }
                return;
            }
          //dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (FollowUserModel *model in users) {
              [model loadLocalState];
              
            }
            dispatch_async(dispatch_get_main_queue(), ^{
              if(success) success(users);
            });
          });

      //});
//        NSError *parseErr = nil;
//        NSArray *users = [FollowUserModel arrayOfModelsFromDictionaries:data error:&parseErr];
//
//        if (parseErr) {
//            if (failure) {
//              failure(@"请求失败");
//            }
//            return;
//        }
//      //dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        for (FollowUserModel *model in users) {
//          [model loadLocalState];
//       // }
//        dispatch_async(dispatch_get_main_queue(), ^{
//          if(success) success(users);
//        });
//      });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
      if (failure) {
        dispatch_async(dispatch_get_main_queue(), ^{
          failure(@"网络因为他");
        });
      }
    }];
}
@end

