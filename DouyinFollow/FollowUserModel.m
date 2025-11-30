//
//  FollowUserModel.m
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/20.
//

#import "FollowUserModel.h"
#import "FMDBManager.h"
@implementation FollowUserModel


+ (BOOL)propertyIsOptional:(NSString *)propertyName { return YES; }

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
      _userId = dict[@"userId"] ?: @"";
      _username = dict[@"username"] ?: @"";
      _avatar = dict[@"avatar"] ?: @"";
      _isV = dict[@"isV"] ?: @NO;
      _cursor = dict[@"cursor"];
      _isFollowing = @YES;
      _isMutualFollow = @NO;
      _remarkName = @"";
      _isSpecial = @NO;
              
      //dispatch_async(dispatch_get_global_queue(0, 0), ^{
       // [self loadLocalState];
      //});
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

- (void)saveLocalState {
  [[FMDBManager sharedManager] saveUser:self];
}

- (void) loadLocalState {
  NSArray *allUsers = [[FMDBManager sharedManager] getAllUsers];
  for (FollowUserModel *user in allUsers) {
    if ([user.userId isEqualToString:self.userId]) {
      self.isFollowing = user.isFollowing;
      self.isSpecial = user.isSpecial;
      self.isMutualFollow = user.isMutualFollow;
      self.remarkName = user.remarkName;
    }
  }
}
@end
