//
//  FMDBManager.m
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/28.
//

#import "FMDBManager.h"
#import "FollowUserModel.h"
@implementation FMDBManager

+ (instancetype)sharedManager {
    static FMDBManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager setupDB];
    });
    return manager;
}

- (void)setupDB {
  NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
  NSString *dbPath = [docs stringByAppendingPathComponent:@"followUsers.db"];
  self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
  [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
    BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS FollowUser (userId TEXT PRIMARY KEY, username TEXT, avatar TEXT, isV INTEGER, isFollowing INTEGER, isSpecial INTEGER, isMutualFollow INTEGER, remarkName TEXT, cursor INTEGER)"];
    if (!result) {
      NSLog(@"创建表失败：%@", db.lastErrorMessage);
    }
  }];
}

//清空数据库，用来清除之前的old数据（错误添加数据时使用）
- (void)resetDB {
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dbPath = [docs stringByAppendingPathComponent:@"followUsers.db"];
    [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
    [self setupDB];
}

-(void) saveUser:(FollowUserModel *) user {
  if (!user.userId) return;
  [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
    [db executeUpdate:@"REPLACE INTO FollowUser (userId, username, avatar, isV, isFollowing, isSpecial, isMutualFollow, remarkName, cursor) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
             user.userId,
             user.username,
             user.avatar,
             @(user.isV),
             @(user.isFollowingBool),
             @(user.isSpecialBool),
             @(user.isMutualFollowBool),
             user.remarkName ?: @"",
             user.cursor ?: @(0)];
  }];
//  [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
//    for (FollowUserModel *user in user) {
//      [db executeUpdate:@"REPLACE INTO FollowUser (userId, username, avatar, isV, isFollowing, isSpecial, isMutualFollow, remarkName, cursor) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
//               user.userId,
//               user.username,
//               user.avatar,
//               @(user.isV),
//               @(user.isFollowingBool),
//               @(user.isSpecialBool),
//               @(user.isMutualFollowBool),
//               user.remarkName ?: @"",
//               user.cursor ?: @(0)];
//    }
//  }]
}

//- (void)saveUsers:(NSArray<FollowUserModel *> *)users {
//  [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
//    for (FollowUserModel *user in users) {
//        [self saveUser:user];
//    }
//  }];
//}
- (void)saveUsers:(NSArray<FollowUserModel *> *)users {
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
      for (FollowUserModel *user in users) {
        FMResultSet *rs = [db executeQuery:@"SELECT userId FROM FollowUser WHERE userId = ?", user.userId];
        if(![rs next]) {
          [db executeUpdate:@"REPLACE INTO FollowUser (userId, username, avatar, isV, isFollowing, isSpecial, isMutualFollow, remarkName, cursor) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
           user.userId,
           user.username,
           user.avatar,
           @(user.isV),
           @(user.isFollowingBool),
           @(user.isSpecialBool),
           @(user.isMutualFollowBool),
           user.remarkName ?: @"",
           user.cursor ?: @(0)];
        }
        [rs close];
      }
    }];
}


- (NSArray<FollowUserModel *> *)getAllUsers {
    NSMutableArray *result = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM FollowUser ORDER BY cursor ASC"];
        while ([rs next]) {
            FollowUserModel *user = [[FollowUserModel alloc] init];
            user.userId = [rs stringForColumn:@"userId"];
            user.username = [rs stringForColumn:@"username"];
            user.avatar = [rs stringForColumn:@"avatar"];
            user.isV = @([rs boolForColumn:@"isV"]);
            user.isFollowing = @([rs boolForColumn:@"isFollowing"]);
            user.isSpecial = @([rs boolForColumn:@"isSpecial"]);
            user.isMutualFollow = @([rs boolForColumn:@"isMutualFollow"]);
            user.remarkName = [rs stringForColumn:@"remarkName"];
            user.cursor = @([rs intForColumn:@"cursor"]);
            [result addObject:user];
        }
        [rs close];
    }];
    return result;
}

- (NSArray<FollowUserModel *> *)getUsersWithGroup:(NSInteger)group pageSize:(NSInteger)pageSize {
    NSMutableArray *result = [NSMutableArray array];
    NSInteger offset = group * pageSize;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM FollowUser ORDER BY cursor ASC LIMIT ? OFFSET ?", @(pageSize), @(offset)];
        while ([rs next]) {
            FollowUserModel *user = [[FollowUserModel alloc] init];
            user.userId = [rs stringForColumn:@"userId"];
            user.username = [rs stringForColumn:@"username"];
            user.avatar = [rs stringForColumn:@"avatar"];
            user.isV = @([rs boolForColumn:@"isV"]);
            user.isFollowing = @([rs boolForColumn:@"isFollowing"]);
            user.isSpecial = @([rs boolForColumn:@"isSpecial"]);
            user.isMutualFollow = @([rs boolForColumn:@"isMutualFollow"]);
            user.remarkName = [rs stringForColumn:@"remarkName"];
            user.cursor = @([rs intForColumn:@"cursor"]);
            [result addObject:user];
        }
        [rs close];
    }];
    return result;
}
@end
