//
//  FollowUserModel.m
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/20.
//

#import "FollowUserModel.h"

@implementation FollowUserModel


+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (instancetype)initWithUserId:(NSString *)userId
                      username:(NSString *)username
                        avatar:(NSString *)avatar
                           isV:(BOOL)isV
                 isMutualFollow:(BOOL)isMutualFollow {
    self = [super init];
    if (self) {
        _userId = userId ?: @"";
        _username = username ?: @"";
        _avatar = avatar ?: @"";
        _isV = isV;
        _isFollowing = @YES;
        _isMutualFollow = @(isMutualFollow);
        _remarkName = @"";
        _isSpecial = @NO;
      dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadLocalState];
      });
    }
    return self;
}

//搭配。h中的NSNumber使用以实现BOOL的功能
- (BOOL)isSpecialBool {
  return self.isSpecial ? self.isSpecial.boolValue : NO;
}
- (BOOL)isFollowingBool {
  return self.isFollowing ? self.isFollowing.boolValue : NO;
}
- (BOOL)isMutualFollowBool {
  return self.isMutualFollow ? self.isMutualFollow.boolValue : NO;
}

- (NSString *)shownName {
  if (self.remarkName && self.remarkName.length > 0) {
    return self.remarkName;
  }
  return self.username;
}

- (void)loadLocalState {
    if (self.userId.length == 0) return;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *prefix = [NSString stringWithFormat:@"Star_%@_", self.userId];

    NSString *savedRemark = [defaults objectForKey:[prefix stringByAppendingString:@"remarkName"]];
    if (savedRemark) self.remarkName = savedRemark;

    NSString *followKey = [prefix stringByAppendingString:@"isFollowing"];
    if ([defaults objectForKey:followKey] != nil) {
        self.isFollowing = @([defaults boolForKey:followKey]);
    }

    NSString *specialKey = [prefix stringByAppendingString:@"isSpecial"];
    if ([defaults objectForKey:specialKey] != nil) {
        self.isSpecial = @([defaults boolForKey:specialKey]);
    }

    NSString *mutualKey = [prefix stringByAppendingString:@"isMutualFollow"];
    if ([defaults objectForKey:mutualKey] != nil) {
        self.isMutualFollow = @([defaults boolForKey:mutualKey]);
    }
}

- (void)saveLocalState {
    if (self.userId.length == 0) return;


  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *prefix = [NSString stringWithFormat:@"Star_%@_", self.userId];

    [defaults setObject:self.remarkName ?: @"" forKey:[prefix stringByAppendingString:@"remarkName"]];
    [defaults setBool:self.isFollowingBool forKey:[prefix stringByAppendingString:@"isFollowing"]];
    [defaults setBool:self.isSpecialBool forKey:[prefix stringByAppendingString:@"isSpecial"]];
    [defaults setBool:self.isMutualFollowBool forKey:[prefix stringByAppendingString:@"isMutualFollow"]];
    [defaults synchronize];//这行代码可以让数据立即写入本地。。。？
  });

}
@end
