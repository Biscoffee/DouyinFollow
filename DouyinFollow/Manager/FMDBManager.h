//
//  FMDBManager.h
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/28.
//
#import "FollowUserModel.h"
#import <Foundation/Foundation.h>
#import "FMDB/FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMDBManager : NSObject

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

+ (id)sharedManager;
- (void)resetDB;
- (void)setupDatabase;
- (void)saveUser:(FollowUserModel *)user;
- (void)saveUsers:(NSArray<FollowUserModel *> *)users;
- (NSArray<FollowUserModel *> *)getAllUsers;
- (NSArray<FollowUserModel *> *)getUsersWithGroup:(NSInteger)group pageSize:(NSInteger)pageSize;

@end

NS_ASSUME_NONNULL_END
