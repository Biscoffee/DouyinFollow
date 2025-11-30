//
//  FollowUserModel.h
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/20.
//

#import "JSONModel.h"
//#import "FMDBManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface FollowUserModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *username;
@property (nonatomic, copy) NSString<Optional> *avatar;
@property (nonatomic, copy) NSString<Optional> *userId;
@property (nonatomic, assign) BOOL isV;
@property (nonatomic, strong) NSNumber *cursor;

//本地状态（不是请求的mock，需要使用 NSNumber<Optional>以兼容 JSONModel，否则JSON会报错。）
@property (nonatomic, strong) NSNumber<Optional> *isSpecial;
@property (nonatomic, assign) BOOL isSpeciaol;
@property (nonatomic, strong) NSNumber<Optional> *isFollowing;
@property (nonatomic, strong) NSNumber<Optional> *isMutualFollow;
@property (nonatomic, copy)   NSString<Optional> *remarkName;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (BOOL)isSpecialBool;
- (BOOL)isFollowingBool;
- (BOOL)isMutualFollowBool;
- (NSString *)shownName;

- (void)loadLocalState;
- (void)saveLocalState;

@end

NS_ASSUME_NONNULL_END
